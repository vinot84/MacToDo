import SwiftUI

struct IntegrationSettingsView: View {
    @EnvironmentObject var integrationManager: IntegrationManager
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingQuipAuth = false
    @State private var showingSlackAuth = false
    @State private var showingChorusAuth = false
    @State private var quipToken = ""
    @State private var slackToken = ""
    @State private var chorusApiKey = ""
    @State private var showingSyncSheet = false
    @State private var actionableItems: [IntegratedItem] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Integrations")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.textPrimary)
            
            Text("Connect your productivity tools to automatically create todos")
                .font(.body)
                .foregroundColor(themeManager.textSecondary)
            
            // User Profile Section
            VStack(alignment: .leading, spacing: 12) {
                Text("User Profile")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("Configure your user information for mention detection in Slack and Mail")
                    .font(.caption)
                    .foregroundColor(themeManager.textSecondary)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.subheadline)
                        TextField("Your display name", text: $integrationManager.userProfile.userDisplayName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.subheadline)
                        TextField("Your username", text: $integrationManager.userProfile.userName)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Addresses")
                        .font(.subheadline)
                    Text("Add your email addresses for Mail integration (one per line)")
                        .font(.caption2)
                        .foregroundColor(themeManager.textSecondary)
                    
                    TextEditor(text: Binding(
                        get: { integrationManager.userProfile.userEmailAddresses.joined(separator: "\n") },
                        set: { newValue in
                            integrationManager.userProfile.userEmailAddresses = newValue
                                .components(separatedBy: .newlines)
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }
                        }
                    ))
                    .frame(height: 60)
                    .border(Color.gray.opacity(0.3))
                }
                
                Button("Save Profile") {
                    integrationManager.userProfile.saveUserProfile()
                }
                .buttonStyle(.bordered)
                .tint(themeManager.accent)
            }
            .padding()
            .background(themeManager.card)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.border, lineWidth: 1)
            )
            
            VStack(spacing: 16) {
                IntegrationCard(
                    title: "Apple Mail",
                    description: "Create todos from action items in your emails",
                    isConnected: integrationManager.mailManager.isAuthenticated,
                    lastSync: integrationManager.mailManager.lastSyncDate,
                    status: integrationManager.mailManager.connectionStatus,
                    errorMessage: integrationManager.mailManager.lastError,
                    onConnect: { 
                        Task {
                            await integrationManager.mailManager.authenticate()
                        }
                    },
                    onDisconnect: { integrationManager.mailManager.logout() },
                    onSync: {
                        Task {
                            await integrationManager.mailManager.syncEmails()
                        }
                    }
                )
                
                IntegrationCard(
                    title: "Quip Documents",
                    description: "Sync action items from your Quip documents",
                    isConnected: integrationManager.quipManager.isAuthenticated,
                    lastSync: integrationManager.quipManager.lastSyncDate,
                    onConnect: { showingQuipAuth = true },
                    onDisconnect: { integrationManager.quipManager.logout() },
                    onSync: { 
                        Task {
                            await integrationManager.quipManager.syncDocuments()
                        }
                    }
                )
                
                IntegrationCard(
                    title: "Slack Channels",
                    description: "Create todos from actionable Slack messages",
                    isConnected: integrationManager.slackManager.isAuthenticated,
                    lastSync: integrationManager.slackManager.lastSyncDate,
                    onConnect: { showingSlackAuth = true },
                    onDisconnect: { integrationManager.slackManager.logout() },
                    onSync: {
                        Task {
                            await integrationManager.slackManager.syncMessages()
                        }
                    }
                )
                
                IntegrationCard(
                    title: "Chorus Meetings",
                    description: "Import action items from meeting recordings",
                    isConnected: integrationManager.chorusManager.isAuthenticated,
                    lastSync: integrationManager.chorusManager.lastSyncDate,
                    onConnect: { showingChorusAuth = true },
                    onDisconnect: { integrationManager.chorusManager.logout() },
                    onSync: {
                        Task {
                            await integrationManager.chorusManager.syncMeetings()
                        }
                    }
                )
            }
            
            Divider()
            
            HStack {
                Button("Sync All") {
                    Task {
                        await integrationManager.syncAllIntegrations()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accent)
                .disabled(!integrationManager.isConfigured)
                
                Button("Review Actions") {
                    loadActionableItems()
                    showingSyncSheet = true
                }
                .buttonStyle(.bordered)
                .tint(themeManager.secondary)
                .disabled(!integrationManager.isConfigured)
                
                Spacer()
            }
            }
            .padding()
        }
        .sheet(isPresented: $showingQuipAuth) {
            AuthenticationSheet(
                title: "Connect Quip",
                description: "Enter your Quip API token",
                tokenLabel: "API Token",
                token: $quipToken,
                onAuthenticate: {
                    Task {
                        await integrationManager.quipManager.authenticate(token: quipToken)
                        showingQuipAuth = false
                        quipToken = ""
                    }
                },
                onCancel: {
                    showingQuipAuth = false
                    quipToken = ""
                }
            )
        }
        .sheet(isPresented: $showingSlackAuth) {
            AuthenticationSheet(
                title: "Connect Slack",
                description: "Enter your Slack Bot User OAuth Token",
                tokenLabel: "Bot Token (xoxb-...)",
                token: $slackToken,
                onAuthenticate: {
                    Task {
                        await integrationManager.slackManager.authenticate(token: slackToken)
                        showingSlackAuth = false
                        slackToken = ""
                    }
                },
                onCancel: {
                    showingSlackAuth = false
                    slackToken = ""
                }
            )
        }
        .sheet(isPresented: $showingChorusAuth) {
            AuthenticationSheet(
                title: "Connect Chorus",
                description: "Enter your Chorus API key",
                tokenLabel: "API Key",
                token: $chorusApiKey,
                onAuthenticate: {
                    Task {
                        await integrationManager.chorusManager.authenticate(apiKey: chorusApiKey)
                        showingChorusAuth = false
                        chorusApiKey = ""
                    }
                },
                onCancel: {
                    showingChorusAuth = false
                    chorusApiKey = ""
                }
            )
        }
        .sheet(isPresented: $showingSyncSheet) {
            ActionableItemsSheet(
                items: actionableItems,
                onCreateTodos: { selectedItems in
                    for item in selectedItems {
                        integrationManager.createTodoFromIntegration(item, todoStore: todoStore)
                    }
                    showingSyncSheet = false
                },
                onCancel: {
                    showingSyncSheet = false
                }
            )
        }
    }
    
    private func loadActionableItems() {
        var items: [IntegratedItem] = []
        items.append(contentsOf: integrationManager.quipManager.getActionableItems())
        items.append(contentsOf: integrationManager.slackManager.getActionableItems())
        items.append(contentsOf: integrationManager.chorusManager.getActionableItems())
        items.append(contentsOf: integrationManager.mailManager.getActionableItems())
        actionableItems = items
    }
}

struct IntegrationCard: View {
    let title: String
    let description: String
    let isConnected: Bool
    let lastSync: Date?
    let status: String?
    let errorMessage: String?
    let onConnect: () -> Void
    let onDisconnect: () -> Void
    let onSync: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    init(title: String, description: String, isConnected: Bool, lastSync: Date?, status: String? = nil, errorMessage: String? = nil, onConnect: @escaping () -> Void, onDisconnect: @escaping () -> Void, onSync: @escaping () -> Void) {
        self.title = title
        self.description = description
        self.isConnected = isConnected
        self.lastSync = lastSync
        self.status = status
        self.errorMessage = errorMessage
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        self.onSync = onSync
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                }
                
                Spacer()
                
                Circle()
                    .fill(isConnected ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)
            }
            
            // Status and error messages
            if let status = status {
                Text(status)
                    .font(.caption2)
                    .foregroundColor(isConnected ? .green : .orange)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .padding(.top, 2)
            }
            
            if let lastSync = lastSync {
                Text("Last sync: \(lastSync, formatter: dateFormatter)")
                    .font(.caption2)
                    .foregroundColor(themeManager.textSecondary)
            }
            
            HStack {
                if isConnected {
                    Button("Sync") {
                        onSync()
                    }
                    .buttonStyle(.bordered)
                    .tint(themeManager.accent)
                    
                    Button("Disconnect") {
                        onDisconnect()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(themeManager.danger)
                } else {
                    Button("Connect") {
                        onConnect()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(themeManager.accent)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(themeManager.card)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.border, lineWidth: 1)
        )
    }
}

struct AuthenticationSheet: View {
    let title: String
    let description: String
    let tokenLabel: String
    @Binding var token: String
    let onAuthenticate: () -> Void
    let onCancel: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(.plain)
            }
            
            Text(description)
                .font(.body)
                .foregroundColor(themeManager.textSecondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(tokenLabel)
                    .font(.headline)
                
                SecureField("Enter token", text: $token)
                    .textFieldStyle(.roundedBorder)
            }
            
            Text("Your credentials are stored securely in the system keychain.")
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("Connect") {
                    onAuthenticate()
                }
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accent)
                .disabled(token.isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 300)
    }
}

struct ActionableItemsSheet: View {
    let items: [IntegratedItem]
    let onCreateTodos: ([IntegratedItem]) -> Void
    let onCancel: () -> Void
    @State private var selectedItems: Set<String> = []
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Actionable Items")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Cancel") {
                    onCancel()
                }
                .buttonStyle(.plain)
            }
            
            Text("Select items to convert to todos:")
                .foregroundColor(themeManager.textSecondary)
            
            if items.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                    
                    Text("No actionable items found")
                        .font(.title3)
                    
                    Text("All caught up!")
                        .foregroundColor(themeManager.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(items) { item in
                    HStack {
                        Button(action: {
                            if selectedItems.contains(item.id) {
                                selectedItems.remove(item.id)
                            } else {
                                selectedItems.insert(item.id)
                            }
                        }) {
                            Image(systemName: selectedItems.contains(item.id) ? "checkmark.square.fill" : "square")
                                .foregroundColor(selectedItems.contains(item.id) ? themeManager.accent : themeManager.textSecondary)
                        }
                        .buttonStyle(.plain)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text(item.description)
                                .font(.caption)
                                .foregroundColor(themeManager.textSecondary)
                                .lineLimit(2)
                            
                            HStack {
                                Text(item.source)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(themeManager.accent.opacity(0.2))
                                    .cornerRadius(4)
                                
                                if let dueDate = item.dueDate {
                                    Text("Due: \(dueDate, formatter: dateFormatter)")
                                        .font(.caption2)
                                        .foregroundColor(themeManager.textSecondary)
                                }
                                
                                Spacer()
                                
                                Circle()
                                    .fill(priorityColor(item.priority))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
                
                HStack {
                    Button("Select All") {
                        selectedItems = Set(items.map { $0.id })
                    }
                    .buttonStyle(.plain)
                    .disabled(items.isEmpty)
                    
                    Button("Deselect All") {
                        selectedItems.removeAll()
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedItems.isEmpty)
                    
                    Spacer()
                    
                    Button("Create \(selectedItems.count) Todos") {
                        let selected = items.filter { selectedItems.contains($0.id) }
                        onCreateTodos(selected)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(themeManager.accent)
                    .disabled(selectedItems.isEmpty)
                }
            }
        }
        .padding()
        .frame(width: 700, height: 500)
    }
    
    private func priorityColor(_ priority: IntegratedPriority) -> Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
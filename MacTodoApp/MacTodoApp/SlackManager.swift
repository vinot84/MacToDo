import Foundation
import Combine

@MainActor
class SlackManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var channels: [SlackChannel] = []
    @Published var messages: [SlackMessage] = []
    @Published var lastSyncDate: Date?
    
    private var accessToken: String?
    private let baseURL = "https://slack.com/api"
    
    // User profile for mention detection
    private var userName: String = ""
    private var userDisplayName: String = ""
    private var slackUserId: String = ""
    
    func updateUserProfile(userName: String, displayName: String, userId: String) {
        self.userName = userName
        self.userDisplayName = displayName
        self.slackUserId = userId
    }
    
    func authenticate(token: String) async {
        self.accessToken = token
        await validateToken()
    }
    
    private func validateToken() async {
        guard let token = accessToken else { return }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/auth.test")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(SlackAuthResponse.self, from: data)
            isAuthenticated = response.ok
            if isAuthenticated {
                // Store user ID for mentions if available
                if let userId = response.user_id {
                    slackUserId = userId
                }
                saveCredentials()
                await loadChannels()
            }
        } catch {
            print("Slack authentication failed: \(error)")
            isAuthenticated = false
        }
    }
    
    func syncMessages() async {
        guard isAuthenticated, let token = accessToken else { return }
        
        var allMessages: [SlackMessage] = []
        
        for channel in channels {
            var request = URLRequest(url: URL(string: "\(baseURL)/conversations.history?channel=\(channel.id)&limit=50")!)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let response = try JSONDecoder().decode(SlackMessagesResponse.self, from: data)
                
                if response.ok {
                    let channelMessages = response.messages.map { msg in
                        SlackMessage(
                            id: msg.ts,
                            text: msg.text,
                            user: msg.user ?? "Unknown",
                            channel: channel.name,
                            channelId: channel.id,
                            timestamp: Double(msg.ts) ?? 0
                        )
                    }
                    allMessages.append(contentsOf: channelMessages)
                }
            } catch {
                print("Failed to sync messages for channel \(channel.name): \(error)")
            }
        }
        
        messages = allMessages
        lastSyncDate = Date()
    }
    
    private func loadChannels() async {
        guard let token = accessToken else { return }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/conversations.list?types=public_channel,private_channel")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(SlackChannelsResponse.self, from: data)
            
            if response.ok {
                channels = response.channels.filter { !$0.isArchived }
            }
        } catch {
            print("Failed to load channels: \(error)")
        }
    }
    
    private func isUserMentioned(in text: String) -> Bool {
        let lowercaseText = text.lowercased()
        
        // Check for @username mentions
        if !userName.isEmpty && lowercaseText.contains("@\(userName.lowercased())") {
            return true
        }
        
        // Check for display name mentions
        if !userDisplayName.isEmpty && lowercaseText.contains(userDisplayName.lowercased()) {
            return true
        }
        
        // Check for Slack user ID mentions
        if !slackUserId.isEmpty && lowercaseText.contains("<@\(slackUserId)>") {
            return true
        }
        
        return false
    }
    
    func getActionableItems() -> [IntegratedItem] {
        let actionKeywords = ["todo", "task", "action", "follow up", "reminder", "@channel", "urgent"]
        
        return messages.compactMap { msg in
            let hasActionableContent = actionKeywords.contains { keyword in
                msg.text.lowercased().contains(keyword.lowercased())
            }
            
            let isUserMentioned = isUserMentioned(in: msg.text)
            
            // Create todo if message has actionable content OR mentions the user
            if hasActionableContent || isUserMentioned {
                let priority: IntegratedPriority
                if msg.text.lowercased().contains("urgent") || isUserMentioned {
                    priority = .high
                } else {
                    priority = .medium
                }
                
                let titlePrefix = isUserMentioned ? "💬 You were mentioned" : "Slack Action"
                
                return IntegratedItem(
                    id: msg.id,
                    title: "\(titlePrefix): #\(msg.channel)",
                    description: msg.text,
                    priority: priority,
                    dueDate: Calendar.current.date(byAdding: .day, value: isUserMentioned ? 1 : 2, to: Date()),
                    url: "slack://channel?id=\(msg.channelId)&message=\(msg.id)",
                    source: "Slack Message",
                    createdAt: Date(timeIntervalSince1970: msg.timestamp)
                )
            }
            return nil
        }
    }
    
    func saveCredentials() {
        if let token = accessToken {
            UserDefaults.standard.set(token, forKey: "slack_token")
        }
    }
    
    func loadCredentials() {
        if let token = UserDefaults.standard.string(forKey: "slack_token") {
            self.accessToken = token
            Task {
                await validateToken()
            }
        }
    }
    
    func logout() {
        accessToken = nil
        isAuthenticated = false
        channels = []
        messages = []
        UserDefaults.standard.removeObject(forKey: "slack_token")
    }
}

struct SlackChannel: Codable, Identifiable {
    let id: String
    let name: String
    let isArchived: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case isArchived = "is_archived"
    }
}

struct SlackMessage: Codable, Identifiable {
    let id: String
    let text: String
    let user: String
    let channel: String
    let channelId: String
    let timestamp: Double
}

struct SlackAuthResponse: Codable {
    let ok: Bool
    let user: String?
    let user_id: String?
    let team: String?
}

struct SlackChannelsResponse: Codable {
    let ok: Bool
    let channels: [SlackChannel]
}

struct SlackMessagesResponse: Codable {
    let ok: Bool
    let messages: [SlackMessageData]
}

struct SlackMessageData: Codable {
    let ts: String
    let text: String
    let user: String?
}
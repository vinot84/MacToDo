import Foundation
import Combine
import AppKit

@MainActor
class IntegrationManager: ObservableObject {
    @Published var quipManager = QuipManager()
    @Published var slackManager = SlackManager()
    @Published var chorusManager = ChorusManager()
    @Published var mailManager = MailManager()
    @Published var userProfile = UserProfileManager()
    @Published var isConfigured = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadConfiguration()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest4(
            quipManager.$isAuthenticated,
            slackManager.$isAuthenticated,
            chorusManager.$isAuthenticated,
            mailManager.$isAuthenticated
        )
        .map { quip, slack, chorus, mail in
            quip || slack || chorus || mail
        }
        .assign(to: \.isConfigured, on: self)
        .store(in: &cancellables)
        
        // Update Slack manager with user profile
        userProfile.$userName
            .combineLatest(userProfile.$userDisplayName, userProfile.$slackUserId)
            .sink { [weak self] userName, displayName, userId in
                self?.slackManager.updateUserProfile(userName: userName, displayName: displayName, userId: userId)
            }
            .store(in: &cancellables)
        
        // Update Mail manager with user profile
        userProfile.$userName
            .combineLatest(userProfile.$userDisplayName, userProfile.$userEmailAddresses)
            .sink { [weak self] userName, displayName, emailAddresses in
                self?.mailManager.updateUserProfile(userName: userName, displayName: displayName, emailAddresses: emailAddresses)
            }
            .store(in: &cancellables)
    }
    
    func syncAllIntegrations() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.quipManager.syncDocuments() }
            group.addTask { await self.slackManager.syncMessages() }
            group.addTask { await self.chorusManager.syncMeetings() }
            group.addTask { await self.mailManager.syncEmails() }
        }
    }
    
    func createTodoFromIntegration(_ item: IntegratedItem, todoStore: TodoStore) {
        let priority: TodoItem.Priority = switch item.priority {
        case .high: .high
        case .medium: .medium
        case .low: .low
        }
        
        let sourceType: TodoItem.SourceType = switch item.source {
        case "Quip Document": .quip
        case "Slack Message": .slack
        case "Chorus Meeting", "Chorus Follow-up": .chorus
        case "Mail Message": .mail
        default: .manual
        }
        
        todoStore.addTodo(
            title: item.title,
            priority: priority,
            dueDate: item.dueDate,
            sourceType: sourceType,
            sourceUrl: item.url,
            sourceId: item.id
        )
        
        if let index = todoStore.todos.firstIndex(where: { $0.title == item.title }) {
            todoStore.todos[index].updateNotes("\(item.source): \(item.description)\n\nLink: \(item.url)")
            todoStore.updateTodo(todoStore.todos[index])
        }
    }
    
    func openIntegrationSource(for todo: TodoItem) {
        guard let sourceUrl = todo.sourceUrl,
              let url = URL(string: sourceUrl) else { return }
        
        NSWorkspace.shared.open(url)
    }
    
    private func loadConfiguration() {
        quipManager.loadCredentials()
        slackManager.loadCredentials()
        chorusManager.loadCredentials()
        mailManager.loadCredentials()
    }
}

struct IntegratedItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let priority: IntegratedPriority
    let dueDate: Date?
    let url: String
    let source: String
    let createdAt: Date
}

enum IntegratedPriority {
    case high, medium, low
}
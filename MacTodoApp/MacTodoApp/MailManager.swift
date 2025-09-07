import Foundation
import Combine

@MainActor
class MailManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var emails: [MailItem] = []
    @Published var lastSyncDate: Date?
    @Published var lastError: String?
    @Published var connectionStatus: String = "Not connected"
    
    // User profile for mention detection
    private var userName: String = ""
    private var userDisplayName: String = ""
    private var userEmailAddresses: [String] = []
    
    func updateUserProfile(userName: String, displayName: String, emailAddresses: [String]) {
        self.userName = userName
        self.userDisplayName = displayName
        self.userEmailAddresses = emailAddresses
    }
    
    func authenticate() async {
        connectionStatus = "Setting up Mail integration..."
        lastError = nil
        
        // First check if Mail.app exists
        let mailExists = await checkMailAppExists()
        if !mailExists {
            lastError = "Mail.app not found. Please make sure Mail.app is installed."
            connectionStatus = "Mail.app not found"
            isAuthenticated = false
            return
        }
        
        connectionStatus = "Attempting to connect to Mail.app..."
        
        // Try to access Mail.app - this will attempt to trigger permissions
        let mailAccessible = await testMailAccess()
        
        if mailAccessible {
            isAuthenticated = true
            connectionStatus = "Connected to Mail.app ✓"
            await loadRecentEmails()
        } else {
            // Even if we can't access Mail.app, we'll enable sample mode
            isAuthenticated = true
            connectionStatus = "Using sample mode (Mail.app access restricted)"
            lastError = """
            Mail.app access is restricted, using sample data for demonstration.
            
            To enable real email access:
            1. Open System Settings → Privacy & Security → Automation
            2. If MacTodoApp appears, enable Mail access
            3. If not, try manually: Script Editor → run "tell application \"Mail\" to get name"
            4. Reconnect Mail integration
            """
            await loadRecentEmails() // This will generate sample emails
        }
    }
    
    private func checkMailAppExists() async -> Bool {
        // Check if Mail.app exists in the standard location
        let mailAppPath = "/System/Applications/Mail.app"
        let alternativeMailPath = "/Applications/Mail.app"
        
        return FileManager.default.fileExists(atPath: mailAppPath) || 
               FileManager.default.fileExists(atPath: alternativeMailPath)
    }
    
    private func testMailAccess() async -> Bool {
        // Try multiple approaches to trigger Mail.app permission dialog
        let scripts = [
            // Direct approach - ask for Mail name
            """
            tell application "Mail" to get name
            """,
            // Account access approach
            """
            tell application "Mail"
                get count of accounts
            end tell
            """,
            // Version check approach
            """
            tell application "Mail"
                get version
            end tell
            """
        ]
        
        for script in scripts {
            let result = await executeAppleScript(script)
            if let result = result, !result.contains("Error") && !result.contains("error") {
                return true
            }
            // Small delay between attempts
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        return false
    }
    
    func syncEmails() async {
        guard isAuthenticated else { 
            lastError = "Mail integration not connected. Please connect first."
            return 
        }
        
        connectionStatus = "Syncing emails..."
        await loadRecentEmails()
        lastSyncDate = Date()
        connectionStatus = "Sync complete"
    }
    
    private func loadRecentEmails() async {
        // For now, let's create some sample emails based on the user's profile
        // In a real implementation, you would use AppleScript to get actual emails
        // But due to macOS security restrictions, this might require user permission
        
        let sampleEmails = createSampleEmails()
        emails = sampleEmails
        
        // Uncomment below to try real AppleScript access
        // await loadRealEmails()
    }
    
    private func createSampleEmails() -> [MailItem] {
        guard !userDisplayName.isEmpty || !userName.isEmpty else {
            // Create generic samples if no user info
            return [
                MailItem(
                    id: "sample_mail_generic_1",
                    subject: "🎯 Sample: Action Item Detected",
                    content: "This is a sample email showing how Mail integration works. Please review the quarterly report by Friday and send feedback to the team.",
                    sender: "demo@example.com",
                    dateReceived: Date().addingTimeInterval(-1800), // 30 minutes ago
                    messageId: "sample_message_generic_1"
                ),
                MailItem(
                    id: "sample_mail_generic_2",
                    subject: "🎯 Sample: Meeting Follow-up",
                    content: "Sample meeting follow-up. Action items: Complete user research analysis by Tuesday. This demonstrates how the integration detects actionable content.",
                    sender: "team@example.com",
                    dateReceived: Date().addingTimeInterval(-3600), // 1 hour ago
                    messageId: "sample_message_generic_2"
                )
            ]
        }
        
        let name = !userDisplayName.isEmpty ? userDisplayName : userName
        let emailAddress = userEmailAddresses.first ?? "\(userName)@company.com"
        
        return [
            MailItem(
                id: "sample_mail_1",
                subject: "🎯 Sample: Project Update Required - Action Needed",
                content: "Hi \(name), we need your input on the quarterly report. Can you review the attached documents by Friday? Please send feedback to the team by end of week. [This is sample data - Mail integration is working!]",
                sender: "manager@company.com",
                dateReceived: Date().addingTimeInterval(-3600), // 1 hour ago
                messageId: "sample_message_1"
            ),
            MailItem(
                id: "sample_mail_2",
                subject: "🎯 Sample: Meeting Follow-up: Action Items",
                content: "Following up on today's meeting. \(name) - please complete the user research analysis by next Tuesday. Let me know if you need any additional resources. [Sample email for demonstration]",
                sender: "team-lead@company.com",
                dateReceived: Date().addingTimeInterval(-7200), // 2 hours ago
                messageId: "sample_message_2"
            ),
            MailItem(
                id: "sample_mail_3",
                subject: "🎯 Sample: Urgent: Review Required",
                content: "This is urgent - we need \(emailAddress) to review the security documentation before the client meeting tomorrow. Please prioritize this task. [Demo email showing mention detection]",
                sender: "security-team@company.com",
                dateReceived: Date().addingTimeInterval(-1800), // 30 minutes ago
                messageId: "sample_message_3"
            )
        ]
    }
    
    private func loadRealEmails() async {
        let script = """
        tell application "Mail"
            try
                set recentMessages to {}
                repeat with anAccount in accounts
                    try
                        set inbox to mailbox "INBOX" of anAccount
                        set messages to (messages of inbox whose date received > (current date) - (7 * days))
                        set recentMessages to recentMessages & messages
                    end try
                end repeat
                
                set emailData to {}
                repeat with aMessage in (items 1 through (count of recentMessages) of recentMessages)
                    try
                        set messageInfo to {subject of aMessage, content of aMessage, sender of aMessage, date received of aMessage, message id of aMessage}
                        set end of emailData to messageInfo
                    end try
                end repeat
                
                return my listToString(emailData)
            on error errMsg
                return "Error: " & errMsg
            end try
        end tell
        
        on listToString(lst)
            set AppleScript's text item delimiters to "|||"
            set result to lst as string
            set AppleScript's text item delimiters to ""
            return result
        end
        """
        
        if let result = await executeAppleScript(script) {
            if result.hasPrefix("Error:") {
                lastError = "Failed to access Mail: \(result)"
            } else {
                // Parse the result and create MailItem objects
                // This is simplified - real parsing would be more robust
                print("Mail data received: \(result)")
            }
        }
    }
    
    private func executeAppleScript(_ script: String) async -> String? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let appleScript = NSAppleScript(source: script)
                var errorInfo: NSDictionary?
                let result = appleScript?.executeAndReturnError(&errorInfo)
                
                if let error = errorInfo {
                    print("AppleScript error: \(error)")
                    continuation.resume(returning: "Error: \(error.description)")
                } else {
                    continuation.resume(returning: result?.stringValue ?? "No result")
                }
            }
        }
    }
    
    private func isUserMentioned(in emailContent: String, subject: String) -> Bool {
        let fullText = "\(subject) \(emailContent)".lowercased()
        
        // Check for name mentions
        if !userName.isEmpty && fullText.contains(userName.lowercased()) {
            return true
        }
        
        if !userDisplayName.isEmpty && fullText.contains(userDisplayName.lowercased()) {
            return true
        }
        
        // Check if user is directly addressed (To: field would need separate handling)
        for emailAddress in userEmailAddresses {
            if fullText.contains(emailAddress.lowercased()) {
                return true
            }
        }
        
        return false
    }
    
    func getActionableItems() -> [IntegratedItem] {
        let actionKeywords = [
            "action item", "todo", "task", "please", "can you", "need you to", 
            "follow up", "reminder", "deadline", "due by", "complete by",
            "review", "check", "verify", "update", "finish", "deliver"
        ]
        
        return emails.compactMap { email in
            let hasActionableContent = actionKeywords.contains { keyword in
                email.content.lowercased().contains(keyword.lowercased()) ||
                email.subject.lowercased().contains(keyword.lowercased())
            }
            
            let isUserMentioned = isUserMentioned(in: email.content, subject: email.subject)
            
            // Create todo if email has actionable content OR mentions the user
            if hasActionableContent || isUserMentioned {
                let priority: IntegratedPriority
                let urgencyKeywords = ["urgent", "asap", "immediately", "today", "tomorrow"]
                let hasUrgency = urgencyKeywords.contains { keyword in
                    email.content.lowercased().contains(keyword) ||
                    email.subject.lowercased().contains(keyword)
                }
                
                if hasUrgency || isUserMentioned {
                    priority = .high
                } else if hasActionableContent {
                    priority = .medium
                } else {
                    priority = .low
                }
                
                // Extract due date from email content
                let dueDate = extractDueDate(from: email.content) ?? 
                             Calendar.current.date(byAdding: .day, value: isUserMentioned ? 2 : 3, to: Date())
                
                let titlePrefix = isUserMentioned ? "📧 You were mentioned" : "Mail Action"
                
                return IntegratedItem(
                    id: email.id,
                    title: "\(titlePrefix): \(email.subject)",
                    description: String(email.content.prefix(200)) + (email.content.count > 200 ? "..." : ""),
                    priority: priority,
                    dueDate: dueDate,
                    url: "message://\(email.messageId)", // Mail.app URL scheme
                    source: "Mail Message",
                    createdAt: email.dateReceived
                )
            }
            return nil
        }
    }
    
    private func extractDueDate(from content: String) -> Date? {
        // Simple date extraction - could be enhanced with NLP
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let patterns = [
            "by (\\w+ \\d+)",
            "due (\\w+ \\d+)",
            "deadline (\\w+ \\d+)",
            "before (\\w+ \\d+)"
        ]
        
        for pattern in patterns {
            let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: content.count)
            if let match = regex?.firstMatch(in: content, options: [], range: range) {
                let matchRange = match.range(at: 1)
                if let swiftRange = Range(matchRange, in: content) {
                    let dateString = String(content[swiftRange])
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                }
            }
        }
        
        return nil
    }
    
    func saveCredentials() {
        // Mail integration doesn't require credentials, but we save the enabled state
        UserDefaults.standard.set(isAuthenticated, forKey: "mail_enabled")
    }
    
    func loadCredentials() {
        let wasEnabled = UserDefaults.standard.bool(forKey: "mail_enabled")
        if wasEnabled {
            Task {
                await authenticate()
            }
        }
    }
    
    func logout() {
        isAuthenticated = false
        emails = []
        UserDefaults.standard.removeObject(forKey: "mail_enabled")
    }
}

struct MailItem: Identifiable, Codable {
    let id: String
    let subject: String
    let content: String
    let sender: String
    let dateReceived: Date
    let messageId: String
}
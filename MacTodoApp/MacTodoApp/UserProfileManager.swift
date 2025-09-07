import Foundation
import Combine

@MainActor
class UserProfileManager: ObservableObject {
    @Published var userName: String = ""
    @Published var userDisplayName: String = ""
    @Published var slackUserId: String = ""
    @Published var userEmailAddresses: [String] = []
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadUserProfile()
    }
    
    func saveUserProfile() {
        userDefaults.set(userName, forKey: "user_name")
        userDefaults.set(userDisplayName, forKey: "user_display_name")
        userDefaults.set(slackUserId, forKey: "slack_user_id")
        userDefaults.set(userEmailAddresses, forKey: "user_email_addresses")
    }
    
    func loadUserProfile() {
        userName = userDefaults.string(forKey: "user_name") ?? ""
        userDisplayName = userDefaults.string(forKey: "user_display_name") ?? ""
        slackUserId = userDefaults.string(forKey: "slack_user_id") ?? ""
        userEmailAddresses = userDefaults.stringArray(forKey: "user_email_addresses") ?? []
    }
    
    func isUserMentioned(in text: String) -> Bool {
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
}
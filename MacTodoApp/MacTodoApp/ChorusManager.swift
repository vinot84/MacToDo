import Foundation
import Combine

@MainActor
class ChorusManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var meetings: [ChorusMeeting] = []
    @Published var lastSyncDate: Date?
    
    private var apiKey: String?
    private let baseURL = "https://api.chorus.ai/v1"
    
    func authenticate(apiKey: String) async {
        self.apiKey = apiKey
        await validateApiKey()
    }
    
    private func validateApiKey() async {
        guard let key = apiKey else { return }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/meetings?limit=1")!)
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                isAuthenticated = httpResponse.statusCode == 200
                if isAuthenticated {
                    saveCredentials()
                }
            }
        } catch {
            print("Chorus authentication failed: \(error)")
            isAuthenticated = false
        }
    }
    
    func syncMeetings() async {
        guard isAuthenticated, let key = apiKey else { return }
        
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        
        let dateFormatter = ISO8601DateFormatter()
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        var request = URLRequest(url: URL(string: "\(baseURL)/meetings?start_date=\(startDateString)&end_date=\(endDateString)&limit=100")!)
        request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(ChorusMeetingsResponse.self, from: data)
            meetings = response.meetings
            lastSyncDate = Date()
            
            await loadMeetingInsights()
        } catch {
            print("Chorus sync failed: \(error)")
        }
    }
    
    private func loadMeetingInsights() async {
        guard let key = apiKey else { return }
        
        for meeting in meetings {
            var request = URLRequest(url: URL(string: "\(baseURL)/meetings/\(meeting.id)/insights")!)
            request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                let insights = try JSONDecoder().decode(ChorusInsightsResponse.self, from: data)
                
                if let index = meetings.firstIndex(where: { $0.id == meeting.id }) {
                    meetings[index].actionItems = insights.actionItems
                    meetings[index].followUps = insights.followUps
                }
            } catch {
                print("Failed to load insights for meeting \(meeting.id): \(error)")
            }
        }
    }
    
    func getActionableItems() -> [IntegratedItem] {
        var items: [IntegratedItem] = []
        
        for meeting in meetings {
            if let actionItems = meeting.actionItems {
                for action in actionItems {
                    let priority: IntegratedPriority = action.priority == "high" ? .high : .medium
                    let dueDate = Calendar.current.date(byAdding: .day, value: 3, to: meeting.startTime)
                    
                    items.append(IntegratedItem(
                        id: "\(meeting.id)_\(action.id)",
                        title: "Chorus: \(action.title)",
                        description: "Action from meeting: \(meeting.title)\nAssigned to: \(action.assignee)",
                        priority: priority,
                        dueDate: dueDate,
                        url: meeting.recordingUrl ?? "https://chorus.ai/meetings/\(meeting.id)",
                        source: "Chorus Meeting",
                        createdAt: meeting.startTime
                    ))
                }
            }
            
            if let followUps = meeting.followUps {
                for followUp in followUps {
                    items.append(IntegratedItem(
                        id: "\(meeting.id)_followup_\(followUp.id)",
                        title: "Chorus: Follow up - \(followUp.title)",
                        description: "Follow up from meeting: \(meeting.title)\n\(followUp.description)",
                        priority: .medium,
                        dueDate: Calendar.current.date(byAdding: .day, value: 7, to: meeting.startTime),
                        url: meeting.recordingUrl ?? "https://chorus.ai/meetings/\(meeting.id)",
                        source: "Chorus Follow-up",
                        createdAt: meeting.startTime
                    ))
                }
            }
        }
        
        return items
    }
    
    func saveCredentials() {
        if let key = apiKey {
            UserDefaults.standard.set(key, forKey: "chorus_api_key")
        }
    }
    
    func loadCredentials() {
        if let key = UserDefaults.standard.string(forKey: "chorus_api_key") {
            self.apiKey = key
            Task {
                await validateApiKey()
            }
        }
    }
    
    func logout() {
        apiKey = nil
        isAuthenticated = false
        meetings = []
        UserDefaults.standard.removeObject(forKey: "chorus_api_key")
    }
}

struct ChorusMeeting: Codable, Identifiable {
    let id: String
    let title: String
    let startTime: Date
    let endTime: Date
    let recordingUrl: String?
    var actionItems: [ChorusActionItem]?
    var followUps: [ChorusFollowUp]?
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case startTime = "start_time"
        case endTime = "end_time"
        case recordingUrl = "recording_url"
    }
}

struct ChorusActionItem: Codable, Identifiable {
    let id: String
    let title: String
    let assignee: String
    let priority: String
    let status: String
}

struct ChorusFollowUp: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
}

struct ChorusMeetingsResponse: Codable {
    let meetings: [ChorusMeeting]
}

struct ChorusInsightsResponse: Codable {
    let actionItems: [ChorusActionItem]?
    let followUps: [ChorusFollowUp]?
    
    enum CodingKeys: String, CodingKey {
        case actionItems = "action_items"
        case followUps = "follow_ups"
    }
}
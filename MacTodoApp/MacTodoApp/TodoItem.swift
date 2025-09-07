import Foundation
import SwiftUI

struct TodoItem: Identifiable, Codable, Hashable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
    var priority: Priority = .medium
    var dueDate: Date?
    var notes: String = ""
    let createdAt = Date()
    var updatedAt = Date()
    
    // Integration metadata
    var sourceType: SourceType?
    var sourceUrl: String?
    var sourceId: String?
    
    enum SourceType: String, Codable, CaseIterable {
        case quip = "Quip"
        case slack = "Slack"
        case chorus = "Chorus"
        case mail = "Mail"
        case manual = "Manual"
    }
    
    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var color: Color {
            switch self {
            case .low:
                return .blue
            case .medium:
                return .orange
            case .high:
                return .red
            }
        }
    }
    
    mutating func toggle() {
        isCompleted.toggle()
        updatedAt = Date()
    }
    
    mutating func updateTitle(_ newTitle: String) {
        title = newTitle
        updatedAt = Date()
    }
    
    mutating func updatePriority(_ newPriority: Priority) {
        priority = newPriority
        updatedAt = Date()
    }
    
    mutating func updateDueDate(_ newDate: Date?) {
        dueDate = newDate
        updatedAt = Date()
    }
    
    mutating func updateNotes(_ newNotes: String) {
        notes = newNotes
        updatedAt = Date()
    }
}
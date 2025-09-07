import Foundation
import EventKit
import Combine

@MainActor
class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var hasCalendarAccess = false
    @Published var calendarStatus = "Checking calendar access..."
    
    weak var todoStore: TodoStore?
    
    init() {
        checkCalendarAccess()
    }
    
    private func checkCalendarAccess() {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized, .fullAccess:
            hasCalendarAccess = true
            calendarStatus = "Calendar access granted"
        case .denied, .restricted:
            hasCalendarAccess = false
            calendarStatus = "Calendar access denied"
        case .writeOnly:
            hasCalendarAccess = true
            calendarStatus = "Calendar write access granted"
        case .notDetermined:
            requestCalendarAccess()
        @unknown default:
            hasCalendarAccess = false
            calendarStatus = "Unknown calendar status"
        }
    }
    
    private func requestCalendarAccess() {
        calendarStatus = "Requesting calendar access..."
        
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            Task { @MainActor in
                if let error = error {
                    self?.calendarStatus = "Calendar access error: \(error.localizedDescription)"
                    self?.hasCalendarAccess = false
                    return
                }
                
                self?.hasCalendarAccess = granted
                self?.calendarStatus = granted ? "Calendar access granted" : "Calendar access denied"
            }
        }
    }
    
    // MARK: - Create Calendar Events
    
    func createCalendarEvent(for todo: TodoItem) -> Bool {
        guard hasCalendarAccess else {
            print("No calendar access to create event")
            return false
        }
        
        guard let dueDate = todo.dueDate else {
            print("Todo has no due date, cannot create calendar event")
            return false
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = todo.title
        event.notes = todo.notes.isEmpty ? nil : todo.notes
        
        // Set event time - use the exact time from dueDate
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        
        // If no specific time was set (hour and minute are both 0), default to 9 AM
        let startDate: Date
        if components.hour == 0 && components.minute == 0 {
            startDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: dueDate) ?? dueDate
        } else {
            startDate = dueDate
        }
        
        let endDate = calendar.date(byAdding: .hour, value: 1, to: startDate) ?? startDate
        
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = false
        
        // Set calendar (use default calendar)
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Note: EKEvent priority is iOS-only, so we'll add priority info to notes instead
        var eventNotes = todo.notes
        if !eventNotes.isEmpty {
            eventNotes += "\n\n"
        }
        eventNotes += "Priority: \(todo.priority.rawValue)"
        event.notes = eventNotes
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Successfully created calendar event for todo: \(todo.title)")
            return true
        } catch {
            print("Failed to create calendar event: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Sync All Todos with Calendar
    
    func syncTodosWithCalendar() {
        guard hasCalendarAccess,
              let todoStore = todoStore else {
            print("Cannot sync todos: no calendar access or todo store")
            return
        }
        
        let todosWithDueDates = todoStore.todos.filter { $0.dueDate != nil && !$0.isCompleted }
        
        for todo in todosWithDueDates {
            // Check if event already exists for this todo
            if !eventExistsForTodo(todo) {
                let success = createCalendarEvent(for: todo)
                if success {
                    print("Synced todo '\(todo.title)' with calendar")
                }
            }
        }
        
        calendarStatus = "Synced \(todosWithDueDates.count) todos with calendar"
    }
    
    private func eventExistsForTodo(_ todo: TodoItem) -> Bool {
        guard let dueDate = todo.dueDate else { return false }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: dueDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? dueDate
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        return events.contains { event in
            event.title == todo.title
        }
    }
    
    // MARK: - Get Upcoming Calendar Events
    
    func getUpcomingEvents(days: Int = 7) -> [EKEvent] {
        guard hasCalendarAccess else { return [] }
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: days, to: startDate) ?? startDate
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        return eventStore.events(matching: predicate)
    }
    
    // MARK: - Create Todo from Calendar Event
    
    func createTodoFromEvent(_ event: EKEvent) {
        guard let todoStore = todoStore else { return }
        
        // Extract priority from notes if available
        let priority: TodoItem.Priority
        if let notes = event.notes, notes.lowercased().contains("priority: high") {
            priority = .high
        } else if let notes = event.notes, notes.lowercased().contains("priority: low") {
            priority = .low
        } else {
            priority = .medium
        }
        
        let dueDate = event.startDate
        let notes = event.notes ?? ""
        
        todoStore.addTodo(title: event.title ?? "Untitled Event", priority: priority, dueDate: dueDate)
        
        // Update the newly created todo with notes if present
        if !notes.isEmpty {
            if let newTodo = todoStore.todos.last {
                var updatedTodo = newTodo
                updatedTodo.updateNotes(notes)
                todoStore.updateTodo(updatedTodo)
            }
        }
        
        print("Created todo from calendar event: \(event.title ?? "Untitled Event")")
    }
    
    // MARK: - Voice Command Integration
    
    func handleVoiceCalendarCommand(_ command: String) -> String {
        let lowercasedCommand = command.lowercased()
        
        if lowercasedCommand.contains("sync calendar") || lowercasedCommand.contains("sync with calendar") {
            syncTodosWithCalendar()
            return "Synced todos with calendar"
        }
        else if lowercasedCommand.contains("upcoming events") || lowercasedCommand.contains("what's on my calendar") {
            let events = getUpcomingEvents()
            if events.isEmpty {
                return "No upcoming events found"
            } else {
                let eventTitles = events.prefix(5).map { $0.title }.joined(separator: ", ")
                return "Upcoming events: \(eventTitles)"
            }
        }
        else if lowercasedCommand.contains("calendar status") {
            return calendarStatus
        }
        
        return "Calendar command not recognized"
    }
}
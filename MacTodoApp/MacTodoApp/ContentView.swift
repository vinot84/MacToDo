import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var calendarManager = CalendarManager()
    @State private var newTodoTitle = ""
    @State private var selectedPriority: TodoItem.Priority = .medium
    @State private var selectedTodo: TodoItem?
    @State private var showingAddSheet = false
    @State private var showingDetailSheet = false
    @State private var searchText = ""
    @State private var showingThemeSelection = false
    
    var filteredTodos: [TodoItem] {
        let todos = todoStore.filteredTodos
        if searchText.isEmpty {
            return todos
        } else {
            return todos.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("To Do List")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.textPrimary)
                        
                        Spacer()
                        
                        // Theme Selection Button
                        Button(action: { showingThemeSelection = true }) {
                            Image(systemName: "paintbrush")
                                .font(.title2)
                                .foregroundColor(themeManager.accent)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Change Theme")
                        
                        // Add Task Button
                        Button(action: { showingAddSheet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(themeManager.accent)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Add Task")
                    }
                    
                    // Stats
                    HStack(spacing: 20) {
                        StatView(title: "Total", count: todoStore.todos.count, color: themeManager.textPrimary)
                        StatView(title: "Active", count: todoStore.activeCount, color: themeManager.warning)
                        StatView(title: "Completed", count: todoStore.completedCount, color: themeManager.success)
                    }
                    
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search tasks...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(8)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .padding()
                .background(Color(NSColor.windowBackgroundColor))
                
                Divider()
                
                // Filters
                HStack {
                    ForEach(TodoStore.FilterType.allCases, id: \.self) { filter in
                        Button(filter.rawValue) {
                            todoStore.filter = filter
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(todoStore.filter == filter ? themeManager.accent : Color.clear)
                        .foregroundColor(todoStore.filter == filter ? .white : themeManager.textPrimary)
                        .cornerRadius(15)
                    }
                    
                    Spacer()
                    
                    if todoStore.completedCount > 0 {
                        Button("Clear Completed") {
                            todoStore.clearCompleted()
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(themeManager.danger)
                    }
                }
                .padding()
                
                Divider()
                
                // Todo List
                List(filteredTodos, selection: $selectedTodo) { todo in
                    TodoRowView(todo: todo) {
                        selectedTodo = todo
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .tag(todo)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                
                if filteredTodos.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: searchText.isEmpty ? "checkmark.circle" : "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text(searchText.isEmpty ? "No tasks yet" : "No matching tasks")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        if searchText.isEmpty {
                            Text("Add your first task to get started")
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        } detail: {
            if let selectedTodo = selectedTodo {
                TodoDetailView(todo: selectedTodo, calendarManager: calendarManager)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("Select a task to view details")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddTodoSheet()
        }
        .sheet(isPresented: $showingDetailSheet) {
            if let todo = selectedTodo {
                TodoDetailSheet(todo: todo)
            }
        }
        .sheet(isPresented: $showingThemeSelection) {
            ThemeSelectionView()
                .environmentObject(themeManager)
        }
        .onAppear {
            calendarManager.todoStore = todoStore
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(themeManager.background)
    }
}

struct StatView: View {
    let title: String
    let count: Int
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(themeManager.textSecondary)
            Text("\(count)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct TodoRowView: View {
    let todo: TodoItem
    let onTap: () -> Void
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                todoStore.toggleTodo(todo)
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(todo.isCompleted ? themeManager.success : themeManager.textSecondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(todo.title)
                        .font(.body)
                        .strikethrough(todo.isCompleted)
                        .foregroundColor(todo.isCompleted ? themeManager.textSecondary : themeManager.textPrimary)
                    
                    Spacer()
                    
                    Circle()
                        .fill(todo.priority.color)
                        .frame(width: 8, height: 8)
                }
                
                if let dueDate = todo.dueDate {
                    Text("Due: \(dueDate, formatter: formatterForDate(dueDate))")
                        .font(.caption)
                        .foregroundColor(dueDate < Date() ? themeManager.danger : themeManager.textSecondary)
                }
                
                if !todo.notes.isEmpty {
                    Text(todo.notes)
                        .font(.caption)
                        .foregroundColor(themeManager.textSecondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(12)
        .background(themeManager.card)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(themeManager.border, lineWidth: 1)
        )
        .shadow(color: themeManager.shadow, radius: 2, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
        .contextMenu {
            Button("Edit") {
                // We'll use the parent's selectedTodo for this
                onTap()
            }
            
            Button("Toggle Complete") {
                todoStore.toggleTodo(todo)
            }
            
            Divider()
            
            Button("Delete", role: .destructive) {
                todoStore.deleteTodo(todo)
            }
        }
    }
}

struct AddTodoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var title = ""
    @State private var priority: TodoItem.Priority = .medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var notes = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Add New Task")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.headline)
                TextField("Enter task title", text: $title)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Priority")
                        .font(.headline)
                    Picker("Priority", selection: $priority) {
                        ForEach(TodoItem.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Due Date & Time", isOn: $hasDueDate)
                        .font(.headline)
                    
                    if hasDueDate {
                        VStack(alignment: .leading, spacing: 4) {
                            DatePicker("Date", selection: $dueDate, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                            
                            DatePicker("Time", selection: $dueDate, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.compact)
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.headline)
                TextEditor(text: $notes)
                    .frame(height: 80)
                    .border(Color.gray.opacity(0.3))
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button("Add Task") {
                    todoStore.addTodo(
                        title: title,
                        priority: priority,
                        dueDate: hasDueDate ? dueDate : nil
                    )
                    if let index = todoStore.todos.firstIndex(where: { $0.title == title }) {
                        todoStore.todos[index].updateNotes(notes)
                        todoStore.updateTodo(todoStore.todos[index])
                    }
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accent)
                .disabled(title.isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
}

struct TodoDetailView: View {
    let todo: TodoItem
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingEditSheet = false
    
    // Add calendar manager - we'll pass it from parent view
    var calendarManager: CalendarManager?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with title and status
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(todo.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .strikethrough(todo.isCompleted)
                            .foregroundColor(todo.isCompleted ? .secondary : .primary)
                        
                        Text(todo.isCompleted ? "Completed" : "Active")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(todo.isCompleted ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                            .foregroundColor(todo.isCompleted ? .green : .orange)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Button("Edit") {
                        showingEditSheet = true
                    }
                    .buttonStyle(.bordered)
                    .tint(themeManager.accent)
                }
                
                // Priority indicator
                HStack {
                    Circle()
                        .fill(todo.priority.color)
                        .frame(width: 12, height: 12)
                    
                    Text("\(todo.priority.rawValue) Priority")
                        .font(.body)
                        .fontWeight(.medium)
                }
            }
            
            Divider()
            
            // Due Date
            if let dueDate = todo.dueDate {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Due Date & Time")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text(dueDate, formatter: formatterForDate(dueDate))
                            .foregroundColor(dueDate < Date() ? .red : .primary)
                        
                        if dueDate < Date() && !todo.isCompleted {
                            Text("(Overdue)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            
            // Notes
            if !todo.notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)
                    Text(todo.notes)
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Divider()
            
            // Timestamps
            VStack(alignment: .leading, spacing: 12) {
                Text("Task Information")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Created")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(todo.createdAt, formatter: dateTimeFormatter)
                                .font(.body)
                        }
                    }
                    
                    if todo.updatedAt != todo.createdAt {
                        HStack {
                            Image(systemName: "pencil.circle")
                                .foregroundColor(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Last Updated")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(todo.updatedAt, formatter: dateTimeFormatter)
                                    .font(.body)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack {
                Button(todo.isCompleted ? "Mark Incomplete" : "Mark Complete") {
                    todoStore.toggleTodo(todo)
                }
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accent)
                
                // Calendar sync button (only show if task has due date)
                if todo.dueDate != nil, let calendarManager = calendarManager {
                    Button("Add to Calendar") {
                        let success = calendarManager.createCalendarEvent(for: todo)
                        if success {
                            // Could add some visual feedback here
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(themeManager.secondary)
                }
                
                // Integration source buttons
                if let sourceType = todo.sourceType, let sourceUrl = todo.sourceUrl {
                    Button("Open in \(sourceType.rawValue)") {
                        if let url = URL(string: sourceUrl) {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(themeManager.accent)
                }
                
                Spacer()
                
                Button("Delete", role: .destructive) {
                    todoStore.deleteTodo(todo)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: $showingEditSheet) {
            TodoDetailSheet(todo: todo)
        }
    }
}

struct TodoDetailSheet: View {
    @State var todo: TodoItem
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var todoStore: TodoStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var hasDueDate: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Edit Task")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.headline)
                TextField("Enter task title", text: $todo.title)
                    .textFieldStyle(.roundedBorder)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Priority")
                        .font(.headline)
                    Picker("Priority", selection: $todo.priority) {
                        ForEach(TodoItem.Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Due Date & Time", isOn: $hasDueDate)
                        .font(.headline)
                    
                    if hasDueDate {
                        VStack(alignment: .leading, spacing: 4) {
                            DatePicker("Date", selection: Binding(
                                get: { todo.dueDate ?? Date() },
                                set: { todo.dueDate = $0 }
                            ), displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            
                            DatePicker("Time", selection: Binding(
                                get: { todo.dueDate ?? Date() },
                                set: { todo.dueDate = $0 }
                            ), displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.compact)
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes")
                    .font(.headline)
                TextEditor(text: $todo.notes)
                    .frame(height: 100)
                    .border(Color.gray.opacity(0.3))
            }
            
            Spacer()
            
            HStack {
                Button("Delete", role: .destructive) {
                    todoStore.deleteTodo(todo)
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Save Changes") {
                    if !hasDueDate {
                        todo.dueDate = nil
                    }
                    todo.updatedAt = Date()
                    todoStore.updateTodo(todo)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(themeManager.accent)
                .disabled(todo.title.isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 450)
        .onAppear {
            hasDueDate = todo.dueDate != nil
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

private let dateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

// Helper function to choose the appropriate formatter
private func formatterForDate(_ date: Date) -> DateFormatter {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: date)
    
    // If time is set to something other than midnight (00:00), show time
    if components.hour != 0 || components.minute != 0 {
        return dateTimeFormatter
    } else {
        return dateFormatter
    }
}

#Preview {
    ContentView()
        .environmentObject(TodoStore())
}
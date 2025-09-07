import Foundation
import Combine

class TodoStore: ObservableObject {
    @Published var todos: [TodoItem] = []
    @Published var filter: FilterType = .all
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
    }
    
    private let userDefaults = UserDefaults.standard
    private let todosKey = "SavedTodos"
    
    init() {
        loadTodos()
    }
    
    var filteredTodos: [TodoItem] {
        switch filter {
        case .all:
            return todos.sorted { $0.createdAt > $1.createdAt }
        case .active:
            return todos.filter { !$0.isCompleted }.sorted { $0.createdAt > $1.createdAt }
        case .completed:
            return todos.filter { $0.isCompleted }.sorted { $0.createdAt > $1.createdAt }
        }
    }
    
    var completedCount: Int {
        todos.filter { $0.isCompleted }.count
    }
    
    var activeCount: Int {
        todos.filter { !$0.isCompleted }.count
    }
    
    func addTodo(title: String, priority: TodoItem.Priority = .medium, dueDate: Date? = nil, sourceType: TodoItem.SourceType? = nil, sourceUrl: String? = nil, sourceId: String? = nil) {
        var newTodo = TodoItem(title: title, priority: priority, dueDate: dueDate)
        newTodo.sourceType = sourceType ?? .manual
        newTodo.sourceUrl = sourceUrl
        newTodo.sourceId = sourceId
        todos.append(newTodo)
        saveTodos()
    }
    
    func deleteTodo(_ todo: TodoItem) {
        todos.removeAll { $0.id == todo.id }
        saveTodos()
    }
    
    func deleteTodos(at offsets: IndexSet) {
        let todosToDelete = offsets.map { filteredTodos[$0] }
        for todo in todosToDelete {
            todos.removeAll { $0.id == todo.id }
        }
        saveTodos()
    }
    
    func toggleTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].toggle()
            saveTodos()
        }
    }
    
    func updateTodo(_ todo: TodoItem) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index] = todo
            saveTodos()
        }
    }
    
    func clearCompleted() {
        todos.removeAll { $0.isCompleted }
        saveTodos()
    }
    
    func markAllComplete() {
        for index in todos.indices {
            todos[index].isCompleted = true
            todos[index].updatedAt = Date()
        }
        saveTodos()
    }
    
    private func saveTodos() {
        if let encoded = try? JSONEncoder().encode(todos) {
            userDefaults.set(encoded, forKey: todosKey)
        }
    }
    
    private func loadTodos() {
        if let data = userDefaults.data(forKey: todosKey),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            todos = decoded
        }
    }
}
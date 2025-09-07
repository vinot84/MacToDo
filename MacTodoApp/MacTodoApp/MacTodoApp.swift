import SwiftUI

@main
struct MacTodoApp: App {
    @StateObject private var todoStore = TodoStore()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var integrationManager = IntegrationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(todoStore)
                .environmentObject(themeManager)
                .environmentObject(integrationManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 800, height: 600)
        
        Settings {
            SettingsView()
                .environmentObject(themeManager)
                .environmentObject(integrationManager)
        }
    }
}
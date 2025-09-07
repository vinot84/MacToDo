import Foundation
import SwiftUI

// MARK: - Theme Protocol
protocol AppTheme {
    var name: String { get }
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var backgroundColor: Color { get }
    var surfaceColor: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    var accentColor: Color { get }
    var successColor: Color { get }
    var warningColor: Color { get }
    var dangerColor: Color { get }
    var cardBackground: Color { get }
    var borderColor: Color { get }
    var shadowColor: Color { get }
}

// MARK: - Theme Implementations

struct LightTheme: AppTheme {
    let name = "Light"
    let primaryColor = Color(red: 0.2, green: 0.4, blue: 0.8)
    let secondaryColor = Color(red: 0.5, green: 0.7, blue: 0.9)
    let backgroundColor = Color(red: 0.98, green: 0.98, blue: 0.98)
    let surfaceColor = Color.white
    let textPrimary = Color.black
    let textSecondary = Color.gray
    let accentColor = Color.blue
    let successColor = Color.green
    let warningColor = Color.orange
    let dangerColor = Color.red
    let cardBackground = Color.white
    let borderColor = Color(red: 0.9, green: 0.9, blue: 0.9)
    let shadowColor = Color.black.opacity(0.1)
}

struct DarkTheme: AppTheme {
    let name = "Dark"
    let primaryColor = Color(red: 0.3, green: 0.5, blue: 0.9)
    let secondaryColor = Color(red: 0.4, green: 0.6, blue: 0.8)
    let backgroundColor = Color(red: 0.1, green: 0.1, blue: 0.1)
    let surfaceColor = Color(red: 0.15, green: 0.15, blue: 0.15)
    let textPrimary = Color.white
    let textSecondary = Color(red: 0.7, green: 0.7, blue: 0.7)
    let accentColor = Color(red: 0.4, green: 0.7, blue: 1.0)
    let successColor = Color(red: 0.3, green: 0.8, blue: 0.3)
    let warningColor = Color(red: 1.0, green: 0.6, blue: 0.2)
    let dangerColor = Color(red: 0.9, green: 0.3, blue: 0.3)
    let cardBackground = Color(red: 0.2, green: 0.2, blue: 0.2)
    let borderColor = Color(red: 0.3, green: 0.3, blue: 0.3)
    let shadowColor = Color.black.opacity(0.3)
}

struct ColorfulTheme: AppTheme {
    let name = "Colorful"
    let primaryColor = Color(red: 0.9, green: 0.2, blue: 0.5)
    let secondaryColor = Color(red: 0.3, green: 0.7, blue: 0.9)
    let backgroundColor = Color(red: 0.95, green: 0.95, blue: 1.0)
    let surfaceColor = Color(red: 0.98, green: 0.98, blue: 1.0)
    let textPrimary = Color(red: 0.2, green: 0.2, blue: 0.3)
    let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.5)
    let accentColor = Color(red: 0.6, green: 0.3, blue: 0.9)
    let successColor = Color(red: 0.2, green: 0.8, blue: 0.4)
    let warningColor = Color(red: 1.0, green: 0.5, blue: 0.0)
    let dangerColor = Color(red: 0.9, green: 0.2, blue: 0.4)
    let cardBackground = Color.white
    let borderColor = Color(red: 0.8, green: 0.8, blue: 0.9)
    let shadowColor = Color(red: 0.6, green: 0.3, blue: 0.9).opacity(0.1)
}

struct MinimalTheme: AppTheme {
    let name = "Minimal"
    let primaryColor = Color(red: 0.3, green: 0.3, blue: 0.3)
    let secondaryColor = Color(red: 0.6, green: 0.6, blue: 0.6)
    let backgroundColor = Color(red: 0.99, green: 0.99, blue: 0.99)
    let surfaceColor = Color.white
    let textPrimary = Color(red: 0.2, green: 0.2, blue: 0.2)
    let textSecondary = Color(red: 0.5, green: 0.5, blue: 0.5)
    let accentColor = Color(red: 0.4, green: 0.4, blue: 0.4)
    let successColor = Color(red: 0.4, green: 0.4, blue: 0.4)
    let warningColor = Color(red: 0.6, green: 0.6, blue: 0.6)
    let dangerColor = Color(red: 0.3, green: 0.3, blue: 0.3)
    let cardBackground = Color(red: 0.98, green: 0.98, blue: 0.98)
    let borderColor = Color(red: 0.9, green: 0.9, blue: 0.9)
    let shadowColor = Color.clear
}

struct OceanTheme: AppTheme {
    let name = "Ocean"
    let primaryColor = Color(red: 0.1, green: 0.4, blue: 0.6)
    let secondaryColor = Color(red: 0.2, green: 0.6, blue: 0.8)
    let backgroundColor = Color(red: 0.95, green: 0.98, blue: 1.0)
    let surfaceColor = Color(red: 0.98, green: 0.99, blue: 1.0)
    let textPrimary = Color(red: 0.1, green: 0.2, blue: 0.3)
    let textSecondary = Color(red: 0.3, green: 0.4, blue: 0.5)
    let accentColor = Color(red: 0.0, green: 0.5, blue: 0.7)
    let successColor = Color(red: 0.1, green: 0.6, blue: 0.4)
    let warningColor = Color(red: 0.9, green: 0.6, blue: 0.1)
    let dangerColor = Color(red: 0.8, green: 0.3, blue: 0.3)
    let cardBackground = Color.white
    let borderColor = Color(red: 0.8, green: 0.9, blue: 1.0)
    let shadowColor = Color(red: 0.1, green: 0.4, blue: 0.6).opacity(0.1)
}

struct ForestTheme: AppTheme {
    let name = "Forest"
    let primaryColor = Color(red: 0.2, green: 0.5, blue: 0.3)
    let secondaryColor = Color(red: 0.4, green: 0.7, blue: 0.5)
    let backgroundColor = Color(red: 0.97, green: 0.99, blue: 0.97)
    let surfaceColor = Color(red: 0.99, green: 1.0, blue: 0.99)
    let textPrimary = Color(red: 0.1, green: 0.3, blue: 0.1)
    let textSecondary = Color(red: 0.3, green: 0.5, blue: 0.3)
    let accentColor = Color(red: 0.3, green: 0.6, blue: 0.4)
    let successColor = Color(red: 0.2, green: 0.7, blue: 0.3)
    let warningColor = Color(red: 0.8, green: 0.6, blue: 0.2)
    let dangerColor = Color(red: 0.7, green: 0.3, blue: 0.2)
    let cardBackground = Color.white
    let borderColor = Color(red: 0.8, green: 0.9, blue: 0.8)
    let shadowColor = Color(red: 0.2, green: 0.5, blue: 0.3).opacity(0.1)
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = LightTheme()
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "SelectedTheme"
    
    let availableThemes: [AppTheme] = [
        LightTheme(),
        DarkTheme(),
        ColorfulTheme(),
        MinimalTheme(),
        OceanTheme(),
        ForestTheme()
    ]
    
    init() {
        loadSavedTheme()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        saveTheme(theme.name)
    }
    
    private func loadSavedTheme() {
        let savedThemeName = userDefaults.string(forKey: themeKey) ?? "Light"
        if let theme = availableThemes.first(where: { $0.name == savedThemeName }) {
            currentTheme = theme
        }
    }
    
    private func saveTheme(_ themeName: String) {
        userDefaults.set(themeName, forKey: themeKey)
    }
    
    // Convenience methods for easy access to current theme colors
    var primary: Color { currentTheme.primaryColor }
    var secondary: Color { currentTheme.secondaryColor }
    var background: Color { currentTheme.backgroundColor }
    var surface: Color { currentTheme.surfaceColor }
    var textPrimary: Color { currentTheme.textPrimary }
    var textSecondary: Color { currentTheme.textSecondary }
    var accent: Color { currentTheme.accentColor }
    var success: Color { currentTheme.successColor }
    var warning: Color { currentTheme.warningColor }
    var danger: Color { currentTheme.dangerColor }
    var card: Color { currentTheme.cardBackground }
    var border: Color { currentTheme.borderColor }
    var shadow: Color { currentTheme.shadowColor }
}

// MARK: - Theme Environment Key
struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: ThemeManager = ThemeManager()
}

extension EnvironmentValues {
    var theme: ThemeManager {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}
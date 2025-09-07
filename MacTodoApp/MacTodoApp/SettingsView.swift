import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var integrationManager: IntegrationManager
    @State private var showingThemeSelection = false
    @State private var showingIntegrations = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.textPrimary)
                
                Text("Customize your MacTodoApp experience")
                    .font(.body)
                    .foregroundColor(themeManager.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            
            Divider()
                .background(themeManager.border)
            
            // Tab Selection
            HStack(spacing: 0) {
                Button("Appearance") {
                    selectedTab = 0
                }
                .buttonStyle(.plain)
                .padding()
                .background(selectedTab == 0 ? themeManager.accent : Color.clear)
                .foregroundColor(selectedTab == 0 ? .white : themeManager.textPrimary)
                
                Button("Integrations") {
                    selectedTab = 1
                }
                .buttonStyle(.plain)
                .padding()
                .background(selectedTab == 1 ? themeManager.accent : Color.clear)
                .foregroundColor(selectedTab == 1 ? .white : themeManager.textPrimary)
                
                Spacer()
            }
            
            Divider()
                .background(themeManager.border)
            
            // Tab Content
            Group {
                if selectedTab == 0 {
                    appearanceSettings
                } else {
                    integrationsSettings
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(themeManager.background)
        .frame(width: 800, height: 600)
        .sheet(isPresented: $showingThemeSelection) {
            ThemeSelectionView()
                .environmentObject(themeManager)
        }
    }
    
    private var appearanceSettings: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Theme")
                    .font(.headline)
                    .foregroundColor(themeManager.textPrimary)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Theme")
                            .font(.body)
                            .foregroundColor(themeManager.textPrimary)
                        
                        Text(themeManager.currentTheme.name)
                            .font(.caption)
                            .foregroundColor(themeManager.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button("Change Theme") {
                        showingThemeSelection = true
                    }
                    .buttonStyle(.bordered)
                    .tint(themeManager.accent)
                }
                .padding()
                .background(themeManager.card)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(themeManager.border, lineWidth: 1)
                )
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var integrationsSettings: some View {
        IntegrationSettingsView()
            .environmentObject(integrationManager)
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ThemeManager())
    }
}
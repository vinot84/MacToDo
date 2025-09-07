import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose Your Theme")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(themeManager.textPrimary)
                    
                    Text("Personalize your todo app with beautiful themes")
                        .font(.body)
                        .foregroundColor(themeManager.textSecondary)
                }
                .padding(.horizontal)
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(themeManager.availableThemes, id: \.name) { theme in
                            ThemePreviewCard(
                                theme: theme,
                                isSelected: theme.name == themeManager.currentTheme.name
                            ) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    themeManager.setTheme(theme)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .background(themeManager.background)
            .navigationTitle("Themes")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.accent)
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

struct ThemePreviewCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Theme preview
                VStack(spacing: 8) {
                    // Header preview
                    HStack {
                        Circle()
                            .fill(theme.primaryColor)
                            .frame(width: 8, height: 8)
                        Rectangle()
                            .fill(theme.textPrimary)
                            .frame(height: 3)
                        Spacer()
                    }
                    
                    // Task preview
                    VStack(spacing: 4) {
                        HStack {
                            Circle()
                                .fill(theme.successColor)
                                .frame(width: 6, height: 6)
                            Rectangle()
                                .fill(theme.textSecondary)
                                .frame(height: 2)
                            Spacer()
                        }
                        
                        HStack {
                            Circle()
                                .fill(theme.warningColor)
                                .frame(width: 6, height: 6)
                            Rectangle()
                                .fill(theme.textSecondary)
                                .frame(height: 2)
                            Spacer()
                        }
                        
                        HStack {
                            Circle()
                                .fill(theme.dangerColor)
                                .frame(width: 6, height: 6)
                            Rectangle()
                                .fill(theme.textSecondary)
                                .frame(height: 2)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .padding(12)
                .background(theme.surfaceColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(theme.borderColor, lineWidth: 1)
                )
                
                // Theme name
                Text(theme.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(theme.textPrimary)
            }
            .padding(12)
            .background(theme.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? theme.accentColor : theme.borderColor,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: theme.shadowColor,
                radius: isSelected ? 8 : 4,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Preview
struct ThemeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeSelectionView()
            .environmentObject(ThemeManager())
    }
}
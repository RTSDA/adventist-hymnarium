import SwiftUI

struct ResponsiveReadingView: View {
    let reading: ResponsiveReading
    @StateObject private var readingService = ResponsiveReadingService.shared
    @AppStorage("fontSize") private var fontSize: Double = AppDefaults.defaultFontSize
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.padding) {
                Text(reading.title)
                    .font(AppTheme.standardFont)
                    .foregroundColor(AppTheme.textColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, AppTheme.padding)
                
                if reading.sections.isEmpty {
                    Text(reading.formattedContent)
                        .font(AppTheme.standardFont)
                        .foregroundColor(AppTheme.textColor)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, AppTheme.padding)
                } else {
                    ForEach(reading.sections.sorted(by: { $0.order < $1.order })) { section in
                        SectionView(section: section)
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.backgroundColor)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    readingService.toggleFavorite(for: reading)
                }) {
                    Image(systemName: readingService.isFavorite(reading) ? "heart.fill" : "heart")
                        .foregroundColor(readingService.isFavorite(reading) ? AppTheme.accentColor : AppTheme.textColor)
                }
            }
        }
    }
}

struct SectionView: View {
    let section: ResponsiveReading.Section
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let role = section.role {
                Text(role)
                    .font(AppTheme.standardFont)
                    .foregroundColor(AppTheme.accentColor)
            }
            
            Text(section.content)
                .font(AppTheme.standardFont)
                .foregroundColor(AppTheme.textColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.padding)
    }
}

#Preview {
    NavigationStack {
        ResponsiveReadingView(reading: ResponsiveReading.example)
    }
}

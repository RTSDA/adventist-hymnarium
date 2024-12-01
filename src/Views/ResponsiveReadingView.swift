import SwiftUI

struct ResponsiveReadingView: View {
    let reading: ResponsiveReading
    @StateObject private var readingService = ResponsiveReadingService.shared
    @AppStorage("fontSize") private var fontSize: Double = AppDefaults.defaultFontSize
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                titleView
                
                if reading.sections.isEmpty {
                    Text(reading.formattedContent)
                        .scaledFontSize(fontSize)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .padding(.horizontal)
                } else {
                    ForEach(reading.sections.sorted(by: { $0.order < $1.order })) { section in
                        SectionView(section: section, fontSize: fontSize)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                favoriteButton
            }
        }
    }
    
    private var titleView: some View {
        Text(reading.title)
            .scaledFontSize(fontSize + 4)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom)
    }
    
    private var favoriteButton: some View {
        Button(action: {
            readingService.toggleFavorite(for: reading)
        }) {
            Image(systemName: readingService.isFavorite(reading) ? "heart.fill" : "heart")
                .foregroundColor(readingService.isFavorite(reading) ? .red : .primary)
        }
    }
}

struct SectionView: View {
    let section: ResponsiveReading.Section
    let fontSize: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(sectionTitle)
                    .scaledFontSize(fontSize - 2)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Text(section.formattedContent)
                .scaledFontSize(fontSize)
                .foregroundColor(section.type.textColor)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, section.type == .dark ? 16 : 0)
        }
    }
    
    private var sectionTitle: String {
        switch section.type {
        case .all:
            return "All"
        case .light:
            return "Leader"
        case .dark:
            return "Congregation"
        }
    }
}

#Preview {
    NavigationStack {
        ResponsiveReadingView(reading: ResponsiveReading.example)
    }
}

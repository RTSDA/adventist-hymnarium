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
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, AppTheme.padding)
                
                if reading.sections.isEmpty {
                    Text(reading.formattedContent)
                        .font(.system(size: fontSize))
                        .foregroundColor(AppTheme.textColor)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppTheme.padding)
                } else {
                    ForEach(reading.sections) { section in
                        ReadingSectionView(section: section, fontSize: fontSize)
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.backgroundColor)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    readingService.toggleFavorite(reading)
                } label: {
                    Image(systemName: readingService.isFavorite(reading) ? "heart.fill" : "heart")
                        .foregroundColor(readingService.isFavorite(reading) ? AppTheme.accentColor : AppTheme.textColor)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        if fontSize > AppDefaults.minFontSize {
                            fontSize -= 2
                        }
                    } label: {
                        Label("Decrease Font Size", systemImage: "textformat.size.smaller")
                    }
                    
                    Button {
                        if fontSize < AppDefaults.maxFontSize {
                            fontSize += 2
                        }
                    } label: {
                        Label("Increase Font Size", systemImage: "textformat.size.larger")
                    }
                    
                    Button {
                        fontSize = AppDefaults.defaultFontSize
                    } label: {
                        Label("Reset Font Size", systemImage: "arrow.counterclockwise")
                    }
                } label: {
                    Image(systemName: "textformat.size")
                        .foregroundColor(AppTheme.textColor)
                }
            }
        }
    }
}

struct ReadingSectionView: View {
    let section: ResponsiveReading.Section
    let fontSize: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let role = section.role {
                Text(role)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
            }
            
            Text(section.text)
                .font(.system(size: fontSize))
                .foregroundColor(AppTheme.textColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppTheme.padding)
        .padding(.vertical, 4)
    }
}

struct ResponsiveReadingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ResponsiveReadingView(reading: ResponsiveReading.example)
        }
    }
}

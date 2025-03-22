import SwiftUI

struct ResponsiveReadingView: View {
    let reading: ResponsiveReading
    @StateObject private var readingService = ResponsiveReadingService.shared
    @AppStorage("fontSize") private var fontSize: Double = AppDefaults.defaultFontSize
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                Text(reading.title)
                    .scaledFontSize(fontSize + 4)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if reading.sections.isEmpty {
                    Text(reading.formattedContent)
                        .scaledFontSize(fontSize)
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .padding(.horizontal)
                } else {
                    VStack(alignment: .center, spacing: 24) {
                        ForEach(reading.sections) { section in
                            ReadingSectionView(section: section, fontSize: fontSize)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }
    }
}

struct ReadingSectionView: View {
    let section: ResponsiveReading.Section
    let fontSize: Double
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            if let role = section.role {
                Text(role)
                    .scaledFontSize(fontSize - 2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            Text(section.text)
                .scaledFontSize(fontSize)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

struct ResponsiveReadingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ResponsiveReadingView(reading: ResponsiveReading.example)
        }
    }
}

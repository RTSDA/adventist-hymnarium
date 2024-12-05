import SwiftUI

struct IndexView: View {
    @State private var selectedTab = 0
    @StateObject private var hymnalService = HymnalService.shared
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Index Type", selection: $selectedTab) {
                Text("A-Z").tag(0)
                Text("#").tag(1)
                Text("Categories").tag(2)
                if hymnalService.currentLanguage == .english1985 {
                    Text("Readings").tag(3)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, AppTheme.padding)
            .padding(.vertical, AppTheme.padding)
            .background(Color(uiColor: .systemBackground))
            
            TabView(selection: $selectedTab) {
                AlphabeticalIndexView()
                    .tag(0)
                    .background(Color(uiColor: .systemBackground))
                
                NumericalIndexView()
                    .tag(1)
                    .background(Color(uiColor: .systemBackground))
                
                ThematicIndexContent()
                    .tag(2)
                    .background(Color(uiColor: .systemBackground))
                
                if hymnalService.currentLanguage == .english1985 {
                    ResponsiveReadingsListView()
                        .tag(3)
                        .background(Color(uiColor: .systemBackground))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Adventist Hymnarium")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(uiColor: .systemBackground))
    }
}

struct ResponsiveReadingsListView: View {
    @StateObject private var hymnalService = HymnalService.shared
    @StateObject private var responsiveReadingService = ResponsiveReadingService.shared
    
    var body: some View {
        List {
            ForEach(696...920, id: \.self) { number in
                if let reading = responsiveReadingService.reading(number: number) {
                    NavigationLink {
                        ResponsiveReadingView(reading: reading)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(reading.number). \(reading.title)")
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .task {
            await responsiveReadingService.loadReadings()
        }
    }
}

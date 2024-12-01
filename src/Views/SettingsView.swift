import SwiftUI

struct SettingsView: View {
    @AppStorage("fontSize") private var fontSize: Double = AppDefaults.defaultFontSize
    @AppStorage("showVerseNumbers") private var showVerseNumbers = true
    @AppStorage("selectedHymnal") private var selectedHymnal = HymnalType.current.rawValue
    @AppStorage("keepScreenOn") private var keepScreenOn = true
    @AppStorage("showMiniPlayer") private var showMiniPlayer = true
    @AppStorage("maxRecentHymns") private var maxRecentHymns = 10
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var hymnalService = HymnalService.shared
    @State private var showingHelp = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Hymnal").scaledFont(.subheadline)) {
                    Picker(selection: $selectedHymnal) {
                        ForEach(HymnalType.allCases, id: \.rawValue) { hymnal in
                            Text(hymnal.displayName)
                                .scaledFont(.body)
                                .tag(hymnal.rawValue)
                        }
                    } label: {
                        Text("Selected Hymnal")
                            .scaledFont(.headline)
                    }
                    .onChange(of: selectedHymnal) { oldValue, newValue in
                        let hymnalType = HymnalType(rawValue: newValue) ?? .current
                        let language = hymnalType == .current ? HymnalLanguage.english1985 : HymnalLanguage.english1941
                        Task {
                            await hymnalService.setLanguage(language)
                        }
                    }
                }
                
                Section(header: Text("Display").scaledFont(.subheadline)) {
                    Toggle(isOn: $showVerseNumbers) {
                        Text("Show Verse Numbers")
                            .scaledFont(.headline)
                    }
                    Toggle(isOn: $showMiniPlayer) {
                        Text("Show Mini Player")
                            .scaledFont(.headline)
                    }
                    Toggle(isOn: $keepScreenOn) {
                        Text("Keep Screen On")
                            .scaledFont(.headline)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Font Size")
                            .scaledFont(.headline)
                        Slider(value: $fontSize, in: AppDefaults.minFontSize...AppDefaults.maxFontSize, step: 1)
                        
                        Text("Sample Text")
                            .scaledFontSize(fontSize)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                    }
                }
                
                Section(header: Text("History").scaledFont(.subheadline)) {
                    HStack {
                        Text("Recent Hymns: \(maxRecentHymns)")
                            .scaledFont(.headline)
                        Spacer()
                        Stepper("", value: $maxRecentHymns, in: 5...50, step: 5)
                    }
                    Button {
                        RecentHymnsManager.shared.clearRecentHymns()
                    } label: {
                        Text("Clear Recent Hymns")
                            .scaledFont(.headline)
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("Data").scaledFont(.subheadline)) {
                    Button {
                        FavoritesManager.shared.clearFavorites()
                        ResponsiveReadingService.shared.clearFavorites()
                    } label: {
                        Text("Clear Favorites")
                            .scaledFont(.headline)
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About").scaledFont(.subheadline)) {
                    Button {
                        showingHelp = true
                    } label: {
                        Text("Help")
                            .scaledFont(.headline)
                    }
                    
                    NavigationLink(destination: LegalView()) {
                        Text("Legal Information")
                            .scaledFont(.headline)
                    }
                    
                    HStack {
                        Text("Version")
                            .scaledFont(.headline)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .scaledFont(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Copyright")
                            .scaledFont(.headline)
                        Spacer()
                        Text(selectedHymnal == HymnalType.current.rawValue ? " 1985 Review and Herald" : " 1941 Review and Herald")
                            .scaledFont(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingHelp) {
                NavigationView {
                    HelpView()
                        .navigationTitle("Help")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showingHelp = false
                                }
                            }
                        }
                }
            }
        }
    }
}

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("How to Use")
                    .scaledFont(.title)
                    .padding(.bottom)
                
                VStack(alignment: .leading, spacing: 15) {
                    helpItem(
                        title: "Finding Hymns",
                        description: "Use the number pad to enter a hymn number directly, or use the search feature to find hymns by title or lyrics."
                    )
                    
                    helpItem(
                        title: "Thematic Index",
                        description: "Browse hymns by theme using the Index tab. Hymns are categorized by topic for easy reference."
                    )
                    
                    helpItem(
                        title: "Favorites",
                        description: "Tap the heart icon while viewing a hymn to add it to your favorites for quick access."
                    )
                    
                    helpItem(
                        title: "Settings",
                        description: "Customize font size, verse numbers, and other display preferences to your liking."
                    )
                }
            }
            .padding()
        }
    }
    
    private func helpItem(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .scaledFont(.headline)
            Text(description)
                .scaledFont(.body)
                .foregroundColor(.secondary)
        }
    }
}

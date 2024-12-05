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
    @State private var showFavoritesAlert = false
    @State private var showRecentHymnsAlert = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            let isIPad = horizontalSizeClass == .regular && geometry.size.width > 750
            
            ScrollView {
                VStack(spacing: 20) {
                    if isIPad {
                        // Two-column layout for iPad
                        HStack(alignment: .top, spacing: 20) {
                            // Left column
                            VStack {
                                mainSettingsSection
                                displaySection
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Right column
                            VStack {
                                historySection
                                dataSection
                                aboutSection
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                    } else {
                        // Single column layout for iPhone
                        VStack(spacing: 20) {
                            mainSettingsSection
                            displaySection
                            historySection
                            dataSection
                            aboutSection
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
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
    
    private var mainSettingsSection: some View {
        GroupBox(label: Text("Hymnal").scaledFont(.headline)) {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Selected Hymnal", selection: $selectedHymnal) {
                    ForEach(HymnalType.allCases) { hymnal in
                        Text(hymnal.displayName)
                            .scaledFont(.body)
                            .tag(hymnal.rawValue)
                    }
                }
                .onChange(of: selectedHymnal) { oldValue, newValue in
                    let hymnalType = HymnalType(rawValue: newValue) ?? .current
                    let language = hymnalType == .current ? HymnalLanguage.english1985 : HymnalLanguage.english1941
                    
                    // Save the selected hymnal type
                    UserDefaults.standard.set(hymnalType.rawValue, forKey: "selectedHymnal")
                    
                    // Update the hymnal service language
                    Task {
                        await hymnalService.setLanguage(language)
                    }
                }
            }
            .padding()
        }
    }
    
    private var displaySection: some View {
        GroupBox(label: Text("Display").scaledFont(.headline)) {
            VStack(alignment: .leading, spacing: 16) {
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
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Font Size")
                        .scaledFont(.headline)
                    
                    Slider(value: $fontSize, 
                           in: AppDefaults.minFontSize...AppDefaults.maxFontSize,
                           step: 1)
                    
                    Text("Sample Text")
                        .scaledFontSize(fontSize)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
            }
            .padding()
        }
    }
    
    private var historySection: some View {
        GroupBox(label: Text("History").scaledFont(.headline)) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Recent Hymns: \(maxRecentHymns)")
                        .scaledFont(.headline)
                    Spacer()
                    Stepper("", value: $maxRecentHymns, in: 5...50, step: 5)
                }
                
                Button {
                    showRecentHymnsAlert = true
                } label: {
                    Text("Clear Recent Hymns")
                        .scaledFont(.headline)
                }
                .foregroundColor(.red)
                .alert("Clear Recent Hymns?", isPresented: $showRecentHymnsAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Clear", role: .destructive) {
                        Task {
                            await hymnalService.clearRecentHymns()
                        }
                    }
                } message: {
                    Text("This will remove all hymns from your recent history.")
                }
            }
            .padding()
        }
    }
    
    private var dataSection: some View {
        GroupBox(label: Text("Data").scaledFont(.headline)) {
            VStack(alignment: .leading, spacing: 16) {
                Button {
                    showFavoritesAlert = true
                } label: {
                    Text("Clear Favorites")
                        .scaledFont(.headline)
                }
                .foregroundColor(.red)
                .alert("Clear Favorites?", isPresented: $showFavoritesAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Clear", role: .destructive) {
                        Task {
                            await FavoritesManager.shared.clearFavorites()
                            await ResponsiveReadingService.shared.clearFavorites()
                        }
                    }
                } message: {
                    Text("This will remove all hymns and readings from your favorites.")
                }
            }
            .padding()
        }
    }
    
    private var aboutSection: some View {
        GroupBox(label: Text("About").scaledFont(.headline)) {
            VStack(alignment: .leading, spacing: 16) {
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
            .padding()
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

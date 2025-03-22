import SwiftUI
import AVFoundation

struct HymnDetailView: View {
    @StateObject private var hymnalService = HymnalService.shared
    @StateObject private var audioService = AudioService.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var responsiveReadingService = ResponsiveReadingService.shared
    @StateObject private var favoritesManager = FavoritesManager.shared
    @Environment(\.dismiss) private var dismiss
    let hymn: Hymn
    @State private var isFavorite = false
    @AppStorage("fontSize") private var fontSize: Double = AppDefaults.defaultFontSize
    @AppStorage("showVerseNumbers") private var showVerseNumbers = true
    @State private var showNowPlaying = false
    
    private var isPlaying: Bool {
        let isCurrentHymn = audioService.currentHymnNumber == hymn.number
        return isCurrentHymn && audioService.isPlaying
    }
    
    private var isCurrentHymnal: Bool {
        hymnalService.currentLanguage == .english1985
    }
    
    private var isResponsiveReading: Bool {
        hymnalService.isReadingNumber(hymn.number)
    }
    
    private var reading: ResponsiveReading? {
        guard isResponsiveReading else { return nil }
        return responsiveReadingService.reading(number: hymn.number)
    }
    
    var body: some View {
        mainContent
            .safeAreaInset(edge: .bottom) {
                miniPlayer
            }
            .navigationBarTitle("# \(hymn.number)", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarButtons
                }
            }
            .onAppear {
                setupInitialState()
                hymnalService.addToRecentHymns(hymn.number)
            }
            .onChange(of: hymnalService.currentLanguage) { oldValue, newValue in
                // Dismiss view when hymnal type changes
                dismiss()
            }
            .task {
                await hymnalService.refreshData()
                if isResponsiveReading {
                    await responsiveReadingService.loadReadings()
                }
            }
            .sheet(isPresented: $showNowPlaying) {
                NowPlayingView()
            }
            .accentColor(themeManager.accentColor)
    }
    
    private var mainContent: some View {
        Group {
            if let reading = reading {
                ResponsiveReadingView(reading: reading)
            } else {
                HymnContentView(hymn: hymn)
            }
        }
    }
    
    private var miniPlayer: some View {
        Group {
            if audioService.currentHymnNumber != nil {
                MiniPlayerView()
                    .background(Color(UIColor.systemBackground))
                    .overlay(alignment: .bottom) {
                        Divider()
                    }
            }
        }
    }
    
    private var toolbarButtons: some View {
        HStack(spacing: 16) {
            if isCurrentHymnal && !isResponsiveReading {
                NavigationLink(destination: SheetMusicView(hymn: hymn)) {
                    Image(systemName: "music.note.list")
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            if !isResponsiveReading {
                Button(action: {
                    Task {
                        if isPlaying {
                            showNowPlaying = true
                        } else {
                            try? await audioService.loadAndPlay(hymnNumber: hymn.number)
                        }
                    }
                }) {
                    Image(systemName: isPlaying ? "music.note" : "play.circle")
                        .imageScale(.large)
                }
            }
            
            Button {
                toggleFavorite()
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
            }
        }
    }
    
    private func setupInitialState() {
        if isResponsiveReading {
            isFavorite = responsiveReadingService.favoriteReadings.contains(hymn.number)
        } else {
            isFavorite = favoritesManager.isFavorite(hymn.number)
        }
    }
    
    private func toggleFavorite() {
        isFavorite.toggle()
        if isResponsiveReading {
            if let reading = reading {
                Task {
                     responsiveReadingService.toggleFavorite(reading)
                }
            }
        } else {
            favoritesManager.toggleFavorite(hymn.number)
        }
    }
}

private struct HymnContentView: View {
    let hymn: Hymn
    @AppStorage("fontSize") private var fontSize: Double = AppDefaults.defaultFontSize
    @AppStorage("showVerseNumbers") private var showVerseNumbers = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                Text(hymn.title)
                    .scaledFontSize(fontSize + 4)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .center, spacing: 24) {
                    ForEach(hymn.parsedVerses) { verse in
                        VerseView(
                            verse: verse,
                            showNumber: showVerseNumbers,
                            fontSize: fontSize
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct VerseView: View {
    let verse: Verse
    let showNumber: Bool
    let fontSize: Double
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            if showNumber {
                if verse.isChorus {
                    Text("Chorus")
                        .scaledFontSize(fontSize - 2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                } else if let label = verse.label {
                    Text(label)
                        .scaledFontSize(fontSize - 2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                } else {
                    Text("Verse \(verse.number)")
                        .scaledFontSize(fontSize - 2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(verse.text)
                .scaledFontSize(fontSize)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        HymnDetailView(hymn: .example)
    }
}

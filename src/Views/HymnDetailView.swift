import SwiftUI
import AVFoundation

struct HymnDetailView: View {
    @StateObject private var hymnalService = HymnalService.shared
    @StateObject private var audioService = AudioService.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var responsiveReadingService = ResponsiveReadingService.shared
    @StateObject private var favoritesManager = FavoritesManager.shared
    let hymn: Hymn
    @State private var isFavorite = false
    @AppStorage("fontSize") private var fontSize: Double = AppDefaults.defaultFontSize
    @AppStorage("showVerseNumbers") private var showVerseNumbers = true
    @Environment(\.presentationMode) var presentationMode
    @State private var showNowPlaying = false
    
    private var isPlaying: Bool {
        audioService.currentHymnNumber == hymn.number && audioService.isPlaying
    }
    
    private var isCurrentHymnal: Bool {
        hymnalService.currentLanguage == .english1985
    }
    
    private var isResponsiveReading: Bool {
        hymnalService.isReadingNumber(hymn.number)
    }
    
    var body: some View {
        Group {
            if isResponsiveReading,
               let reading = responsiveReadingService.reading(for: hymn.number) {
                ResponsiveReadingView(reading: reading)
            } else {
                HymnContentView(hymn: hymn)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if audioService.currentHymnNumber != nil {
                MiniPlayerView()
                    .background(Color(UIColor.systemBackground))
                    .overlay(alignment: .bottom) {
                        Divider()
                    }
            }
        }
        .navigationBarTitle("# \(hymn.number)", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !isResponsiveReading {
                    Button(action: {
                        Task {
                            if isPlaying {
                                audioService.stop()
                            } else {
                                await audioService.loadAndPlay(hymnNumber: hymn.number)
                            }
                        }
                    }) {
                        Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                            .imageScale(.large)
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    if audioService.isPlaying && audioService.currentHymnNumber == hymn.number {
                        Button {
                            showNowPlaying = true
                        } label: {
                            Image(systemName: "music.note")
                        }
                    }
                    
                    Button {
                        isFavorite.toggle()
                        if isResponsiveReading {
                            if let reading = responsiveReadingService.reading(for: hymn.number) {
                                Task {
                                    await responsiveReadingService.toggleFavorite(for: reading)
                                }
                            }
                        } else {
                            favoritesManager.toggleFavorite(hymn.number)
                        }
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if isCurrentHymnal && !isResponsiveReading {
                    NavigationLink(destination: SheetMusicView(hymn: hymn)) {
                        Image(systemName: "music.note.list")
                            .foregroundColor(themeManager.accentColor)
                    }
                }
            }
        }
        .onAppear {
            if isResponsiveReading {
                isFavorite = responsiveReadingService.favoriteReadings.contains(hymn.number)
            } else {
                isFavorite = favoritesManager.favorites.contains(hymn.number)
            }
            hymnalService.recentHymnsManager.addRecentHymn(hymn.number)
        }
        .task {
            await hymnalService.updateRecentHymns()
            if isResponsiveReading {
                await responsiveReadingService.loadReadings()
            }
        }
        .sheet(isPresented: $showNowPlaying) {
            NowPlayingView()
        }
        .accentColor(themeManager.accentColor)
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

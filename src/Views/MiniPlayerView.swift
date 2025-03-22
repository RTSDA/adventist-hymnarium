import SwiftUI
import AVFoundation

struct MiniPlayerView: View {
    @ObservedObject private var audioService = AudioService.shared
    @ObservedObject private var hymnalService = HymnalService.shared
    @State private var showNowPlaying = false
    @State private var offset: CGFloat = 0
    
    var body: some View {
        if let currentHymnNumber = audioService.currentHymnNumber,
           let hymn = HymnalService.shared.hymn(number: currentHymnNumber) {
            HStack(spacing: 16) {
                // Title and number - tappable to show now playing
                Button {
                    showNowPlaying = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(hymn.number). \(hymn.title)")
                                .scaledFont(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            if let firstVerse = hymn.verses.first {
                                Text(firstVerse)
                                    .scaledFont(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Play/Pause button
                Button {
                    Task {
                        if audioService.isPlaying {
                            audioService.pause()
                        } else {
                            try? await audioService.play()
                        }
                    }
                } label: {
                    Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                        .frame(width: 44, height: 44)
                }
                
                // Close button
                Button {
                    Task {
                        await audioService.stop()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal)
            .frame(height: 56)
            .sheet(isPresented: $showNowPlaying) {
                NowPlayingView()
            }
            .onChange(of: hymnalService.currentLanguage) { oldValue, newValue in
                // Stop playback when hymnal type changes
                Task {
                    await audioService.stop()
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation.width
                    }
                    .onEnded { value in
                        if value.translation.width > 50 {
                            Task {
                                await audioService.stop()
                            }
                        }
                        offset = 0
                    }
            )
            .offset(x: offset)
            .animation(.spring(), value: offset)
        }
    }
}

#Preview {
    MiniPlayerView()
}

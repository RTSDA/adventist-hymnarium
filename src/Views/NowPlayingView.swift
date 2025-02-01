import SwiftUI
import AVFoundation

struct NowPlayingView: View {
    @ObservedObject private var audioService = AudioService.shared
    @ObservedObject private var hymnalService = HymnalService.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let currentHymnNumber = audioService.currentHymnNumber,
                   let hymn = HymnalService.shared.hymn(number: currentHymnNumber) {
                    // Hymn info
                    VStack(spacing: 16) {
                        Text("\(hymn.number). \(hymn.title)")
                            .scaledFont(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    // Lyrics
                    LyricsView(hymn: hymn)
                    
                    // Progress bar
                    if audioService.duration > 0 {
                        VStack {
                            Slider(value: .init(
                                get: { audioService.currentTime },
                                set: { newTime in
                                    Task {
                                        await audioService.seek(to: newTime)
                                    }
                                }
                            ), in: 0...audioService.duration)
                            
                            HStack {
                                Text(formatTime(audioService.currentTime))
                                    .scaledFont(.caption)
                                Spacer()
                                Text(formatTime(audioService.duration))
                                    .scaledFont(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Playback controls
                    HStack(spacing: 40) {
                        Button(action: {
                            Task {
                                if audioService.isPlaying {
                                    await audioService.pause()
                                } else {
                                    try? await audioService.play()
                                }
                            }
                        }) {
                            Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .padding(.vertical)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: hymnalService.currentLanguage) { oldValue, NewValue in
            // Dismiss when hymnal type changes
            dismiss()
        }
        .onAppear {
            // Set up completion handler to dismiss when playback ends
            audioService.setCompletionHandler {
                dismiss()
            }
        }
        .onDisappear {
            // Clean up completion handler
            audioService.clearCompletionHandler()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    NowPlayingView()
}

import SwiftUI
import AVFoundation

struct NowPlayingView: View {
    @ObservedObject private var audioService = AudioService.shared
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
                        
                        if let firstVerse = hymn.verses.first {
                            Text(firstVerse)
                                .scaledFont(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Progress bar
                    if let player = audioService.player {
                        VStack {
                            Slider(value: .init(
                                get: { player.currentTime },
                                set: { audioService.seek(to: $0) }
                            ), in: 0...player.duration)
                            
                            HStack {
                                Text(formatTime(player.currentTime))
                                    .scaledFont(.caption)
                                Spacer()
                                Text(formatTime(player.duration))
                                    .scaledFont(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Playback controls
                    HStack(spacing: 40) {
                        Button(action: {
                            audioService.pause()
                        }) {
                            Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .padding(.vertical)
            .navigationBarTitleDisplayMode(.inline)
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

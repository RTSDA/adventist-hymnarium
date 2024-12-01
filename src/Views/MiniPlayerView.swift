import SwiftUI
import AVFoundation

struct MiniPlayerView: View {
    @ObservedObject private var audioService = AudioService.shared
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
                    if audioService.isPlaying {
                        audioService.pause()
                    } else {
                        audioService.resumePlayback()
                    }
                } label: {
                    Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                        .frame(width: 44, height: 44)
                }
                
                // Close button
                Button {
                    audioService.stop()
                } label: {
                    Image(systemName: "xmark")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .contentShape(Rectangle()) // Make entire area tappable
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Only allow horizontal drag
                        offset = value.translation.width
                    }
                    .onEnded { value in
                        let width = UIScreen.main.bounds.width
                        let dragPercentage = abs(value.translation.width / width)
                        let velocity = abs(value.velocity.width)
                        
                        // Dismiss if dragged more than 30% of the way or with high velocity
                        if dragPercentage > 0.3 || velocity > 800 {
                            withAnimation(.easeOut(duration: 0.2)) {
                                // Determine direction and animate accordingly
                                offset = value.translation.width > 0 ? width : -width
                            }
                            // Stop playback after animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                audioService.stop()
                            }
                        } else {
                            // Reset position if not dismissed
                            withAnimation(.easeOut(duration: 0.2)) {
                                offset = 0
                            }
                        }
                    }
            )
            .sheet(isPresented: $showNowPlaying) {
                NowPlayingView()
            }
        }
    }
}

#Preview {
    MiniPlayerView()
}

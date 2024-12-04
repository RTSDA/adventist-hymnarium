import SwiftUI

struct PlaybackButton: View {
    let isPlaying: Bool
    let action: () -> Void
    @StateObject private var audioService = AudioService.shared
    
    var body: some View {
        Button(action: {
            if isPlaying {
                Task {
                    await audioService.stop()
                }
            } else {
                action()
            }
        }) {
            Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                .imageScale(.large)
        }
    }
}

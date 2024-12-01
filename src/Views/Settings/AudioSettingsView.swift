import SwiftUI

struct AudioSettingsView: View {
    @StateObject private var audioService = AudioService.shared
    @State private var isDownloading = false
    @State private var showingDownloadAlert = false
    @State private var showingClearAlert = false
    @State private var downloadStart: Int = 1
    @State private var downloadEnd: Int = 2
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Downloaded Audio")
                    Spacer()
                    Text(formatFileSize(audioService.getDownloadedAudioSize()))
                        .foregroundColor(.secondary)
                }
                
                if audioService.isDownloading {
                    VStack(alignment: .leading) {
                        Text("Downloading...")
                            .foregroundColor(.secondary)
                        ProgressView(value: audioService.downloadProgress)
                            .progressViewStyle(.linear)
                    }
                } else {
                    Button(action: { showingDownloadAlert = true }) {
                        Label("Download Hymns", systemImage: "arrow.down.circle")
                    }
                    
                    Button(action: { showingClearAlert = true }) {
                        Label("Clear Downloads", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
            } header: {
                Text("Offline Access")
            } footer: {
                Text("Download hymns for offline playback. Downloaded audio will be available when you don't have an internet connection.")
            }
        }
        .navigationTitle("Audio Settings")
        .alert("Download Hymns", isPresented: $showingDownloadAlert) {
            TextField("Start Number", value: $downloadStart, format: .number)
            TextField("End Number", value: $downloadEnd, format: .number)
            Button("Cancel", role: .cancel) { }
            Button("Download") {
                Task {
                    let downloadRange = downloadStart...downloadEnd
                    await audioService.downloadHymnsForOfflineUse(range: downloadRange)
                }
            }
        } message: {
            Text("Enter the range of hymn numbers to download")
        }
        .alert("Clear Downloads", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                audioService.clearDownloadedAudio()
            }
        } message: {
            Text("Are you sure you want to delete all downloaded hymn audio? This cannot be undone.")
        }
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

#Preview {
    NavigationView {
        AudioSettingsView()
    }
}

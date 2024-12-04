import SwiftUI

struct AudioSettingsView: View {
    @StateObject private var audioService = AudioService.shared
    @State private var showingDownloadAlert = false
    @State private var downloadStart: Int = 1
    @State private var downloadEnd: Int = 2
    @State private var isDownloading = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Cloud Storage")
                    Spacer()
                    Text("Using Cloudflare R2")
                        .foregroundColor(.secondary)
                }
                
                if isDownloading {
                    VStack(alignment: .leading) {
                        Text("Downloading...")
                            .foregroundColor(.secondary)
                        ProgressView()
                            .progressViewStyle(.linear)
                    }
                } else {
                    Button(action: { showingDownloadAlert = true }) {
                        Label("Cache Hymns", systemImage: "arrow.down.circle")
                    }
                }
            } header: {
                Text("Storage")
            } footer: {
                Text("Hymn audio is stored in the cloud and streamed when playing. You can cache hymns for faster playback.")
            }
        }
        .navigationTitle("Audio Settings")
        .alert("Cache Hymns", isPresented: $showingDownloadAlert) {
            TextField("Start Number", value: $downloadStart, format: .number)
            TextField("End Number", value: $downloadEnd, format: .number)
            Button("Cancel", role: .cancel) { }
            Button("Download") {
                Task {
                    isDownloading = true
                    for number in downloadStart...downloadEnd {
                        do {
                            try await audioService.loadAndPlay(hymnNumber: number)
                            await audioService.stop()
                        } catch {
                            print("Failed to cache hymn \(number): \(error)")
                        }
                    }
                    isDownloading = false
                }
            }
        } message: {
            Text("Enter the range of hymn numbers to cache locally")
        }
    }
}

struct AudioSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AudioSettingsView()
        }
    }
}

import Foundation
import AVFoundation
import MediaPlayer
import Combine
import UIKit

class AudioService: NSObject, ObservableObject {
    static let shared = AudioService()
    
    @Published private(set) var player: AVAudioPlayer?
    @Published private(set) var isPlaying = false
    @Published private(set) var currentHymnNumber: Int?
    @Published private(set) var audioAvailable = false
    @Published private(set) var isLoading = false
    @Published private(set) var isDownloading = false
    @Published private(set) var downloadProgress: Float = 0
    
    private var hymnalService = HymnalService.shared
    private var downloadTask: URLSessionDataTask?
    private var cancellables = Set<AnyCancellable>()
    
    private let fileManager = FileManager.default
    
    override private init() {
        super.init()
        setupAudioSession()
        setupHymnalServiceObserver()
        setupRemoteCommandCenter()
    }
    
    private func setupHymnalServiceObserver() {
        hymnalService.$currentLanguage
            .sink { [weak self] _ in
                // Stop current playback when language changes
                self?.stop()
            }
            .store(in: &cancellables)
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Configure basic playback that should work in silent mode
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Remove all previous targets
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.removeTarget(nil)
        commandCenter.stopCommand.removeTarget(nil)
        commandCenter.changePlaybackPositionCommand.removeTarget(nil)
        
        // Enable commands
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.stopCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        
        // Add handlers
        commandCenter.playCommand.addTarget { [weak self] _ in
            if let currentHymn = self?.currentHymnNumber {
                self?.play(hymnNumber: currentHymn)
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            if let self = self {
                if self.isPlaying {
                    self.pause()
                } else if let currentHymn = self.currentHymnNumber {
                    self.play(hymnNumber: currentHymn)
                }
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.stopCommand.addTarget { [weak self] _ in
            self?.stop()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self?.seek(to: event.positionTime)
                return .success
            }
            return .commandFailed
        }
    }
    
    func updateNowPlaying() {
        guard let player = player,
              let currentHymnNumber = currentHymnNumber,
              let hymn = hymnalService.hymn(number: currentHymnNumber) else { return }
        
        var nowPlayingInfo = [String: Any]()
        
        // Set title and first verse
        nowPlayingInfo[MPMediaItemPropertyTitle] = "\(hymn.number). \(hymn.title)"
        if let firstVerse = hymn.verses.first {
            nowPlayingInfo[MPMediaItemPropertyArtist] = firstVerse
        }
        
        // Add duration and current time
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        
        // Add playback rate
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Set the artwork if available
        if let image = UIImage(named: "AppIcon") {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func getFileSize(at url: URL) -> Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64
        } catch {
            print("Error getting file size: \(error)")
            return nil
        }
    }

    private func getLocalAudioPath(hymnNumber: Int, language: HymnalLanguage) -> URL? {
        // Format the number with leading zeros
        let formattedNumber = String(format: "%03d", hymnNumber)
        let fileName = language.year == 1941 ? formattedNumber : "en_\(formattedNumber)"
        let yearDir = language.year == 1941 ? "1941" : "1985"
        
        // Print bundle URL for debugging
        if let bundleURL = Bundle.main.resourceURL {
            print("Bundle URL: \(bundleURL.path)")
        }
        
        // First, try the full path (most specific)
        let fullPath = "Resources/Assets/Audio/\(yearDir)"
        if let path = Bundle.main.path(forResource: fileName, ofType: "mp3", inDirectory: fullPath) {
            print("Found audio file in full path: \(path)")
            return URL(fileURLWithPath: path)
        }
        
        // Next, try in the year-specific directory
        if let path = Bundle.main.path(forResource: fileName, ofType: "mp3", inDirectory: yearDir) {
            print("Found audio file in year directory: \(path)")
            return URL(fileURLWithPath: path)
        }
        
        // Finally, try to find the file directly (least specific)
        if let path = Bundle.main.path(forResource: fileName, ofType: "mp3") {
            print("Found audio file at root: \(path)")
            return URL(fileURLWithPath: path)
        }
        
        // Log the attempted paths for debugging
        print("Could not find \(fileName).mp3")
        print("Attempted paths:")
        print("1. /\(fullPath)")
        print("2. /\(yearDir)")
        print("3. Root bundle")
        
        return nil
    }
    
    func play(hymnNumber: Int) {
        // If the same hymn is paused, resume playback
        if hymnNumber == currentHymnNumber, let player = player, !player.isPlaying {
            resumePlayback()
            return
        }
        
        guard let url = getLocalAudioPath(hymnNumber: hymnNumber, language: hymnalService.currentLanguage) else {
            print("Could not find audio file for hymn \(hymnNumber)")
            return
        }
        
        do {
            // Stop any currently playing audio
            if let player = player {
                player.stop()
                self.player = nil
            }
            
            // Create and configure new audio player
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            
            // Set volume and prepare audio
            player?.volume = 1.0
            
            // Update UI state
            DispatchQueue.main.async {
                self.currentHymnNumber = hymnNumber
                self.audioAvailable = true
                self.isPlaying = true
                self.updateNowPlaying()
            }
            
            // Start playback
            if let player = player, player.play() {
                print("Started playing audio from: \(url.path)")
            } else {
                print("Failed to start playback")
            }
        } catch {
            print("Error playing audio: \(error)")
            DispatchQueue.main.async {
                self.isPlaying = false
                self.audioAvailable = false
                self.currentHymnNumber = nil
                self.updateNowPlaying()
            }
        }
    }
    
    func pause() {
        player?.pause()
        DispatchQueue.main.async {
            self.isPlaying = false
            self.updateNowPlaying()
        }
    }
    
    public func resumePlayback() {
        player?.play()
        DispatchQueue.main.async {
            self.isPlaying = true
            self.updateNowPlaying()
        }
    }
    
    func stop() {
        player?.stop()
        player?.currentTime = 0
        player = nil
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentHymnNumber = nil
            self.audioAvailable = false
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        }
    }
    
    public func loadAndPlay(hymnNumber: Int) async {
        guard hymnNumber != currentHymnNumber || !isPlaying else {
            print("Hymn \(hymnNumber) is already playing.")
            stop()
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
            self.audioAvailable = false
        }

        downloadTask?.cancel()

        let language = hymnalService.currentLanguage
        print("Attempting to load hymn \(hymnNumber) for language \(language.id)")

        if let localUrl = getLocalAudioPath(hymnNumber: hymnNumber, language: language) {
            print("Constructed file path: \(localUrl.path)")
            do {
                let attributes = try fileManager.attributesOfItem(atPath: localUrl.path)
                print("File attributes: \(attributes)")
            } catch {
                print("Error retrieving file attributes: \(error)")
            }
            print("Checking existence of file at path: \(localUrl.path)")
            if fileManager.fileExists(atPath: localUrl.path) {
                print("File exists: \(localUrl.path)")
                do {
                    let data = try Data(contentsOf: localUrl)
                    try await loadAndPlayAudio(from: data, hymnNumber: hymnNumber)
                    print("Successfully loaded and playing hymn \(hymnNumber)")
                    return
                } catch {
                    print("Error loading local audio: \(error)")
                }
            } else {
                print("File does not exist at path: \(localUrl.path)")
            }
        }

        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
    
    private func loadAndPlayAudio(from data: Data, hymnNumber: Int) async throws {
        player = try AVAudioPlayer(data: data)
        player?.delegate = self
        
        guard let player = player, player.prepareToPlay() else {
            throw NSError(domain: "AudioService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare audio player"])
        }
        
        DispatchQueue.main.async {
            self.currentHymnNumber = hymnNumber
            self.audioAvailable = true
            self.isLoading = false
            self.isPlaying = true
        }
        player.play()
    }
    
    // Download a range of hymns for offline use
    func downloadHymnsForOfflineUse(range: ClosedRange<Int>) async {
        // This function will be left empty since we're not downloading any files.
    }
    
    // Get the size of downloaded audio files
    func getDownloadedAudioSize() -> Int64 {
        guard let audioDir = getLocalAudioPath(hymnNumber: 1, language: hymnalService.currentLanguage)?.deletingLastPathComponent() else { return 0 }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: audioDir, includingPropertiesForKeys: [.fileSizeKey])
            return try contents.reduce(0) { total, url in
                let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
                return total + Int64(resourceValues.fileSize ?? 0)
            }
        } catch {
            print("Error calculating audio size: \(error)")
            return 0
        }
    }
    
    // Clear all downloaded audio files
    func clearDownloadedAudio() {
        // This function will be left empty since we're not writing any files.
    }
    
    func seekForward() {
        guard let player = player else { return }
        seek(to: player.currentTime + 10)
    }
    
    func seekBackward() {
        guard let player = player else { return }
        seek(to: player.currentTime - 10)
    }
    
    func seek(to time: TimeInterval) {
        player?.currentTime = max(0, min(time, player?.duration ?? 0))
        updateNowPlaying()
    }
}

extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.updateNowPlaying()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.audioAvailable = false
            if let error = error {
                print("Audio decode error: \(error)")
            }
        }
    }
}

//
//  AudioService.swift
//  SDA HymnalApp
//
//  Created by Benjamin Slingo on 12/3/24.
//

import Foundation
import AVFoundation
import MediaPlayer
import Combine
import UIKit

@MainActor
final class AudioService: NSObject, ObservableObject, @unchecked Sendable {
    // MARK: - Singleton
    
    static let shared = AudioService()
    
    // MARK: - Properties
    
    @Published private(set) var isLoading = false
    @Published private(set) var currentHymnNumber: Int?
    @Published private(set) var audioAvailable = false
    @Published private(set) var error: Error?
    
    private var player: AVPlayer?
    private var timeObserver: Any?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isPlaying: Bool = false
    
    private let Storage = StorageService.shared
    private let cacheService = CacheService.shared
    private let cacheDirectory = "audio_cache"
    private let maxCacheSize: Int64 = 100 * 1024 * 1024  // 100 MB
    private let hymnalService = HymnalService.shared
    
    private let fileManager = FileManager.default
    
    private var completionHandler: (() -> Void)?
    
    // MARK: - Initialization
    
    @MainActor
    override private init() {
        super.init()
        setupAudioSession()
        setupHymnalServiceObserver()
        setupRemoteCommandCenter()
        
        // Trim cache if needed when app starts
        cacheService.trimCacheIfNeeded(inDirectory: cacheDirectory, maxSize: maxCacheSize)
    }
    
    // MARK: - Remote Command Center
    
    @MainActor
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            if self.currentHymnNumber != nil {
                Task {
                    try? await self.play()
                }
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            Task {
                self.pause()
            }
            return .success
        }
        
        commandCenter.stopCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            Task {
                await self.stop()
            }
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            Task {
                if self.isPlaying {
                    self.pause()
                } else if self.currentHymnNumber != nil {
                    try? await self.play()
                }
            }
            return .success
        }
    }
    
    // MARK: - Audio Control
    
    @MainActor
    func play() async throws {
        if let player = player {
            player.play()
            isPlaying = true
            updateNowPlaying()
        } else if let number = currentHymnNumber {
            try await loadAndPlay(hymnNumber: number)
        }
    }
    
    @MainActor
    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlaying()
    }
    
    @MainActor
    func stop() async {
        player?.pause()
        await player?.seek(to: .zero)
        player = nil
        isPlaying = false
        currentHymnNumber = nil
        audioAvailable = false
        currentTime = 0
        duration = 0
        updateNowPlaying()
    }
    
    @MainActor
    public func loadAndPlay(hymnNumber: Int) async throws {
        // Stop any current playback
        await stop()
        
        isLoading = true
        error = nil
        
        do {
            let numberString = String(format: "%03d", hymnNumber)
            let isOldHymnal = hymnalService.currentLanguage == .english1941
            
            // For 1941 hymnal: audio/1985/1941/xxx.mp3
            // For 1985 hymnal: audio/1985/1985/en_xxx.mp3
            let filename = isOldHymnal 
                ? "audio/1941/\(numberString).mp3"
                : "audio/1985/en_\(numberString).mp3"
            
            let cacheKey = isOldHymnal 
                ? "1941_\(numberString).mp3"
                : "1985_\(numberString).mp3"
            
            let audioData: Data
            
            // Try to get from cache first
            if let cachedData = try? cacheService.retrieve(forKey: cacheKey, fromDirectory: cacheDirectory) {
                audioData = cachedData
                print("Using cached audio data for hymn \(hymnNumber) in \(isOldHymnal ? "1941" : "1985") hymnal")
            } else {
                // Download from R2 if not in cache
                audioData = try await Storage.downloadAsset(path: filename)
                print("Downloaded audio data size: \(audioData.count) bytes")
                
                // Store in cache
                try? cacheService.store(audioData, forKey: cacheKey, inDirectory: cacheDirectory)
            }
            
            // Create a temporary file for AVAudioPlayer
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp3")
            try audioData.write(to: tempURL)
            
            // Initialize audio player
            let playerItem = AVPlayerItem(url: tempURL)
            
            // Observe player item status
            var observation: NSKeyValueObservation?
            observation = playerItem.observe(\.status) { [weak self] item, _ in
                Task { @MainActor in
                    if item.status == .readyToPlay {
                        self?.duration = item.duration.seconds
                        observation?.invalidate()
                    }
                }
            }
            
            player = AVPlayer(playerItem: playerItem)
            
            // Add completion observer
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: playerItem,
                queue: .main
            ) { [weak self] _ in
                Task { @MainActor in
                    self?.isPlaying = false
                    // Clean up temporary file
                    if let urlAsset = playerItem.asset as? AVURLAsset {
                        try? FileManager.default.removeItem(at: urlAsset.url)
                    }
                    self?.currentHymnNumber = nil
                    self?.updateNowPlaying()
                    self?.completionHandler?()
                }
            }
            
            player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main) { [weak self] time in
                Task { @MainActor in
                    self?.currentTime = time.seconds
                    self?.updateNowPlaying()
                }
            }
            
            currentHymnNumber = hymnNumber
            audioAvailable = true
            isLoading = false
            
            // Start playing
            try await play()
            
        } catch {
            isLoading = false
            self.error = error
            audioAvailable = false
            throw error
        }
    }
    
    @MainActor
    func seek(to time: TimeInterval) async {
        await player?.seek(to: CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        updateNowPlaying()
    }
    
    // MARK: - Audio Session
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Observe audio session interruptions
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAudioSessionInterruption),
                name: AVAudioSession.interruptionNotification,
                object: nil
            )
            
            // Observe audio route changes (e.g., headphones disconnected)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAudioRouteChange),
                name: AVAudioSession.routeChangeNotification,
                object: nil
            )
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        Task { @MainActor in
            switch type {
            case .began:
                // Audio was interrupted (e.g., by a phone call or another app)
                pause()
                
            case .ended:
                // Interruption ended
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        // Only auto-resume if the interruption options indicate we should
                        try? await play()
                    }
                }
                
            @unknown default:
                break
            }
        }
    }
    
    @objc private func handleAudioRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        Task { @MainActor in
            switch reason {
            case .oldDeviceUnavailable:
                // For example, headphones were unplugged
                pause()
            default:
                break
            }
        }
    }
    
    // MARK: - Now Playing Info
    
    @MainActor
    private func updateNowPlaying() {
        guard let hymnNumber = currentHymnNumber else { return }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Hymn \(hymnNumber)"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Adventist Hymnal"
        
        if let player = player {
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.duration.seconds ?? 0
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - Hymnal Service Observer
    
    private func setupHymnalServiceObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleHymnalServiceNotification(_:)),
            name: Notification.Name("HymnalServiceDidUpdateHymn"),
            object: nil
        )
    }
    
    @objc private func handleHymnalServiceNotification(_ notification: Notification) {
        guard let hymnNumber = notification.userInfo?["hymnNumber"] as? Int else { return }
        
        // If hymnal type changed
        if let oldHymnalType = notification.userInfo?["oldHymnalType"] as? Bool,
           let newHymnalType = notification.userInfo?["newHymnalType"] as? Bool,
           oldHymnalType != newHymnalType {
            Task { @MainActor in
                // Stop any playback and reset
                await stop()
            }
            return
        }
        
        // Only auto-play if it's just a hymn number change
        Task {
            try? await loadAndPlay(hymnNumber: hymnNumber)
        }
    }
    
    // MARK: - Completion Handler
    
    @MainActor
    func setCompletionHandler(_ handler: @escaping () -> Void) {
        completionHandler = handler
    }
    
    @MainActor
    func clearCompletionHandler() {
        completionHandler = nil
    }
}

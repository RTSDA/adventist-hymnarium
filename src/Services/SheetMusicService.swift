//
//  SheetMusicService.swift
//  SDA HymnalApp
//
//  Created by Benjamin Slingo on 12/3/24.
//

import Foundation
import UIKit
import Combine

// Wrapper class for caching arrays of UIImage
final class ImageContainer {
    let images: [UIImage]
    
    init(images: [UIImage]) {
        self.images = images
    }
}

final class SheetMusicService: ObservableObject {
    static let shared = SheetMusicService()
    
    @Published private(set) var currentSheetMusic: [UIImage]?
    @Published private(set) var currentHymnKey: Int?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let cacheService = CacheService.shared
    private let cloudStorage = CloudStorageService.shared
    private let cacheDirectory = "sheet-music"
    private let maxCacheSize: Int64 = 200 * 1024 * 1024  // 200MB limit for sheet music
    
    private init() {
        // Trim cache if needed when app starts
        cacheService.trimCacheIfNeeded(inDirectory: cacheDirectory, maxSize: maxCacheSize)
    }
    
    @MainActor
    func getSheetMusic(for hymnNumber: Int) async throws -> [UIImage]? {
        // If we're already showing this hymn, return it
        if let existingImages = currentSheetMusic,
           let currentKey = currentHymnKey,
           currentKey == hymnNumber {
            return existingImages
        }
        
        isLoading = true
        error = nil
        
        do {
            let images = try await loadImagesAsync(for: hymnNumber)
            currentSheetMusic = images
            currentHymnKey = hymnNumber
            isLoading = false
            return images
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    private func loadImagesAsync(for hymnNumber: Int) async throws -> [UIImage] {
        // Format the hymn number with leading zeros (e.g. 1 -> "001")
        let numberString = String(format: "%03d", hymnNumber)
        let baseFilename = "sheet-music/1985/PianoSheet_NewHymnal_en_\(numberString)"
        var images: [UIImage] = []
        print("Starting to load images for hymn \(hymnNumber)")
        
        // Try to load the main sheet music image
        do {
            let imageData: Data
            let cacheKey = "\(numberString).png"
            
            // Try to get from cache first
            if let cachedData = try? cacheService.retrieve(forKey: cacheKey, fromDirectory: cacheDirectory) {
                imageData = cachedData
                print("Retrieved main page from cache, size: \(imageData.count) bytes")
            } else {
                // Download from R2 if not in cache
                imageData = try await cloudStorage.downloadAsset(path: "\(baseFilename).png")
                print("Downloaded main page, size: \(imageData.count) bytes")
                // Store in cache
                try? cacheService.store(imageData, forKey: cacheKey, inDirectory: cacheDirectory)
            }
            
            if let image = UIImage(data: imageData) {
                print("Successfully created UIImage for main page, dimensions: \(image.size)")
                images.append(image)
            }
            
            // Try loading additional pages
            var page = 1  // Start from page 1 since some hymns use _1, _2, etc.
            var consecutiveFailures = 0
            while consecutiveFailures < 2 {  // Allow one missing page before stopping
                do {
                    let pageCacheKey = "\(numberString)_\(page).png"
                    let pageData: Data
                    
                    print("Attempting to load page \(page)")
                    // Try cache first
                    if let cachedData = try? cacheService.retrieve(forKey: pageCacheKey, fromDirectory: cacheDirectory) {
                        pageData = cachedData
                        print("Retrieved page \(page) from cache, size: \(pageData.count) bytes")
                    } else {
                        // Download if not in cache
                        pageData = try await cloudStorage.downloadAsset(path: "\(baseFilename)_\(page).png")
                        print("Downloaded page \(page), size: \(pageData.count) bytes")
                        // Store in cache
                        try? cacheService.store(pageData, forKey: pageCacheKey, inDirectory: cacheDirectory)
                    }
                    
                    if let pageImage = UIImage(data: pageData) {
                        print("Successfully created UIImage for page \(page), dimensions: \(pageImage.size)")
                        images.append(pageImage)
                        consecutiveFailures = 0  // Reset counter on success
                    } else {
                        print("Failed to create UIImage from data for page \(page)")
                        consecutiveFailures += 1
                    }
                } catch {
                    print("Error loading page \(page): \(error)")
                    consecutiveFailures += 1
                }
                page += 1
            }
            
            print("Finished loading images. Total pages loaded: \(images.count)")
        } catch {
            print("Error loading sheet music: \(error)")
        }
        
        guard !images.isEmpty else {
            throw NSError(domain: "SheetMusicService", code: -1, 
                        userInfo: [NSLocalizedDescriptionKey: "Sheet music not found for hymn \(hymnNumber)"])
        }
        
        return images
    }
    
    func sheetMusicExists(for hymnNumber: Int) -> Bool {
        // Format the hymn number with leading zeros
        let numberString = String(format: "%03d", hymnNumber)
        let path = "sheet-music/1985/PianoSheet_NewHymnal_en_\(numberString).png"
        
        // We'll consider it exists if we can construct a valid URL
        // The actual existence will be checked when downloading
        return true
    }
}

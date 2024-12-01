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

class SheetMusicService: ObservableObject {
    static let shared = SheetMusicService()
    
    @Published private(set) var currentSheetMusic: [UIImage]?
    @Published private(set) var currentHymnKey: Int?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    // Cache for loaded images
    private var imageCache = NSCache<NSString, ImageContainer>()
    private var loadingTasks: [Int: Task<Void, Never>] = [:]
    
    private init() {
        // Configure cache limits
        imageCache.countLimit = 10 // Keep at most 10 hymns in memory
        imageCache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
    }
    
    @MainActor
    func getSheetMusic(for hymnNumber: Int) async throws -> [UIImage]? {
        // If we're already showing this hymn, return it
        if let existingImages = currentSheetMusic,
           let currentKey = currentHymnKey,
           currentKey == hymnNumber {
            return existingImages
        }
        
        // Check the cache first
        let cacheKey = NSString(string: String(hymnNumber))
        if let cachedContainer = imageCache.object(forKey: cacheKey) {
            currentSheetMusic = cachedContainer.images
            currentHymnKey = hymnNumber
            isLoading = false
            error = nil
            return cachedContainer.images
        }
        
        isLoading = true
        error = nil
        
        do {
            let images = try await loadImagesAsync(for: hymnNumber)
            currentSheetMusic = images
            currentHymnKey = hymnNumber
            imageCache.setObject(ImageContainer(images: images), forKey: cacheKey)
            isLoading = false
            return images
        } catch {
            self.error = error
            isLoading = false
            throw error
        }
    }
    
    private func loadImagesAsync(for hymnNumber: Int) async throws -> [UIImage] {
        // Check if we're using the 1941 hymnal
        let selectedHymnal = UserDefaults.standard.string(forKey: "selectedHymnal") ?? HymnalType.current.rawValue
        let hymnalType = HymnalType(rawValue: selectedHymnal) ?? .current
        
        if hymnalType == .old1941 {
            return try await load1941Images(for: hymnNumber)
        } else {
            return try await loadCurrentImages(for: hymnNumber)
        }
    }
    
    private func load1941Images(for hymnNumber: Int) async throws -> [UIImage] {
        let numberString = String(format: "%03d", hymnNumber)
        let hymnsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("1941_sheet_music")
            .appendingPathComponent(numberString)
        
        var images: [UIImage] = []
        
        // Check if directory exists
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: hymnsDirectory.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            throw NSError(domain: "SheetMusicService", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Sheet music not found for 1941 hymn \(hymnNumber)"])
        }
        
        // Load all sheet music files in the directory
        let fileURLs = try FileManager.default.contentsOfDirectory(at: hymnsDirectory,
                                                                 includingPropertiesForKeys: nil)
        let imageURLs = fileURLs.filter { url in
            let ext = url.pathExtension.lowercased()
            return ext == "pdf" || ext == "png" || ext == "jpg" || ext == "jpeg"
        }.sorted { $0.lastPathComponent < $1.lastPathComponent }
        
        for url in imageURLs {
            if url.pathExtension.lowercased() == "pdf" {
                // For PDFs, convert to images
                if let pdfDoc = CGPDFDocument(url as CFURL),
                   let pdfPage = pdfDoc.page(at: 1) {
                    let pageRect = pdfPage.getBoxRect(.mediaBox)
                    let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                    let image = renderer.image { ctx in
                        UIColor.white.set()
                        ctx.fill(pageRect)
                        ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
                        ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                        ctx.cgContext.drawPDFPage(pdfPage)
                    }
                    images.append(image)
                }
            } else if let image = UIImage(contentsOfFile: url.path) {
                images.append(image)
            }
        }
        
        guard !images.isEmpty else {
            throw NSError(domain: "SheetMusicService", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No valid sheet music found for 1941 hymn \(hymnNumber)"])
        }
        
        return images
    }
    
    private func loadCurrentImages(for hymnNumber: Int) async throws -> [UIImage] {
        // Format the hymn number with leading zeros (e.g. 1 -> "001")
        let numberString = String(format: "%03d", hymnNumber)
        let baseFilename = "PianoSheet_NewHymnal_en_\(numberString)"
        var images: [UIImage] = []
        
        // Try different possible locations for the sheet music
        let possibleDirectories = [
            "Resources/Assets/MusicSheets",
            "MusicSheets",
            "Assets/MusicSheets",
            ""
        ]
        
        // Load the main image
        for directory in possibleDirectories {
            if let mainImage = loadImage(withName: baseFilename, inDirectory: directory) {
                images.append(mainImage)
                break
            }
        }
        
        // Try loading additional pages (up to 5 pages)
        if !images.isEmpty {
            let directory = possibleDirectories.first { dir in
                loadImage(withName: baseFilename, inDirectory: dir) != nil
            } ?? ""
            
            for i in 1...5 {
                if let additionalImage = loadImage(withName: "\(baseFilename)_\(i)", inDirectory: directory) {
                    images.append(additionalImage)
                }
            }
        }
        
        guard !images.isEmpty else {
            throw NSError(domain: "SheetMusicService", code: -1, 
                        userInfo: [NSLocalizedDescriptionKey: "Sheet music not found for hymn \(hymnNumber)"])
        }
        
        return images
    }
    
    private func loadImage(withName name: String, inDirectory directory: String) -> UIImage? {
        // First try loading from the specified directory
        if !directory.isEmpty,
           let resourcePath = Bundle.main.path(forResource: name, ofType: "png", inDirectory: directory),
           let image = UIImage(contentsOfFile: resourcePath) {
            return image
        }
        
        // If that fails, try loading directly by name
        if let resourcePath = Bundle.main.path(forResource: name, ofType: "png"),
           let image = UIImage(contentsOfFile: resourcePath) {
            return image
        }
        
        return nil
    }
    
    func sheetMusicExists(for hymnNumber: Int) -> Bool {
        // Check if we're using the 1941 hymnal
        let selectedHymnal = UserDefaults.standard.string(forKey: "selectedHymnal") ?? HymnalType.current.rawValue
        let hymnalType = HymnalType(rawValue: selectedHymnal) ?? .current
        
        // Hide sheet music completely for 1941 hymnal
        if hymnalType == .old1941 {
            return false
        }
        
        // Check for current hymnal sheet music
        let numberString = String(format: "%03d", hymnNumber)
        let filename = "PianoSheet_NewHymnal_en_\(numberString)"
        
        // Try different possible locations
        let possibleDirectories = [
            "Resources/Assets/MusicSheets",
            "MusicSheets",
            "Assets/MusicSheets",
            ""
        ]
        
        return possibleDirectories.contains { directory in
            Bundle.main.path(forResource: filename, ofType: "png", inDirectory: directory) != nil ||
            Bundle.main.path(forResource: "\(filename)_1", ofType: "png", inDirectory: directory) != nil
        }
    }
}

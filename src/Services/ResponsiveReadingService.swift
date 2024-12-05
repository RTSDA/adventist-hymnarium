import Foundation
import SwiftUI

@MainActor
final class ResponsiveReadingService: ObservableObject {
    // MARK: - Singleton
    static let shared = ResponsiveReadingService()
    
    // MARK: - Published Properties
    @Published private(set) var readings: [ResponsiveReading] = []
    @Published var currentLanguage: HymnalLanguage {
        didSet {
            Task {
                await loadReadings()
            }
        }
    }
    
    // MARK: - Properties
    private var isLoaded = false
    private let favoritesKey = "favoriteReadings"
    @Published private(set) var favoriteReadings: Set<Int> = []
    
    var sortedFavoriteReadings: [ResponsiveReading] {
        readings.filter { favoriteReadings.contains($0.number) }
            .sorted { $0.number < $1.number }
    }
    
    // MARK: - Dependencies
    private let dataService = DataService.shared
    
    // MARK: - Initialization
    private init() {
        if let favorites = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] {
            favoriteReadings = Set(favorites)
        }
        
        // Initialize with the same language as HymnalService
        self.currentLanguage = HymnalService.shared.currentLanguage
        
        Task {
            await loadReadings()
        }
    }
    
    // MARK: - Public Methods
    func reading(number: Int) -> ResponsiveReading? {
        readings.first { $0.number == number }
    }
    
    func loadReadings() async {
        do {
            readings = try await dataService.loadResponsiveReadings()
            isLoaded = true
        } catch {
            print("Error loading readings: \(error)")
        }
    }
    
    func toggleFavorite(_ reading: ResponsiveReading) {
        if favoriteReadings.contains(reading.number) {
            favoriteReadings.remove(reading.number)
        } else {
            favoriteReadings.insert(reading.number)
        }
        UserDefaults.standard.set(Array(favoriteReadings), forKey: favoritesKey)
    }
    
    func isFavorite(_ reading: ResponsiveReading) -> Bool {
        favoriteReadings.contains(reading.number)
    }
    
    func clearFavorites() {
        favoriteReadings.removeAll()
        UserDefaults.standard.removeObject(forKey: favoritesKey)
    }
}

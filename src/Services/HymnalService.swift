import Foundation
import SwiftUI

@MainActor
final class HymnalService: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var hymns: [Hymn] = []
    @Published private(set) var thematicLists: [ThematicList] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var currentLanguage: HymnalLanguage
    @Published private(set) var recentHymns: [Int] = []
    
    // MARK: - Singleton
    static let shared = HymnalService()
    
    // MARK: - Dependencies
    private let dataService: DataService
    private let recentManager: RecentHymnsManager
    
    // MARK: - Private State
    private var hymnCache: [String: [Hymn]] = [:]
    private var thematicCache: [String: [ThematicList]] = [:]
    
    private init() {
        // Initialize dependencies first
        self.dataService = DataService.shared
        self.recentManager = RecentHymnsManager()
        
        // Initialize published properties
        let savedHymnal = UserDefaults.standard.string(forKey: "selectedHymnal") ?? HymnalType.current.rawValue
        let hymnalType = HymnalType(rawValue: savedHymnal) ?? .current
        self.currentLanguage = hymnalType == .current ? .english1985 : .english1941
        
        // Load initial data
        Task {
            await refreshData()
        }
    }
    
    // MARK: - Public Methods
    func hymn(number: Int) -> Hymn? {
        hymns.first { $0.number == number }
    }
    
    func addToRecentHymns(_ number: Int) {
        recentManager.addHymn(number)
        loadRecentHymns()
    }
    
    func removeFromRecentHymns(_ number: Int) {
        recentManager.removeHymn(number)
        loadRecentHymns()
    }
    
    func isReadingNumber(_ number: Int) -> Bool {
        // Assuming readings are in a specific range, e.g., 700-800
        return currentLanguage == .english1985 && number >= 700 && number <= 800
    }
    
    func clearRecentHymns() {
        recentManager.clearHymns()
        loadRecentHymns()
    }
    
    func refreshData() async {
        isLoading = true
        error = nil
        
        do {
            hymns = try await dataService.loadHymns(for: currentLanguage)
            thematicLists = try await dataService.loadThematicLists(for: currentLanguage)
        } catch {
            self.error = error
        }
        
        isLoading = false
        loadRecentHymns()
    }
    
    // MARK: - Private Methods
    private func loadRecentHymns() {
        recentHymns = recentManager.getRecentHymns()
    }
    
    func setLanguage(_ language: HymnalLanguage) async {
        currentLanguage = language
        await refreshData()
    }
}

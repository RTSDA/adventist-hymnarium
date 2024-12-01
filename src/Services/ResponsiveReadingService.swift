import Foundation
import Combine

class ResponsiveReadingService: ObservableObject {
    static let shared = ResponsiveReadingService()
    
    @Published private(set) var readings: [ResponsiveReading] = []
    @Published private(set) var favoriteReadings: Set<Int> = []
    private var isLoaded = false
    private var cancellables = Set<AnyCancellable>()
    
    private var favoritesKey: String {
        "favoriteReadings_\(HymnalService.shared.currentLanguage.id)"
    }
    
    private init() {
        loadFavorites()
        setupLanguageObserver()
    }
    
    private func setupLanguageObserver() {
        HymnalService.shared.$currentLanguage
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.loadFavorites()
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func loadReadings() async {
        guard !isLoaded else { return }
        
        if let bundleURL = Bundle.main.url(forResource: "responsive_readings", withExtension: "json") {
            do {
                let data = try Data(contentsOf: bundleURL)
                let decoder = JSONDecoder()
                var decodedReadings = try decoder.decode([ResponsiveReading].self, from: data)
                
                // Process each reading to create proper sections
                for i in 0..<decodedReadings.count {
                    let reading = decodedReadings[i]
                    var sections: [ResponsiveReading.Section] = []
                    let paragraphs = reading.content.components(separatedBy: "\n\n")
                    
                    for (index, paragraph) in paragraphs.enumerated() {
                        // If it's the last paragraph, mark it as "All"
                        // Otherwise alternate between Leader and Congregation
                        let type: ResponsiveReading.SectionType
                        if index == paragraphs.count - 1 {
                            type = .all
                        } else {
                            type = index % 2 == 0 ? .light : .dark
                        }
                        
                        sections.append(ResponsiveReading.Section(
                            type: type,
                            content: paragraph.trimmingCharacters(in: .whitespacesAndNewlines),
                            order: index + 1
                        ))
                    }
                    
                    // Update the reading with the new sections
                    decodedReadings[i] = ResponsiveReading(
                        number: reading.number,
                        title: reading.title,
                        content: reading.content,
                        sections: sections
                    )
                }
                
                self.readings = decodedReadings
                isLoaded = true
            } catch {
                print("Error loading responsive readings: \(error)")
            }
        } else {
            print("Warning: Could not find responsive_readings.json in bundle")
        }
    }
    
    func reading(for number: Int) -> ResponsiveReading? {
        readings.first { $0.number == number }
    }
    
    // MARK: - Favorites Management
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] {
            DispatchQueue.main.async {
                self.favoriteReadings = Set(data)
            }
        }
    }
    
    private func saveFavorites() {
        UserDefaults.standard.set(Array(favoriteReadings), forKey: favoritesKey)
    }
    
    func toggleFavorite(for reading: ResponsiveReading) {
        if favoriteReadings.contains(reading.number) {
            favoriteReadings.remove(reading.number)
        } else {
            favoriteReadings.insert(reading.number)
        }
        saveFavorites()
    }
    
    func isFavorite(_ reading: ResponsiveReading) -> Bool {
        favoriteReadings.contains(reading.number)
    }
    
    var sortedFavoriteReadings: [ResponsiveReading] {
        readings.filter { favoriteReadings.contains($0.number) }
               .sorted { $0.number < $1.number }
    }
    
    func clearFavorites() {
        favoriteReadings.removeAll()
        saveFavorites()
    }
}

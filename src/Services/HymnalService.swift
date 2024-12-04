import Foundation

class HymnalService: ObservableObject {
    @Published private(set) var hymns: [Hymn] = []
    @Published private(set) var thematicLists: [ThematicList] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var currentLanguage: HymnalLanguage
    @Published private(set) var recentHymns: [Int] = []
    
    static let shared = HymnalService()
    
    private var hymnCache: [String: [Hymn]] = [:]
    private var thematicCache: [String: [ThematicList]] = [:]
    let recentHymnsManager = RecentHymnsManager.shared
    
    private init() {
        print("HymnalService: Initializing...")
        // Get the saved hymnal preference
        let savedHymnal = UserDefaults.standard.string(forKey: "selectedHymnal") ?? HymnalType.current.rawValue
        let hymnalType = HymnalType(rawValue: savedHymnal) ?? .current
        self.currentLanguage = hymnalType == .current ? .english1985 : .english1941
        
        Task {
            await loadData()
        }
    }
    
    func setLanguage(_ language: HymnalLanguage) async {
        guard language != currentLanguage else { return }
        await MainActor.run {
            self.currentLanguage = language
        }
        await loadData()
    }
    
    private func loadData() async {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            print("HymnalService: Starting data load for language \(currentLanguage.id)...")
            
            // Load hymns and thematic lists
            async let hymnsTask = loadHymns(for: currentLanguage)
            async let thematicTask = loadThematicLists(for: currentLanguage)
            
            let (loadedHymns, loadedThematic) = try await (hymnsTask, thematicTask)
            
            await MainActor.run {
                self.hymns = loadedHymns
                self.thematicLists = loadedThematic
                self.error = nil
                self.isLoading = false
            }
            
            print("HymnalService: Data load completed successfully")
            
            // Update recent hymns
            await updateRecentHymns()
            
            print("HymnalService: Successfully loaded \(loadedHymns.count) hymns and \(loadedThematic.count) thematic lists")
            
        } catch {
            print("HymnalService: Error loading data - \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("HymnalService: Detailed error - Domain: \(nsError.domain), Code: \(nsError.code), Description: \(nsError.debugDescription)")
                print("HymnalService: Error user info - \(nsError.userInfo)")
            }
            
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
        
    }
    
    @MainActor
    func loadHymns() async {
        guard hymns.isEmpty else { return }
        await loadData()
    }
    
    private func loadHymns(for language: HymnalLanguage) async throws -> [Hymn] {
        // Check cache first
        if let cached = hymnCache[language.id] {
            print("HymnalService: Returning cached hymns for \(language.id)")
            return cached
        }
        
        print("HymnalService: Loading hymns for \(language.id)...")
        
        // Try to load from bundle first
        if let bundlePath = Bundle.main.path(forResource: language.hymnsFileName.replacingOccurrences(of: ".json", with: ""), ofType: "json") {
            print("HymnalService: Loading hymns from bundle at \(bundlePath)")
            let data = try Data(contentsOf: URL(fileURLWithPath: bundlePath))
            var hymns = try JSONDecoder().decode([Hymn].self, from: data)
            
            // Set language ID for each hymn
            hymns = hymns.map { hymn in
                var mutableHymn = hymn
                mutableHymn.languageId = language.id
                return mutableHymn
            }
            
            // If this is the current hymnal, also load responsive readings
            if language.id == HymnalType.current.languageCode {
                await ResponsiveReadingService.shared.loadReadings()
                let readings = ResponsiveReadingService.shared.readings
                
                // Convert readings to hymns for display in the list
                let readingHymns = readings.map { reading in
                    Hymn(
                        number: reading.number,
                        title: reading.title,
                        verses: [reading.content],
                        languageId: language.id
                    )
                }
                
                hymns.append(contentsOf: readingHymns)
            }
            
            // Cache the results
            hymnCache[language.id] = hymns
            
            print("HymnalService: Loaded \(hymns.count) hymns from bundle")
            return hymns
        }
        
        // If not in bundle, try loading from app directory
        let appPath = Bundle.main.bundlePath
        print("HymnalService: App bundle path - \(appPath)")
        
        let resourcePath = (appPath as NSString).appendingPathComponent("Resources/Assets/\(language.hymnsFileName)")
        print("HymnalService: Trying to load hymns from \(resourcePath)")
        
        let data = try Data(contentsOf: URL(fileURLWithPath: resourcePath))
        var hymns = try JSONDecoder().decode([Hymn].self, from: data)
        
        // Set language ID for each hymn
        hymns = hymns.map { hymn in
            var mutableHymn = hymn
            mutableHymn.languageId = language.id
            return mutableHymn
        }
        
        // If this is the current hymnal, also load responsive readings
        if language.id == HymnalType.current.languageCode {
            await ResponsiveReadingService.shared.loadReadings()
            let readings = ResponsiveReadingService.shared.readings
            
            // Convert readings to hymns for display in the list
            let readingHymns = readings.map { reading in
                Hymn(
                    number: reading.number,
                    title: reading.title,
                    verses: [reading.content],
                    languageId: language.id
                )
            }
            
            hymns.append(contentsOf: readingHymns)
        }
        
        // Cache the results
        hymnCache[language.id] = hymns
        
        print("HymnalService: Loaded \(hymns.count) hymns from app directory")
        return hymns
    }
    
    private func loadThematicLists(for language: HymnalLanguage) async throws -> [ThematicList] {
        // Check cache first
        if let cached = thematicCache[language.id] {
            return cached
        }
        
        guard let thematicFileName = language.thematicHymnsFileName else {
            return []
        }
        
        // Try to load from bundle first
        if let bundlePath = Bundle.main.path(forResource: thematicFileName.replacingOccurrences(of: ".json", with: ""), ofType: "json") {
            let data = try Data(contentsOf: URL(fileURLWithPath: bundlePath))
            let lists = try JSONDecoder().decode([ThematicList].self, from: data)
            thematicCache[language.id] = lists
            return lists
        }
        
        // If not in bundle, try loading from app directory
        let appPath = Bundle.main.bundlePath
        let resourcePath = (appPath as NSString).appendingPathComponent("Resources/Assets/\(thematicFileName)")
        let data = try Data(contentsOf: URL(fileURLWithPath: resourcePath))
        let lists = try JSONDecoder().decode([ThematicList].self, from: data)
        thematicCache[language.id] = lists
        return lists
    }
    
    func hymn(number: Int) -> Hymn? {
        hymns.first { $0.number == number }
    }
    
    func hymns(in ambit: ThematicAmbit) -> [Hymn] {
        hymns.filter { $0.number >= ambit.start && $0.number <= ambit.end }
    }
    
    func updateRecentHymns() async {
        let recentNumbers = recentHymnsManager.recentHymns
        let recentHymns = recentNumbers.compactMap { number in
            hymns.first { $0.number == number }
        }
        
        await MainActor.run {
            self.recentHymns = recentHymns.map { $0.number }
        }
    }
    
    var isReadingNumber: (Int) -> Bool {
        { number in
            number >= 696 && number <= 920 && self.currentLanguage.id == HymnalType.current.languageCode
        }
    }
    
    // Navigation helpers
    func previousHymnNumber(from current: Int) -> Int? {
        let sortedNumbers = hymns.map { $0.number }.sorted()
        guard let currentIndex = sortedNumbers.firstIndex(of: current) else { return nil }
        return currentIndex > 0 ? sortedNumbers[currentIndex - 1] : nil
    }
    
    func nextHymnNumber(from current: Int) -> Int? {
        let sortedNumbers = hymns.map { $0.number }.sorted()
        guard let currentIndex = sortedNumbers.firstIndex(of: current) else { return nil }
        return currentIndex < sortedNumbers.count - 1 ? sortedNumbers[currentIndex + 1] : nil
    }
}

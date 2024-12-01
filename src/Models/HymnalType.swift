import Foundation

enum HymnalType: String, CaseIterable {
    case current = "sda"
    case old1941 = "old"
    
    var displayName: String {
        switch self {
        case .current:
            return "SDA Hymnal (1985)"
        case .old1941:
            return "Church Hymnal (1941)"
        }
    }
    
    var numberOfHymns: Int {
        switch self {
        case .current:
            return 695
        case .old1941:
            return 703
        }
    }
    
    var languageCode: String {
        return "en"  // Both hymnals are in English
    }
    
    var jsonFileName: String {
        switch self {
        case .current:
            return "hymnal-en"
        case .old1941:
            return "old_hymnal-en"
        }
    }
}

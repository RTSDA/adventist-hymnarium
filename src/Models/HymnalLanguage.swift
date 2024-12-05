import Foundation

enum HymnalLanguage: String, CaseIterable {
    case english1985 = "en-newVersion"
    case english1941 = "en-oldVersion"
    case spanish2009 = "es-newVersion"
    case russian = "ru-newVersion"
    
    var id: String { rawValue }
    
    var twoLetterIsoLanguageName: String {
        switch self {
        case .english1985, .english1941:
            return "en"
        case .spanish2009:
            return "es"
        case .russian:
            return "ru"
        }
    }
    
    var name: String {
        switch self {
        case .english1985:
            return "New Version 1985"
        case .english1941:
            return "Old Version 1941"
        case .spanish2009:
            return "Nueva Versión 2009"
        case .russian:
            return "Русская Версия"
        }
    }
    
    var detail: String {
        switch self {
        case .english1985, .english1941:
            return "English"
        case .spanish2009:
            return "Español"
        case .russian:
            return "Русский"
        }
    }
    
    var year: Int {
        switch self {
        case .english1985:
            return 1985
        case .english1941:
            return 1941
        case .spanish2009:
            return 2009
        case .russian:
            return 2020
        }
    }
    
    var hymnsFileName: String {
        switch self {
        case .english1985:
            return "new-hymnal-en.json"
        case .english1941:
            return "old-hymnal-en.json"
        case .spanish2009:
            return "new-hymnal-es.json"
        case .russian:
            return "new-hymnal-ru.json"
        }
    }
    
    var thematicHymnsFileName: String? {
        switch self {
        case .english1985, .spanish2009, .russian:
            return "new-hymnal-thematic-list-\(twoLetterIsoLanguageName).json"
        case .english1941:
            return "old-hymnal-thematic-list-en.json"
        }
    }
    
    var hymnsSheetsFileName: String? {
        switch self {
        case .english1985, .spanish2009, .russian:
            return "PianoSheet_NewHymnal_\(twoLetterIsoLanguageName)_###"
        case .english1941:
            return nil
        }
    }
    
    var supportsThematicList: Bool { thematicHymnsFileName != nil }
    var supportsSheets: Bool { hymnsSheetsFileName != nil }
    
    static func getLanguage(withId id: String) -> HymnalLanguage? {
        HymnalLanguage(rawValue: id)
    }
}

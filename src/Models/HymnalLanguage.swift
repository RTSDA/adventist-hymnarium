import Foundation

struct HymnalLanguage: Equatable {
    /// Identifier for comparative Equals
    let id: String
    let twoLetterIsoLanguageName: String
    let name: String
    let detail: String
    let year: Int
    let hymnsFileName: String
    let thematicHymnsFileName: String?
    let hymnsSheetsFileName: String?
    
    var supportsThematicList: Bool { thematicHymnsFileName != nil }
    var supportsSheets: Bool { hymnsSheetsFileName != nil }
    
    static let english1985 = HymnalLanguage(
        id: "en-newVersion",
        twoLetterIsoLanguageName: "en",
        name: "New Version 1985",
        detail: "English",
        year: 1985,
        hymnsFileName: "new-hymnal-en.json",
        thematicHymnsFileName: "new-hymnal-thematic-list-en.json",
        hymnsSheetsFileName: "PianoSheet_NewHymnal_en_###"
    )
    
    static let english1941 = HymnalLanguage(
        id: "en-oldVersion",
        twoLetterIsoLanguageName: "en",
        name: "Old Version 1941",
        detail: "English",
        year: 1941,
        hymnsFileName: "old-hymnal-en.json",
        thematicHymnsFileName: "old-hymnal-thematic-list-en.json",
        hymnsSheetsFileName: nil
    )
    
    static let spanish2009 = HymnalLanguage(
        id: "es-newVersion",
        twoLetterIsoLanguageName: "es",
        name: "Nueva Versión 2009",
        detail: "Español",
        year: 2009,
        hymnsFileName: "new-hymnal-es.json",
        thematicHymnsFileName: "new-hymnal-thematic-list-es.json",
        hymnsSheetsFileName: "PianoSheet_NewHymnal_es_###"
    )
    
    static let russian = HymnalLanguage(
        id: "ru-newVersion",
        twoLetterIsoLanguageName: "ru",
        name: "Русская Версия",
        detail: "Русский",
        year: 2020,
        hymnsFileName: "new-hymnal-ru.json",
        thematicHymnsFileName: "new-hymnal-thematic-list-ru.json",
        hymnsSheetsFileName: "PianoSheet_NewHymnal_ru_###"
    )
    
    static let supportedLanguages: [HymnalLanguage] = [
        .english1985,  // Default
        .english1941,
        .spanish2009,
        .russian
    ]
    
    static func getLanguage(withId id: String) -> HymnalLanguage? {
        supportedLanguages.first { $0.id == id }
    }
}

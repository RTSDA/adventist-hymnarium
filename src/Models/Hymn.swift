import Foundation
import UIKit

// MARK: - Hymn Models
struct Hymn: Codable, Identifiable {
    let number: Int
    let title: String
    let verses: [String]
    var languageId: String?  // Language ID from HymnalLanguage
    
    var id: Int { number }
    
    // Sheet music functionality
    var sheetMusic: [UIImage]? {
        if languageId == HymnalLanguage.english1985.id {
            return SheetMusicService.shared.currentSheetMusic
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case number
        case title
        case verses = "content"
        case languageId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        number = try container.decode(Int.self, forKey: .number)
        title = try container.decode(String.self, forKey: .title)
        
        // Handle content which might be a single string or an array
        if let content = try? container.decode(String.self, forKey: .verses) {
            // Split content into verses
            verses = content.components(separatedBy: "\n\n").filter { !$0.isEmpty }
        } else {
            verses = try container.decode([String].self, forKey: .verses)
        }
        
        languageId = try container.decodeIfPresent(String.self, forKey: .languageId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        try container.encode(title, forKey: .title)
        try container.encode(verses.joined(separator: "\n\n"), forKey: .verses)
        try container.encodeIfPresent(languageId, forKey: .languageId)
    }
    
    // Custom init for creating examples and tests
    init(number: Int, title: String, verses: [String], languageId: String? = nil) {
        self.number = number
        self.title = title
        self.verses = verses
        self.languageId = languageId
    }
    
    // Special labels for hymn 663 (Amens)
    private static var amenLabels = [
        "Amen",
        "Threefold Amen",
        "Sevenfold Amen",
        "Fourfold Amen"
    ]
    
    var parsedVerses: [Verse] {
        let verseTexts = verses
        
        // Special handling for hymn 663 (Amens)
        if number == 663 {
            return verseTexts.enumerated().map { index, text in
                let label = index < Self.amenLabels.count ? Self.amenLabels[index] : "Amen \(index + 1)"
                return Verse(number: index + 1, text: text, isChorus: false, label: label)
            }
        }
        
        // Check if this is a 1941 hymnal hymn
        let is1941Hymnal = languageId == HymnalLanguage.english1941.id
        
        // First pass: Parse all verses and identify chorus
        let parsedVerses = verseTexts.enumerated().compactMap { index, text -> Verse? in
            let lines = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if lines.isEmpty { return nil }
            
            // Check if it's a chorus
            if lines.lowercased().hasPrefix("chorus:") {
                let chorusText = lines.replacingOccurrences(of: "CHORUS:", with: "", options: .caseInsensitive)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return Verse(number: 0, text: chorusText, isChorus: true, label: "Chorus")
            }
            
            if is1941Hymnal {
                // For 1941 hymnal, use the index + 1 as verse number
                return Verse(number: index + 1, text: lines, isChorus: false, label: "Verse \(index + 1)")
            } else {
                // Parse verse number and text for 1985 hymnal
                let allLines = lines.components(separatedBy: "\n")
                guard let firstLine = allLines.first?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
                
                // Try to extract verse number from the first line
                // Match patterns like "1.", "12.", "1 ", "12 "
                let pattern = "^(\\d+)[\\s\\.]"
                if let range = firstLine.range(of: pattern, options: .regularExpression),
                   let number = Int(firstLine[range.lowerBound..<range.upperBound].trimmingCharacters(in: CharacterSet(charactersIn: ". "))) {
                    // Join all lines except the first one (which contains the verse number)
                    let verseText = allLines.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    return Verse(number: number, text: verseText, isChorus: false, label: "Verse \(number)")
                }
                
                // Special case: If no verse number is found, treat the entire text as a verse
                return Verse(number: 1, text: lines, isChorus: false, label: "Verse 1")
            }
        }
        
        // Sort verses by number and handle chorus placement
        let regularVerses = parsedVerses.filter { !$0.isChorus }.sorted { $0.number < $1.number }
        let chorus = parsedVerses.first { $0.isChorus }
        
        // Build final array with chorus after verse 1
        var result: [Verse] = []
        
        for verse in regularVerses {
            result.append(verse)
            // Add chorus after verse 1
            if verse.number == 1 && chorus != nil {
                result.append(chorus!)
            }
        }
        
        return result
    }
}

struct Verse: Identifiable, Hashable {
    var id: String { "\(number)-\(isChorus ? "chorus" : "verse")" }
    let number: Int
    let text: String
    let isChorus: Bool
    var label: String?
    
    init(number: Int, text: String, isChorus: Bool, label: String? = nil) {
        self.number = number
        self.text = text
        self.isChorus = isChorus
        self.label = label
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Verse, rhs: Verse) -> Bool {
        lhs.id == rhs.id && lhs.text == rhs.text
    }
}

// MARK: - Preview Helpers
extension Hymn {
    static let example = Hymn(
        number: 1,
        title: "Praise to the Lord",
        verses: [
            "Praise to the Lord, the Almighty, the King of creation!",
            "O my soul, praise Him, for He is thy health and salvation!",
            "All ye who hear, now to His temple draw near;",
            "Praise Him in glad adoration!"
        ]
    )
}

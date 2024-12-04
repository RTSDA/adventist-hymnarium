import Foundation
import SwiftUI

struct ResponsiveReading: Codable, Identifiable {
    let number: Int
    let title: String
    let content: String
    let sections: [Section]
    
    var id: Int { number }
    
    // Format the content for display
    var formattedContent: String {
        content.replacingOccurrences(of: "\\n", with: "\n")
              .replacingOccurrences(of: "\\r", with: "")
              .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    struct Section: Codable, Identifiable, Hashable {
        let type: SectionType
        let content: String
        let order: Int
        
        var id: Int { order }
        
        // Format the content for display
        var formattedContent: String {
            content.replacingOccurrences(of: "\\n", with: "\n")
                  .replacingOccurrences(of: "\\r", with: "")
                  .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        var role: String? {
            switch type {
            case .all:
                return "All"
            case .light:
                return "Leader"
            case .dark:
                return "Congregation"
            }
        }
        
        // Implement Hashable
        func hash(into hasher: inout Hasher) {
            hasher.combine(order)
        }
        
        static func == (lhs: Section, rhs: Section) -> Bool {
            lhs.order == rhs.order
        }
    }
    
    enum SectionType: String, Codable {
        case light = "LIGHT"
        case dark = "DARK"
        case all = "ALL"
    }
}

// MARK: - Preview Example
extension ResponsiveReading {
    static let example = ResponsiveReading(
        number: 696,
        title: "I Will Extol the Lord - Psalm 34",
        content: "",
        sections: [
            Section(type: .light, content: "I will extol the Lord at all times;\nHis praise will always be on my lips.", order: 1),
            Section(type: .dark, content: "My soul will boast in the Lord;\nlet the afflicted hear and rejoice.", order: 2),
            Section(type: .all, content: "Glorify the Lord with me;\nlet us exalt his name together.", order: 3),
            Section(type: .light, content: "I sought the Lord, and he answered me;\nhe delivered me from all my fears.", order: 4),
            Section(type: .dark, content: "Those who look to him are radiant;\ntheir faces are never covered with shame.", order: 5)
        ]
    )
}

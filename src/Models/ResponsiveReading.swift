import Foundation
import SwiftUI

struct ResponsiveReading: Codable, Identifiable {
    struct Section: Identifiable {
        let id = UUID()
        let text: String
        let role: String?
    }
    
    let number: Int
    let title: String
    let parts: [String]
    let roles: [String?]
    
    var id: Int { number }
    
    var formattedContent: String {
        parts.enumerated().map { index, text in
            let role = roles[index]
            if let role = role {
                return "\(role):\n\(text.trimmingCharacters(in: .whitespacesAndNewlines))"
            }
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }.joined(separator: "\n\n")
    }
    
    var sections: [Section] {
        parts.enumerated().map { index, text in
            Section(text: text.trimmingCharacters(in: .whitespacesAndNewlines), role: roles[index])
        }
    }
}

// MARK: - Preview Example
extension ResponsiveReading {
    static let example = ResponsiveReading(
        number: 696,
        title: "The Law of God",
        parts: [
            "God spake all these words, saying:",
            "I am the Lord thy God, which have brought thee out of the land of Egypt, out of the house of bondage.",
            "Thou shalt have no other gods before Me."
        ],
        roles: ["Leader", "All", "Congregation"]
    )
}

import Foundation

struct GlossaryTerm: Codable, Identifiable, Hashable {
    let id: String
    let english: String
    let chinese: String
    let explanation: LocalizedString
    let isHighFrequency: Bool
    let letter: String
    let category: String?
}

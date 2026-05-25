import Foundation

struct Question: Codable, Identifiable, Hashable {
    let id: String
    let moduleId: String
    let number: Int
    let text: LocalizedString
    let options: [QuestionOption]
    let correctAnswer: String
    let topic: LocalizedString?
    let explanation: LocalizedString?
    let source: String?
    let tags: [String]?
}

struct QuestionOption: Codable, Hashable, Identifiable {
    var id: String { label }
    let label: String
    let text: LocalizedString
}

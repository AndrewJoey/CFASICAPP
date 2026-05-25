import Foundation

struct ModuleInfo: Codable, Identifiable, Hashable {
    let id: String
    let number: Int
    let title: LocalizedString
    let examWeight: String?
    let questionCount: Int
    let questionsFile: String
    let content: [ModuleContent]
}

struct ModuleContent: Codable, Identifiable, Hashable {
    var id: String { type }
    let type: String
    let title: LocalizedString
    let icon: String
    let files: [String: String]?
}

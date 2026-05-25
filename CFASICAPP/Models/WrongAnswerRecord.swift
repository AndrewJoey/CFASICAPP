import Foundation
import SwiftData

@Model
final class WrongAnswerRecord {
    @Attribute(.unique) var id: String
    var questionId: String
    var moduleId: String
    var selectedAnswer: String
    var timestamp: Date
    var reviewCount: Int
    var lastReviewed: Date?
    var isMastered: Bool

    init(
        id: String = UUID().uuidString,
        questionId: String,
        moduleId: String,
        selectedAnswer: String,
        timestamp: Date = .now,
        reviewCount: Int = 0,
        lastReviewed: Date? = nil,
        isMastered: Bool = false
    ) {
        self.id = id
        self.questionId = questionId
        self.moduleId = moduleId
        self.selectedAnswer = selectedAnswer
        self.timestamp = timestamp
        self.reviewCount = reviewCount
        self.lastReviewed = lastReviewed
        self.isMastered = isMastered
    }
}

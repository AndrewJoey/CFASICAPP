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

    // SM-2 spaced repetition fields
    var nextReviewDate: Date
    var easeFactor: Double
    var intervalDays: Int

    init(
        id: String = UUID().uuidString,
        questionId: String,
        moduleId: String,
        selectedAnswer: String,
        timestamp: Date = .now,
        reviewCount: Int = 0,
        lastReviewed: Date? = nil,
        isMastered: Bool = false,
        nextReviewDate: Date = .now,
        easeFactor: Double = 2.5,
        intervalDays: Int = 1
    ) {
        self.id = id
        self.questionId = questionId
        self.moduleId = moduleId
        self.selectedAnswer = selectedAnswer
        self.timestamp = timestamp
        self.reviewCount = reviewCount
        self.lastReviewed = lastReviewed
        self.isMastered = isMastered
        self.nextReviewDate = nextReviewDate
        self.easeFactor = easeFactor
        self.intervalDays = intervalDays
    }
}

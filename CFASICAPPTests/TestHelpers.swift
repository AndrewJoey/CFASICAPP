import Foundation
import SwiftData
@testable import CFASICAPP

enum TestHelpers {
    /// Creates an in-memory SwiftData container for testing.
    @MainActor
    static func makeInMemoryModelContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(
            for: WrongAnswerRecord.self, StudyDayRecord.self, ReadingProgress.self,
            configurations: config
        )
    }

    /// Creates a sample Question for testing.
    static func makeQuestion(
        id: String = "test-q001",
        moduleId: String = "module-01",
        number: Int = 1,
        correctAnswer: String = "B"
    ) -> Question {
        Question(
            id: id,
            moduleId: moduleId,
            number: number,
            text: LocalizedString(zh: "Test question?", en: nil),
            options: [
                QuestionOption(label: "A", text: LocalizedString(zh: "Option A", en: nil)),
                QuestionOption(label: "B", text: LocalizedString(zh: "Option B", en: nil)),
                QuestionOption(label: "C", text: LocalizedString(zh: "Option C", en: nil)),
                QuestionOption(label: "D", text: LocalizedString(zh: "Option D", en: nil)),
            ],
            correctAnswer: correctAnswer,
            topic: nil,
            explanation: nil,
            source: nil,
            tags: nil
        )
    }

    /// Creates a batch of sample questions.
    static func makeQuestions(count: Int, moduleId: String = "module-01", correctAnswer: String? = nil) -> [Question] {
        (1...count).map { i in
            makeQuestion(
                id: "\(moduleId)-q\(String(format: "%03d", i))",
                moduleId: moduleId,
                number: i,
                correctAnswer: correctAnswer ?? (i % 2 == 0 ? "A" : "B")
            )
        }
    }

    /// Creates a WrongAnswerRecord for testing.
    static func makeWrongAnswerRecord(
        questionId: String = "test-q001",
        moduleId: String = "module-01",
        isMastered: Bool = false,
        nextReviewDate: Date = .now,
        easeFactor: Double = 2.5,
        intervalDays: Int = 1
    ) -> WrongAnswerRecord {
        WrongAnswerRecord(
            questionId: questionId,
            moduleId: moduleId,
            selectedAnswer: "A",
            isMastered: isMastered,
            nextReviewDate: nextReviewDate,
            easeFactor: easeFactor,
            intervalDays: intervalDays
        )
    }
}

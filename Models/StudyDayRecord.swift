import Foundation
import SwiftData

@Model
final class StudyDayRecord {
    @Attribute(.unique) var id: String
    var date: Date
    var questionsAnswered: Int
    var correctCount: Int
    var modulesStudied: [String]

    init(
        id: String,
        date: Date,
        questionsAnswered: Int = 0,
        correctCount: Int = 0,
        modulesStudied: [String] = []
    ) {
        self.id = id
        self.date = date
        self.questionsAnswered = questionsAnswered
        self.correctCount = correctCount
        self.modulesStudied = modulesStudied
    }
}

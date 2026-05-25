import SwiftUI
import SwiftData

@Observable
final class ProgressViewModel {
    var studyRecords: [StudyDayRecord] = []
    var wrongAnswerCount: Int = 0
    var masteredCount: Int = 0

    var totalQuestionsAnswered: Int { studyRecords.reduce(0) { $0 + $1.questionsAnswered } }
    var totalCorrect: Int { studyRecords.reduce(0) { $0 + $1.correctCount } }
    var accuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalQuestionsAnswered)
    }

    var streak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        var streak = 0
        var date = today

        let dateSet = Set(studyRecords.map { calendar.startOfDay(for: $0.date) })

        while dateSet.contains(date) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return streak
    }

    var last30Days: [StudyDayRecord] {
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .day, value: -30, to: .now) ?? .now
        return studyRecords
            .filter { $0.date >= cutoff }
            .sorted { $0.date < $1.date }
    }

    @MainActor
    func load(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<StudyDayRecord>(sortBy: [SortDescriptor(\.date, order: .forward)])
        studyRecords = (try? modelContext.fetch(descriptor)) ?? []

        let wrongDescriptor = FetchDescriptor<WrongAnswerRecord>(
            predicate: #Predicate { !$0.isMastered }
        )
        wrongAnswerCount = (try? modelContext.fetchCount(wrongDescriptor)) ?? 0

        let masteredDescriptor = FetchDescriptor<WrongAnswerRecord>(
            predicate: #Predicate { $0.isMastered }
        )
        masteredCount = (try? modelContext.fetchCount(masteredDescriptor)) ?? 0
    }
}

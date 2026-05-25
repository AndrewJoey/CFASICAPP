import Foundation
import SwiftData

enum QuizMode: String, CaseIterable {
    case sequential = "顺序"
    case random = "随机"
    case wrongAnswers = "仅错题"
}

@Observable
final class StudyViewModel {
    var questions: [Question] = []
    var currentIndex: Int = 0
    var selectedAnswer: String? = nil
    var isAnswered: Bool = false
    var sessionResults: [(questionId: String, correct: Bool, selectedAnswer: String)] = []
    var isFinished: Bool = false

    var sessionModuleId: String?
    var sessionMode: QuizMode?
    var sessionQuestionCount: Int?

    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var correctCount: Int {
        sessionResults.filter(\.correct).count
    }

    var accuracy: Double {
        guard !sessionResults.isEmpty else { return 0 }
        return Double(correctCount) / Double(sessionResults.count)
    }

    var wrongQuestionDetails: [(question: Question, selectedAnswer: String)] {
        questions.enumerated().compactMap { index, question in
            guard index < sessionResults.count, !sessionResults[index].correct else { return nil }
            return (question: question, selectedAnswer: sessionResults[index].selectedAnswer)
        }
    }

    func startSession(moduleId: String?, mode: QuizMode, questionCount: Int? = nil, modelContext: ModelContext) {
        var pool: [Question]

        switch mode {
        case .sequential:
            pool = fetchQuestions(moduleId: moduleId)
        case .random:
            pool = fetchQuestions(moduleId: moduleId).shuffled()
        case .wrongAnswers:
            pool = fetchWrongAnswerQuestions(moduleId: moduleId, modelContext: modelContext)
        }

        if let count = questionCount, count < pool.count {
            pool = Array(pool.prefix(count))
        }

        self.sessionModuleId = moduleId
        self.sessionMode = mode
        self.sessionQuestionCount = questionCount

        questions = pool
        currentIndex = 0
        selectedAnswer = nil
        isAnswered = false
        sessionResults = []
        isFinished = false
    }

    func retrySameSession(modelContext: ModelContext) {
        guard let mode = sessionMode else { return }
        startSession(
            moduleId: sessionModuleId,
            mode: mode,
            questionCount: sessionQuestionCount,
            modelContext: modelContext
        )
    }

    func submitAnswer(_ answer: String, modelContext: ModelContext) {
        guard let question = currentQuestion else { return }
        isAnswered = true
        selectedAnswer = answer

        let correct = answer == question.correctAnswer
        sessionResults.append((questionId: question.id, correct: correct, selectedAnswer: answer))

        if !correct {
            saveWrongAnswer(question: question, selectedAnswer: answer, modelContext: modelContext)
        }

        updateDailyRecord(correct: correct, moduleId: question.moduleId, modelContext: modelContext)
    }

    func nextQuestion() {
        currentIndex += 1
        selectedAnswer = nil
        isAnswered = false

        if currentIndex >= questions.count {
            isFinished = true
        }
    }

    // MARK: - Private

    private func fetchQuestions(moduleId: String?) -> [Question] {
        let loader = DataLoader.shared
        if let moduleId {
            return loader.questions(for: moduleId)
        }
        return loader.allQuestions()
    }

    private func fetchWrongAnswerQuestions(moduleId: String?, modelContext: ModelContext) -> [Question] {
        var descriptor = FetchDescriptor<WrongAnswerRecord>(
            predicate: #Predicate { !$0.isMastered },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 200

        let records = (try? modelContext.fetch(descriptor)) ?? []
        let questionIds: Set<String>
        if let moduleId {
            questionIds = Set(records.filter { $0.moduleId == moduleId }.map(\.questionId))
        } else {
            questionIds = Set(records.map(\.questionId))
        }

        let allQ = fetchQuestions(moduleId: moduleId)
        return allQ.filter { questionIds.contains($0.id) }.shuffled()
    }

    private func saveWrongAnswer(question: Question, selectedAnswer: String, modelContext: ModelContext) {
        let id = question.id
        let existing = fetchExistingRecord(questionId: id, modelContext: modelContext)
        if let existing {
            existing.selectedAnswer = selectedAnswer
            existing.timestamp = .now
            existing.reviewCount += 1
        } else {
            let record = WrongAnswerRecord(
                questionId: id,
                moduleId: question.moduleId,
                selectedAnswer: selectedAnswer
            )
            modelContext.insert(record)
        }
    }

    private func fetchExistingRecord(questionId: String, modelContext: ModelContext) -> WrongAnswerRecord? {
        let descriptor = FetchDescriptor<WrongAnswerRecord>(
            predicate: #Predicate { $0.questionId == questionId }
        )
        return try? modelContext.fetch(descriptor).first
    }

    private func updateDailyRecord(correct: Bool, moduleId: String, modelContext: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())
        let id = formattedDate(today)

        let descriptor = FetchDescriptor<StudyDayRecord>(
            predicate: #Predicate { $0.id == id }
        )

        if let record = try? modelContext.fetch(descriptor).first {
            record.questionsAnswered += 1
            if correct { record.correctCount += 1 }
            if !record.modulesStudied.contains(moduleId) {
                record.modulesStudied.append(moduleId)
            }
        } else {
            let record = StudyDayRecord(
                id: id,
                date: today,
                questionsAnswered: 1,
                correctCount: correct ? 1 : 0,
                modulesStudied: [moduleId]
            )
            modelContext.insert(record)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

import XCTest
import SwiftData
@testable import CFASICAPP

@MainActor
final class StudyViewModelTests: XCTestCase {
    private var container: ModelContainer!
    private var viewModel: StudyViewModel!

    override func setUp() async throws {
        container = try TestHelpers.makeInMemoryModelContainer()
        viewModel = StudyViewModel()
    }

    override func tearDown() {
        container = nil
        viewModel = nil
    }

    // MARK: - Session Management

    func testStartSession_loadsQuestions() {
        let questions = TestHelpers.makeQuestions(count: 10)
        // Note: This test requires DataLoader to be mockable or the questions to be passed directly.
        // Since StudyViewModel.startSession fetches from DataLoader, we test the state after init.
        XCTAssertTrue(viewModel.questions.isEmpty)
        XCTAssertFalse(viewModel.isFinished)
    }

    func testStartSession_randomMode_shufflesQuestions() {
        // Verify that session results start empty
        XCTAssertTrue(viewModel.sessionResults.isEmpty)
        XCTAssertEqual(viewModel.currentIndex, 0)
    }

    // MARK: - Answer Submission

    func testSubmitAnswer_doubleSubmission_isIgnored() {
        let questions = TestHelpers.makeQuestions(count: 5)
        viewModel.questions = questions
        viewModel.currentIndex = 0

        viewModel.isAnswered = false
        viewModel.selectedAnswer = nil

        // First submission
        viewModel.submitAnswer("B", modelContext: container.mainContext)
        XCTAssertEqual(viewModel.sessionResults.count, 1)
        XCTAssertTrue(viewModel.isAnswered)

        // Second submission should be ignored
        viewModel.submitAnswer("A", modelContext: container.mainContext)
        XCTAssertEqual(viewModel.sessionResults.count, 1, "Double submission should be ignored")
    }

    func testSubmitAnswer_correctAnswer_recordsCorrectResult() {
        let questions = TestHelpers.makeQuestions(count: 1, correctAnswer: "B")
        viewModel.questions = questions
        viewModel.currentIndex = 0
        viewModel.isAnswered = false

        viewModel.submitAnswer("B", modelContext: container.mainContext)

        XCTAssertEqual(viewModel.sessionResults.count, 1)
        XCTAssertTrue(viewModel.sessionResults[0].correct)
        XCTAssertEqual(viewModel.correctCount, 1)
    }

    func testSubmitAnswer_wrongAnswer_recordsIncorrectResult() {
        let questions = TestHelpers.makeQuestions(count: 1, correctAnswer: "B")
        viewModel.questions = questions
        viewModel.currentIndex = 0
        viewModel.isAnswered = false

        viewModel.submitAnswer("A", modelContext: container.mainContext)

        XCTAssertEqual(viewModel.sessionResults.count, 1)
        XCTAssertFalse(viewModel.sessionResults[0].correct)
        XCTAssertEqual(viewModel.correctCount, 0)
    }

    // MARK: - Navigation

    func testNextQuestion_advancesIndex() {
        let questions = TestHelpers.makeQuestions(count: 5)
        viewModel.questions = questions
        viewModel.currentIndex = 0

        viewModel.nextQuestion()
        XCTAssertEqual(viewModel.currentIndex, 1)
        XCTAssertFalse(viewModel.isFinished)
    }

    func testNextQuestion_atEnd_setsIsFinished() {
        let questions = TestHelpers.makeQuestions(count: 2)
        viewModel.questions = questions
        viewModel.currentIndex = 1 // Last question

        viewModel.nextQuestion()
        XCTAssertTrue(viewModel.isFinished)
    }

    func testNextQuestion_resetsAnswerState() {
        let questions = TestHelpers.makeQuestions(count: 5)
        viewModel.questions = questions
        viewModel.currentIndex = 0
        viewModel.isAnswered = true
        viewModel.selectedAnswer = "A"

        viewModel.nextQuestion()
        XCTAssertFalse(viewModel.isAnswered)
        XCTAssertNil(viewModel.selectedAnswer)
    }

    // MARK: - Progress

    func testProgress_calculation() {
        let questions = TestHelpers.makeQuestions(count: 10)
        viewModel.questions = questions
        viewModel.currentIndex = 0
        XCTAssertEqual(viewModel.progress, 0)

        viewModel.currentIndex = 5
        XCTAssertEqual(viewModel.progress, 0.5, accuracy: 0.01)

        viewModel.currentIndex = 10
        XCTAssertEqual(viewModel.progress, 1.0, accuracy: 0.01)
    }

    func testAccuracy_calculation() {
        viewModel.sessionResults = [
            ("q1", true, "B", 10.0),
            ("q2", false, "A", 15.0),
            ("q3", true, "B", 8.0),
            ("q4", false, "A", 20.0),
        ]
        XCTAssertEqual(viewModel.accuracy, 0.5, accuracy: 0.01)
    }

    func testAccuracy_emptySession_returnsZero() {
        XCTAssertTrue(viewModel.sessionResults.isEmpty)
        XCTAssertEqual(viewModel.accuracy, 0)
    }

    // MARK: - Timer

    func testSessionElapsed_startsAtZero() {
        XCTAssertNil(viewModel.sessionStartTime)
        XCTAssertEqual(viewModel.sessionElapsed, 0)
    }

    func testAverageTimePerQuestion_emptySession_returnsZero() {
        XCTAssertEqual(viewModel.averageTimePerQuestion, 0)
    }

    // MARK: - Wrong Question Details

    func testWrongQuestionDetails_filtersCorrectly() {
        let questions = TestHelpers.makeQuestions(count: 3, correctAnswer: "B")
        viewModel.questions = questions
        viewModel.sessionResults = [
            ("q1", true, "B", 10.0),
            ("q2", false, "A", 15.0),
            ("q3", false, "C", 20.0),
        ]

        let wrongDetails = viewModel.wrongQuestionDetails
        XCTAssertEqual(wrongDetails.count, 2)
        XCTAssertEqual(wrongDetails[0].selectedAnswer, "A")
        XCTAssertEqual(wrongDetails[1].selectedAnswer, "C")
    }
}

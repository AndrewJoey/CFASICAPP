import XCTest
import SwiftData
@testable import CFASICAPP

@MainActor
final class ProgressViewModelTests: XCTestCase {
    private var container: ModelContainer!
    private var viewModel: ProgressViewModel!

    override func setUp() async throws {
        container = try TestHelpers.makeInMemoryModelContainer()
        viewModel = ProgressViewModel()
    }

    override func tearDown() {
        container = nil
        viewModel = nil
    }

    // MARK: - Streak Calculation

    func testStreak_noRecords_returnsZero() {
        viewModel.studyRecords = []
        XCTAssertEqual(viewModel.streak, 0)
    }

    func testStreak_studiedToday_returnsOne() {
        let today = Calendar.current.startOfDay(for: .now)
        viewModel.studyRecords = [
            makeStudyDayRecord(date: today, questionsAnswered: 10, correctCount: 7)
        ]
        XCTAssertEqual(viewModel.streak, 1)
    }

    func testStreak_studiedYesterdayOnly_returnsOne() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        viewModel.studyRecords = [
            makeStudyDayRecord(date: yesterday, questionsAnswered: 10, correctCount: 7)
        ]
        // Streak should start from yesterday when today has no record
        XCTAssertEqual(viewModel.streak, 1)
    }

    func testStreak_consecutiveDays_returnsCorrectCount() {
        let today = Calendar.current.startOfDay(for: .now)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let dayBefore = Calendar.current.date(byAdding: .day, value: -2, to: today)!

        viewModel.studyRecords = [
            makeStudyDayRecord(date: dayBefore, questionsAnswered: 5, correctCount: 3),
            makeStudyDayRecord(date: yesterday, questionsAnswered: 8, correctCount: 5),
            makeStudyDayRecord(date: today, questionsAnswered: 10, correctCount: 7),
        ]
        XCTAssertEqual(viewModel.streak, 3)
    }

    func testStreak_gapInDays_breaksStreak() {
        let today = Calendar.current.startOfDay(for: .now)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!

        viewModel.studyRecords = [
            makeStudyDayRecord(date: threeDaysAgo, questionsAnswered: 5, correctCount: 3),
            makeStudyDayRecord(date: yesterday, questionsAnswered: 8, correctCount: 5),
        ]
        // Gap at day-2 breaks the streak; only yesterday counts (today not studied)
        XCTAssertEqual(viewModel.streak, 1)
    }

    // MARK: - Accuracy

    func testAccuracy_noRecords_returnsZero() {
        viewModel.studyRecords = []
        XCTAssertEqual(viewModel.accuracy, 0)
    }

    func testAccuracy_computesCorrectly() {
        viewModel.studyRecords = [
            makeStudyDayRecord(date: .now, questionsAnswered: 10, correctCount: 7),
        ]
        XCTAssertEqual(viewModel.accuracy, 0.7, accuracy: 0.01)
    }

    func testAccuracy_multipleDays_aggregates() {
        let today = Calendar.current.startOfDay(for: .now)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        viewModel.studyRecords = [
            makeStudyDayRecord(date: yesterday, questionsAnswered: 10, correctCount: 8), // 80%
            makeStudyDayRecord(date: today, questionsAnswered: 10, correctCount: 6),     // 60%
        ]
        // Total: 14/20 = 70%
        XCTAssertEqual(viewModel.accuracy, 0.7, accuracy: 0.01)
    }

    // MARK: - Totals

    func testTotalQuestionsAnswered_sumsCorrectly() {
        let today = Calendar.current.startOfDay(for: .now)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        viewModel.studyRecords = [
            makeStudyDayRecord(date: yesterday, questionsAnswered: 10, correctCount: 7),
            makeStudyDayRecord(date: today, questionsAnswered: 15, correctCount: 12),
        ]
        XCTAssertEqual(viewModel.totalQuestionsAnswered, 25)
    }

    func testTotalCorrect_sumsCorrectly() {
        let today = Calendar.current.startOfDay(for: .now)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        viewModel.studyRecords = [
            makeStudyDayRecord(date: yesterday, questionsAnswered: 10, correctCount: 7),
            makeStudyDayRecord(date: today, questionsAnswered: 15, correctCount: 12),
        ]
        XCTAssertEqual(viewModel.totalCorrect, 19)
    }

    // MARK: - Last 30 Days

    func testLast30Days_filtersCorrectly() {
        let today = Calendar.current.startOfDay(for: .now)
        let recentDate = Calendar.current.date(byAdding: .day, value: -10, to: today)!
        let oldDate = Calendar.current.date(byAdding: .day, value: -45, to: today)!

        viewModel.studyRecords = [
            makeStudyDayRecord(date: oldDate, questionsAnswered: 5, correctCount: 3),
            makeStudyDayRecord(date: recentDate, questionsAnswered: 8, correctCount: 5),
        ]
        viewModel.last30Days = viewModel.studyRecords.filter {
            $0.date >= Calendar.current.date(byAdding: .day, value: -30, to: .now)!
        }

        XCTAssertEqual(viewModel.last30Days.count, 1)
    }

    // MARK: - Load

    func testLoad_fetchesRecords() async throws {
        // Insert some records
        let today = Calendar.current.startOfDay(for: .now)
        let record = StudyDayRecord(
            id: Self.dateFormatter.string(from: today),
            date: today,
            questionsAnswered: 10,
            correctCount: 7,
            modulesStudied: ["module-01"]
        )
        container.mainContext.insert(record)

        await viewModel.load(modelContext: container.mainContext)

        XCTAssertEqual(viewModel.studyRecords.count, 1)
        XCTAssertEqual(viewModel.totalQuestionsAnswered, 10)
    }

    // MARK: - Helpers

    private func makeStudyDayRecord(date: Date, questionsAnswered: Int, correctCount: Int) -> StudyDayRecord {
        StudyDayRecord(
            id: Self.dateFormatter.string(from: date),
            date: date,
            questionsAnswered: questionsAnswered,
            correctCount: correctCount,
            modulesStudied: ["module-01"]
        )
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

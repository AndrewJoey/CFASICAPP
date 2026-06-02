import XCTest
@testable import CFASICAPP

final class SM2AlgorithmTests: XCTestCase {

    // MARK: - Correct Answer Tests

    func testCorrectFastAnswer_increasesInterval() {
        let result = SM2Algorithm.calculateNextReview(
            isCorrect: true,
            elapsedSeconds: 5,
            currentEaseFactor: 2.5,
            currentInterval: 1
        )
        // Quality 5 (correct + fast < 10s), first interval should be 6
        XCTAssertEqual(result.intervalDays, 6)
        XCTAssertTrue(result.nextReviewDate > .now)
        XCTAssertTrue(result.easeFactor > 2.5) // EF should increase for Q5
    }

    func testCorrectNormalAnswer_standardIntervalIncrease() {
        let result = SM2Algorithm.calculateNextReview(
            isCorrect: true,
            elapsedSeconds: 15,
            currentEaseFactor: 2.5,
            currentInterval: 6
        )
        // Quality 4 (correct + 10-30s), interval = round(6 * EF)
        XCTAssertEqual(result.intervalDays, Int(round(6 * result.easeFactor)))
    }

    func testCorrectSlowAnswer_smallIntervalIncrease() {
        let result = SM2Algorithm.calculateNextReview(
            isCorrect: true,
            elapsedSeconds: 45,
            currentEaseFactor: 2.5,
            currentInterval: 10
        )
        // Quality 3 (correct + slow > 30s)
        // EF should be slightly lower than for fast answers
        let fastResult = SM2Algorithm.calculateNextReview(
            isCorrect: true,
            elapsedSeconds: 5,
            currentEaseFactor: 2.5,
            currentInterval: 10
        )
        XCTAssertTrue(result.easeFactor < fastResult.easeFactor)
    }

    // MARK: - Incorrect Answer Tests

    func testIncorrectAnswer_resetsInterval() {
        let result = SM2Algorithm.calculateNextReview(
            isCorrect: false,
            elapsedSeconds: 20,
            currentEaseFactor: 2.5,
            currentInterval: 15
        )
        // Quality 1 (incorrect), interval resets to 1
        XCTAssertEqual(result.intervalDays, 1)
    }

    func testIncorrectFastAnswer_lowersEaseFactor() {
        let result = SM2Algorithm.calculateNextReview(
            isCorrect: false,
            elapsedSeconds: 3,
            currentEaseFactor: 2.5,
            currentInterval: 10
        )
        // Quality 0 (incorrect + fast < 5s), EF should drop more
        let slowIncorrect = SM2Algorithm.calculateNextReview(
            isCorrect: false,
            elapsedSeconds: 15,
            currentEaseFactor: 2.5,
            currentInterval: 10
        )
        XCTAssertTrue(result.easeFactor < slowIncorrect.easeFactor)
        XCTAssertEqual(result.intervalDays, 1)
    }

    // MARK: - Ease Factor Bounds

    func testEaseFactor_minimumBound() {
        // Even with many wrong answers, EF should not drop below 1.3
        var ef = 2.5
        for _ in 0..<20 {
            let result = SM2Algorithm.calculateNextReview(
                isCorrect: false,
                elapsedSeconds: 3,
                currentEaseFactor: ef,
                currentInterval: 1
            )
            ef = result.easeFactor
        }
        XCTAssertTrue(ef >= 1.3, "Ease factor should not drop below 1.3, got \(ef)")
    }

    // MARK: - Repeated Correct Answers

    func testRepeatedCorrectAnswers_exponentialGrowth() {
        var interval = 1
        var ef = 2.5
        var previousInterval = interval

        for _ in 0..<5 {
            let result = SM2Algorithm.calculateNextReview(
                isCorrect: true,
                elapsedSeconds: 10,
                currentEaseFactor: ef,
                currentInterval: interval
            )
            previousInterval = interval
            interval = result.intervalDays
            ef = result.easeFactor
        }

        // After 5 correct answers, interval should have grown significantly
        XCTAssertTrue(interval > previousInterval)
        XCTAssertTrue(interval > 10, "Interval should grow substantially after repeated correct answers, got \(interval)")
    }

    // MARK: - Next Review Date

    func testNextReviewDate_isInTheFuture() {
        let result = SM2Algorithm.calculateNextReview(
            isCorrect: true,
            elapsedSeconds: 10,
            currentEaseFactor: 2.5,
            currentInterval: 1
        )
        XCTAssertTrue(result.nextReviewDate > Date.now)
    }

    func testNextReviewDate_respectsInterval() {
        let result = SM2Algorithm.calculateNextReview(
            isCorrect: true,
            elapsedSeconds: 10,
            currentEaseFactor: 2.5,
            currentInterval: 1
        )
        let expectedDate = Calendar.current.date(byAdding: .day, value: result.intervalDays, to: .now)!
        let tolerance: TimeInterval = 2 // 2 second tolerance
        XCTAssertTrue(abs(result.nextReviewDate.timeIntervalSince(expectedDate)) < tolerance)
    }
}

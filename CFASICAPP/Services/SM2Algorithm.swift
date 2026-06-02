import Foundation

/// Simplified SM-2 spaced repetition algorithm.
///
/// Quality mapping:
/// - 5: correct + fast (< 10s) — aggressive interval increase
/// - 4: correct + normal speed — standard interval increase
/// - 3: correct + slow (> 30s) — small interval increase
/// - 1: incorrect — reset interval to 1 day
/// - 0: incorrect + fast (< 5s, likely guessed) — reset + lower ease factor
enum SM2Algorithm {
    struct Result {
        let nextReviewDate: Date
        let easeFactor: Double
        let intervalDays: Int
    }

    /// Calculate the next review schedule based on answer quality.
    static func calculateNextReview(
        isCorrect: Bool,
        elapsedSeconds: TimeInterval,
        currentEaseFactor: Double,
        currentInterval: Int
    ) -> Result {
        let quality = mapQuality(isCorrect: isCorrect, elapsedSeconds: elapsedSeconds)

        let newEaseFactor: Double
        let newInterval: Int

        if quality >= 3 {
            // Correct answer — increase interval
            newEaseFactor = max(1.3, currentEaseFactor + (0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02)))
            if currentInterval <= 1 {
                newInterval = 6
            } else if currentInterval <= 6 {
                newInterval = Int(round(Double(currentInterval) * newEaseFactor))
            } else {
                newInterval = Int(round(Double(currentInterval) * newEaseFactor))
            }
        } else {
            // Incorrect — reset interval, optionally lower ease factor
            newEaseFactor = quality == 0 ? max(1.3, currentEaseFactor - 0.2) : max(1.3, currentEaseFactor - 0.15)
            newInterval = 1
        }

        let nextDate = Calendar.current.date(byAdding: .day, value: newInterval, to: .now) ?? .now

        return Result(
            nextReviewDate: nextDate,
            easeFactor: newEaseFactor,
            intervalDays: newInterval
        )
    }

    /// Map answer correctness and speed to SM-2 quality (0-5).
    private static func mapQuality(isCorrect: Bool, elapsedSeconds: TimeInterval) -> Int {
        if isCorrect {
            if elapsedSeconds < 10 { return 5 }
            if elapsedSeconds <= 30 { return 4 }
            return 3
        } else {
            return elapsedSeconds < 5 ? 0 : 1
        }
    }
}

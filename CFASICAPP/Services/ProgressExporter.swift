import Foundation
import SwiftUI

enum ProgressExporter {
    static func generateTextSummary(
        streak: Int,
        totalQuestions: Int,
        accuracy: Double,
        wrongAnswersPending: Int,
        masteredCount: Int
    ) -> String {
        let accuracyPercent = Int(accuracy * 100)
        return """
        📚 CFA-SIC 学习进度报告

        🔥 连续学习：\(streak) 天
        📝 总答题数：\(totalQuestions) 题
        ✅ 正确率：\(accuracyPercent)%
        ❌ 待复习错题：\(wrongAnswersPending) 题
        🎯 已掌握：\(masteredCount) 题

        —— 来自 CFA-SIC 备考 App
        """
    }

    @MainActor
    static func generateShareImage(
        streak: Int,
        totalQuestions: Int,
        accuracy: Double,
        wrongAnswersPending: Int,
        masteredCount: Int
    ) -> UIImage {
        let view = ProgressShareCard(
            streak: streak,
            totalQuestions: totalQuestions,
            accuracy: accuracy,
            wrongAnswersPending: wrongAnswersPending,
            masteredCount: masteredCount
        )
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3 // 3x for high quality
        return renderer.uiImage ?? UIImage()
    }
}

// MARK: - Share Card View (rendered to image)

private struct ProgressShareCard: View {
    let streak: Int
    let totalQuestions: Int
    let accuracy: Double
    let wrongAnswersPending: Int
    let masteredCount: Int

    private var accuracyPercent: Int { Int(accuracy * 100) }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.15, blue: 0.3), Color(red: 0.05, green: 0.08, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 28) {
                // Header
                VStack(spacing: 6) {
                    Text("CFA-SIC")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                    Text("学习进度报告")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.top, 32)

                // Streak hero
                VStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 40))
                    Text("\(streak)")
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundStyle(.orange)
                    Text("天连续学习")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }

                // Stats grid
                HStack(spacing: 16) {
                    StatBlock(icon: "pencil.circle.fill", value: "\(totalQuestions)", label: "总答题", color: .blue)
                    StatBlock(icon: "checkmark.circle.fill", value: "\(accuracyPercent)%", label: "正确率", color: .green)
                    StatBlock(icon: "xmark.circle.fill", value: "\(wrongAnswersPending)", label: "待复习", color: .red)
                    StatBlock(icon: "star.circle.fill", value: "\(masteredCount)", label: "已掌握", color: .yellow)
                }
                .padding(.horizontal, 24)

                // Footer
                Text("—— 来自 CFA-SIC 备考 App ——")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.bottom, 28)
            }
        }
        .frame(width: 360, height: 520)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

private struct StatBlock: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

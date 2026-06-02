import SwiftUI

struct QuizResultView: View {
    let viewModel: StudyViewModel
    let onDismiss: () -> Void
    let onRetry: () -> Void

    @State private var showReviewSheet = false
    @State private var reviewInitialIndex = 0

    private var wrongQuestions: [(index: Int, question: Question)] {
        viewModel.questions.enumerated().filter { index, _ in
            index < viewModel.sessionResults.count && !viewModel.sessionResults[index].correct
        }.map { (index: $0.offset, question: $0.element) }
    }

    private var totalSessionTime: TimeInterval {
        viewModel.sessionResults.reduce(0) { $0 + $1.elapsedSeconds }
    }

    private var emoji: String {
        let acc = viewModel.accuracy
        if acc >= 0.9 { return "🎉" }
        if acc >= 0.7 { return "👍" }
        if acc >= 0.5 { return "💪" }
        return "📚"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(emoji)
                    .font(.system(size: 64))

                Text("练习完成")
                    .font(.title)
                    .bold()

                // Score card
                VStack(spacing: 12) {
                    HStack(spacing: 32) {
                        StatItem(value: "\(viewModel.correctCount)", label: "正确")
                        StatItem(value: "\(viewModel.sessionResults.count - viewModel.correctCount)", label: "错误")
                        StatItem(value: "\(Int(viewModel.accuracy * 100))%", label: "正确率")
                        StatItem(value: formatTime(viewModel.averageTimePerQuestion), label: "平均用时")
                    }
                    HStack(spacing: 12) {
                        StatItem(value: formatTime(totalSessionTime), label: "总用时")
                        Spacer()
                    }
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(16)

                // Wrong questions list
                if !wrongQuestions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("错题回顾")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(Array(wrongQuestions.enumerated()), id: \.element.index) { _, item in
                            let (index, question) = item
                            Button {
                                if let reviewIdx = viewModel.wrongQuestionDetails.firstIndex(where: { $0.question.id == question.id }) {
                                    reviewInitialIndex = reviewIdx
                                    showReviewSheet = true
                                }
                            } label: {
                                HStack(alignment: .top) {
                                    Text("Q\(question.number)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 36, alignment: .leading)
                                    Text(question.text.display)
                                        .font(.subheadline)
                                        .lineLimit(2)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                if !viewModel.wrongQuestionDetails.isEmpty {
                    Button {
                        reviewInitialIndex = 0
                        showReviewSheet = true
                    } label: {
                        Label("回顾错题 (\(viewModel.wrongQuestionDetails.count)题)", systemImage: "arrow.trianglehead.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                Button {
                    onRetry()
                } label: {
                    Label("再来一次", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    onDismiss()
                } label: {
                    Label("返回首页", systemImage: "house.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showReviewSheet) {
            WrongQuestionReviewView(
                wrongQuestions: viewModel.wrongQuestionDetails,
                initialIndex: reviewInitialIndex
            )
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        if seconds < 60 {
            return String(format: "%.0fs", seconds)
        }
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

private struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .bold()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

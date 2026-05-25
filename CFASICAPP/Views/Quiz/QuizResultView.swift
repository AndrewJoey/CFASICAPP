import SwiftUI

struct QuizResultView: View {
    let viewModel: StudyViewModel

    private var emoji: String {
        let acc = viewModel.accuracy
        if acc >= 0.9 { return "🎉" }
        if acc >= 0.7 { return "👍" }
        if acc >= 0.5 { return "💪" }
        return "📚"
    }

    var body: some View {
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
                }
            }
            .padding(20)
            .background(Color(.systemGray6))
            .cornerRadius(16)

            // Per-module breakdown
            if !viewModel.sessionResults.isEmpty {
                let wrongQuestions = viewModel.questions.enumerated().filter { index, _ in
                    index < viewModel.sessionResults.count && !viewModel.sessionResults[index].correct
                }

                if !wrongQuestions.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("错题回顾")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(wrongQuestions, id: \.offset) { index, question in
                            HStack(alignment: .top) {
                                Text("Q\(question.number)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 36, alignment: .leading)
                                Text(question.text.display)
                                    .font(.subheadline)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .alignmentHorizontal(.leading)
                }
            }

            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden()
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

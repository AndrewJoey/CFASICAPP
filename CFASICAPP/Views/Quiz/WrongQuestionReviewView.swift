import SwiftUI

struct WrongQuestionReviewView: View {
    let wrongQuestions: [(question: Question, selectedAnswer: String)]
    let initialIndex: Int

    @State private var currentIndex: Int
    @Environment(\.dismiss) private var dismiss

    init(wrongQuestions: [(question: Question, selectedAnswer: String)], initialIndex: Int) {
        self.wrongQuestions = wrongQuestions
        self.initialIndex = initialIndex
        self._currentIndex = State(initialValue: initialIndex)
    }

    private var current: (question: Question, selectedAnswer: String)? {
        guard currentIndex >= 0, currentIndex < wrongQuestions.count else { return nil }
        return wrongQuestions[currentIndex]
    }

    var body: some View {
        NavigationStack {
            if wrongQuestions.isEmpty {
                ContentUnavailableView(
                    "没有错题",
                    systemImage: "checkmark.circle",
                    description: Text("全部正确，太棒了！")
                )
            } else if let item = current {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Topic badge
                        if let topic = item.question.topic?.display {
                            Text(topic)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.secondary.opacity(0.1))
                                .cornerRadius(6)
                        }

                        // Question text
                        Text(item.question.text.display)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)

                        // Options
                        VStack(spacing: 12) {
                            ForEach(item.question.options) { option in
                                optionReviewView(option, correct: item.question.correctAnswer, selected: item.selectedAnswer)
                            }
                        }

                        // Explanation
                        explanationSection(item.question)
                    }
                    .padding()
                }
                .safeAreaInset(edge: .bottom) {
                    bottomBar
                }
            }

        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("关闭") {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Option review

    @ViewBuilder
    private func optionReviewView(_ option: QuestionOption, correct: String, selected: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(option.label)
                .font(.headline)
                .frame(width: 28, height: 28)
                .background(optionBackground(option.label, correct: correct, selected: selected))
                .foregroundStyle(optionForeground(option.label, correct: correct, selected: selected))
                .clipShape(Circle())

            Text(option.text.display)
                .font(.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            if option.label == correct {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else if option.label == selected {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(12)
        .background(optionCardBackground(option.label, correct: correct, selected: selected))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(optionBorder(option.label, correct: correct, selected: selected), lineWidth: 1.5)
        )
    }

    // MARK: - Explanation

    @ViewBuilder
    private func explanationSection(_ question: Question) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("解析")
                    .font(.headline)
            }

            if let explanation = question.explanation?.display {
                Text(explanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Bottom bar

    private var bottomBar: some View {
        HStack {
            Button {
                if currentIndex > 0 {
                    currentIndex -= 1
                }
            } label: {
                Label("上一题", systemImage: "chevron.left")
            }
            .disabled(currentIndex <= 0)

            Spacer()

            Text("\(currentIndex + 1) / \(wrongQuestions.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                if currentIndex < wrongQuestions.count - 1 {
                    currentIndex += 1
                }
            } label: {
                Label("下一题", systemImage: "chevron.right")
            }
            .disabled(currentIndex >= wrongQuestions.count - 1)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }

    // MARK: - Color helpers

    private func optionBackground(_ label: String, correct: String, selected: String) -> Color {
        if label == correct { return .green }
        if label == selected { return .red }
        return Color(.systemGray5)
    }

    private func optionForeground(_ label: String, correct: String, selected: String) -> Color {
        if label == correct || label == selected { return .white }
        return .secondary
    }

    private func optionCardBackground(_ label: String, correct: String, selected: String) -> Color {
        if label == correct { return Color.green.opacity(0.08) }
        if label == selected { return Color.red.opacity(0.08) }
        return Color(.systemBackground)
    }

    private func optionBorder(_ label: String, correct: String, selected: String) -> Color {
        if label == correct { return .green }
        if label == selected { return .red }
        return Color(.systemGray4)
    }
}

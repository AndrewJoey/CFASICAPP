import SwiftUI
import SwiftData

struct QuizSessionView: View {
    @Bindable var viewModel: StudyViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showResult = false

    var body: some View {
        Group {
            if viewModel.isFinished {
                QuizResultView(viewModel: viewModel)
            } else if let question = viewModel.currentQuestion {
                questionView(question)
            }
        }
        .navigationTitle("第 \(viewModel.currentIndex + 1)/\(viewModel.questions.count) 题")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func questionView(_ question: Question) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Progress bar
                ProgressView(value: viewModel.progress)
                    .tint(.blue)

                // Topic badge
                if let topic = question.topic?.display {
                    Text(topic)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.secondary.opacity(0.1))
                        .cornerRadius(6)
                }

                // Question text
                Text(question.text.display)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                // Options
                VStack(spacing: 12) {
                    ForEach(question.options) { option in
                        optionButton(option, question: question)
                    }
                }

                // Explanation (after answering)
                if viewModel.isAnswered {
                    explanationSection(question)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func optionButton(_ option: QuestionOption, question: Question) -> some View {
        Button {
            guard !viewModel.isAnswered else { return }
            viewModel.submitAnswer(option.label, modelContext: modelContext)
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Text(option.label)
                    .font(.headline)
                    .frame(width: 28, height: 28)
                    .background(optionBackground(option.label, correct: question.correctAnswer))
                    .foregroundStyle(optionForeground(option.label, correct: question.correctAnswer))
                    .clipShape(Circle())

                Text(option.text.display)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(optionCardBackground(option.label, correct: question.correctAnswer))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(optionBorder(option.label, correct: question.correctAnswer), lineWidth: 1.5)
            )
        }
        .disabled(viewModel.isAnswered)
    }

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

            Button {
                viewModel.nextQuestion()
            } label: {
                Text(viewModel.currentIndex + 1 < viewModel.questions.count ? "下一题" : "查看结果")
                    .frame(maxWidth: .infinity)
                    .bold()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Color helpers

    private func optionBackground(_ label: String, correct: String) -> Color {
        if !viewModel.isAnswered { return Color(.systemGray5) }
        if label == correct { return .green }
        if label == viewModel.selectedAnswer { return .red }
        return Color(.systemGray5)
    }

    private func optionForeground(_ label: String, correct: String) -> Color {
        if !viewModel.isAnswered { return .primary }
        if label == correct || label == viewModel.selectedAnswer { return .white }
        return .secondary
    }

    private func optionCardBackground(_ label: String, correct: String) -> Color {
        if !viewModel.isAnswered { return Color(.systemBackground) }
        if label == correct { return Color.green.opacity(0.08) }
        if label == viewModel.selectedAnswer { return Color.red.opacity(0.08) }
        return Color(.systemBackground)
    }

    private func optionBorder(_ label: String, correct: String) -> Color {
        if !viewModel.isAnswered { return Color(.systemGray4) }
        if label == correct { return .green }
        if label == viewModel.selectedAnswer { return .red }
        return Color(.systemGray4)
    }
}

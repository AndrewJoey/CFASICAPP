import SwiftUI
import SwiftData
import Charts

struct ProgressDashboardView: View {
    @State private var viewModel = ProgressViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Streak card
                streakCard

                // Stats grid
                HStack(spacing: 12) {
                    StatCard(value: "\(viewModel.totalQuestionsAnswered)", label: "总答题", icon: "questionmark.circle.fill", color: .blue)
                    StatCard(value: "\(Int(viewModel.accuracy * 100))%", label: "正确率", icon: "checkmark.circle.fill", color: .green)
                    StatCard(value: "\(viewModel.wrongAnswerCount)", label: "待复习错题", icon: "xmark.circle.fill", color: .red)
                }

                // Accuracy chart
                if !viewModel.last30Days.isEmpty {
                    accuracyChart
                }

                // Module progress
                moduleProgress
            }
            .padding()
        }
        .navigationTitle("学习进度")
        .task {
            viewModel.load(modelContext: modelContext)
        }
        .refreshable {
            viewModel.load(modelContext: modelContext)
        }
    }

    // MARK: - Streak

    private var streakCard: some View {
        VStack(spacing: 8) {
            Text("\(viewModel.streak)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)
            Text("天连续学习")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: - Accuracy chart

    private var accuracyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("近 30 天正确率")
                .font(.headline)

            Chart(viewModel.last30Days) { record in
                let accuracy = record.questionsAnswered > 0
                    ? Double(record.correctCount) / Double(record.questionsAnswered)
                    : 0
                LineMark(
                    x: .value("日期", record.date, unit: .day),
                    y: .value("正确率", accuracy)
                )
                .foregroundStyle(.blue)
                .interpolationMethod(.catmullRom)

                if record.questionsAnswered > 0 {
                    PointMark(
                        x: .value("日期", record.date, unit: .day),
                        y: .value("正确率", accuracy)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .chartYScale(domain: 0...1)
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 0.25, 0.5, 0.75, 1.0]) {
                    AxisValueLabel {
                        Text("\($0)")
                    }
                }
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }

    // MARK: - Module progress

    private var moduleProgress: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("各模块进度")
                .font(.headline)

            let dataLoader = DataLoader.shared
            ForEach(dataLoader.modules) { module in
                ModuleProgressRow(moduleId: module.id, title: "模块 \(module.number): \(module.title.display)")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}

private struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3)
                .bold()
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

private struct ModuleProgressRow: View {
    let moduleId: String
    let title: String
    @Query private var wrongAnswers: [WrongAnswerRecord]

    init(moduleId: String, title: String) {
        self.moduleId = moduleId
        self.title = title
        _wrongAnswers = Query(filter: #Predicate<WrongAnswerRecord> { $0.moduleId == moduleId })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
            HStack {
                Text("\(wrongAnswers.filter { !$0.isMastered }.count) 道错题")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if !wrongAnswers.isEmpty {
                    let mastered = wrongAnswers.filter(\.isMastered).count
                    Text("\(mastered)/\(wrongAnswers.count) 已掌握")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

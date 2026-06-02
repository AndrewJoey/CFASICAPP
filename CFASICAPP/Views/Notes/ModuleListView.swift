import SwiftUI
import SwiftData

struct ModuleListView: View {
    let dataLoader = DataLoader.shared
    @Query(sort: \WrongAnswerRecord.timestamp, order: .reverse) private var allWrongAnswers: [WrongAnswerRecord]

    private var totalWrongByModule: [String: Int] {
        Dictionary(grouping: allWrongAnswers.filter { !$0.isMastered }, by: \.moduleId)
            .mapValues(\.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Overview card
                overviewCard

                // Module cards
                ForEach(dataLoader.modules) { module in
                    NavigationLink {
                        MarkdownReaderView(module: module, moduleContent: module.content[0])
                    } label: {
                        ModuleCard(
                            module: module,
                            wrongCount: totalWrongByModule[module.id] ?? 0
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("CFA-SIC 备考")
    }

    private var overviewCard: some View {
        let totalQuestions = dataLoader.modules.reduce(0) { $0 + $1.questionCount }
        let totalWrong = totalWrongByModule.values.reduce(0, +)
        let modulesWithWrong = totalWrongByModule.keys.count

        return VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("学习概览")
                        .font(.headline)
                    Text("已学 \(modulesWithWrong)/\(dataLoader.modules.count) 模块")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(totalQuestions)")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.blue)
                    Text("总题数")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    Capsule()
                        .fill(Color.blue.gradient)
                        .frame(width: geo.size.width * CGFloat(modulesWithWrong) / CGFloat(max(dataLoader.modules.count, 1)), height: 6)
                }
            }
            .frame(height: 6)

            HStack {
                Label("\(totalWrong) 待复习", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
                Spacer()
                Label("\(dataLoader.modules.count) 模块", systemImage: "book.fill")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .adaptiveShadow()
    }
}

// MARK: - Module Card

struct ModuleCard: View {
    let module: ModuleInfo
    let wrongCount: Int

    private var moduleColors: [Color] {
        [.blue, .purple, .green, .orange, .teal, .indigo, .pink]
    }

    private var color: Color {
        moduleColors[(module.number - 1) % moduleColors.count]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(String(format: "%02d", module.number))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.9))
                        if let weight = module.examWeight {
                            Text(weight)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.white.opacity(0.2))
                                .cornerRadius(6)
                                .foregroundStyle(.white)
                        }
                    }
                    Text(module.title.display)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "book.fill")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            // Stats row
            HStack(spacing: 0) {
                StatBadge(
                    icon: "questionmark.circle.fill",
                    value: "\(module.questionCount)",
                    label: "题目",
                    color: .blue
                )
                Divider().frame(height: 24)
                StatBadge(
                    icon: "xmark.circle.fill",
                    value: "\(wrongCount)",
                    label: "错题",
                    color: wrongCount > 0 ? .red : .secondary
                )
                Divider().frame(height: 24)
                StatBadge(
                    icon: "doc.text.fill",
                    value: "\(module.content.count)",
                    label: "资料",
                    color: .green
                )
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.trailing, 12)
            }
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
        }
        .cornerRadius(14)
        .adaptiveShadow()
    }
}

private struct StatBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

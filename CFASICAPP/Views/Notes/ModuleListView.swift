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
                // Textbook entry card
                textbookCard

                // Module cards
                ForEach(dataLoader.modules) { module in
                    if let firstContent = module.content.first {
                        NavigationLink {
                            MarkdownReaderView(module: module, moduleContent: firstContent)
                        } label: {
                            ModuleCard(
                                module: module,
                                wrongCount: totalWrongByModule[module.id] ?? 0
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        ModuleCard(
                            module: module,
                            wrongCount: totalWrongByModule[module.id] ?? 0
                        )
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("CFA-SIC 备考")
    }

    // MARK: - Textbook card

    private var textbookCard: some View {
        let zhURL = DataLoader.shared.resolvePDF(relativePath: "content/textbook/2026v7CHNTB.pdf")
        let enURL = DataLoader.shared.resolvePDF(relativePath: "content/textbook/2026v7ENGTB.pdf")

        return NavigationLink {
            PDFReaderView(title: "原版教材", chineseURL: zhURL, englishURL: enURL)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "book.closed.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("浏览教材")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("CFA ESG Investing 原版教材（中英双语）")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .adaptiveShadow()
        }
        .buttonStyle(.plain)
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

import SwiftUI
import SwiftData

struct ErrorBookView: View {
    @Query(filter: #Predicate<WrongAnswerRecord> { !$0.isMastered },
           sort: \WrongAnswerRecord.timestamp,
           order: .reverse)
    private var wrongAnswers: [WrongAnswerRecord]

    @Environment(\.modelContext) private var modelContext
    @State private var showMastered = false
    @State private var selectedModule: String? = nil

    let dataLoader = DataLoader.shared

    var filteredRecords: [WrongAnswerRecord] {
        if let moduleId = selectedModule {
            return wrongAnswers.filter { $0.moduleId == moduleId }
        }
        return Array(wrongAnswers)
    }

    var groupedByModule: [(String, [WrongAnswerRecord])] {
        let grouped = Dictionary(grouping: filteredRecords, by: \.moduleId)
        return grouped.sorted { $0.key < $1.key }
    }

    var body: some View {
        Group {
            if wrongAnswers.isEmpty {
                ContentUnavailableView(
                    "没有错题",
                    systemImage: "checkmark.circle",
                    description: Text("练习中答错的题目会自动记录在这里")
                )
            } else {
                List {
                    // Module filter
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(label: "全部", isSelected: selectedModule == nil) {
                                    selectedModule = nil
                                }
                                ForEach(dataLoader.modules.filter { m in
                                    wrongAnswers.contains(where: { $0.moduleId == m.id })
                                }) { module in
                                    FilterChip(
                                        label: "模块 \(module.number)",
                                        isSelected: selectedModule == module.id
                                    ) {
                                        selectedModule = module.id
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    // Wrong answers grouped by module
                    ForEach(groupedByModule, id: \.0) { moduleId, records in
                        Section {
                            ForEach(records) { record in
                                WrongAnswerRow(record: record)
                            }
                        } header: {
                            if let module = dataLoader.module(by: moduleId) {
                                Text("模块 \(module.number): \(module.title.display)")
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("错题本")
        .toolbar {
            if !wrongAnswers.isEmpty {
                Menu {
                    Button("清除全部错题", role: .destructive) {
                        clearAll()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    private func clearAll() {
        for record in wrongAnswers {
            modelContext.delete(record)
        }
    }
}

private struct WrongAnswerRow: View {
    let record: WrongAnswerRecord
    let dataLoader = DataLoader.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let question = findQuestion() {
                Text(question.text.display)
                    .font(.subheadline)
                    .lineLimit(2)

                HStack {
                    Text("你选了 \(record.selectedAnswer)")
                        .font(.caption)
                        .foregroundStyle(.red)
                    Text("正确: \(question.correctAnswer)")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            } else {
                Text(record.questionId)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private func findQuestion() -> Question? {
        dataLoader.questions(for: record.moduleId)
            .first(where: { $0.id == record.questionId })
    }
}

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

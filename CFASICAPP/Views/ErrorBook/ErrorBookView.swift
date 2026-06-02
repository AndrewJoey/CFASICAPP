import SwiftUI
import SwiftData

struct ErrorBookView: View {
    @Query(filter: #Predicate<WrongAnswerRecord> { !$0.isMastered },
           sort: \WrongAnswerRecord.timestamp,
           order: .reverse)
    private var wrongAnswers: [WrongAnswerRecord]

    @Environment(\.modelContext) private var modelContext
    @State private var selectedModule: String? = nil
    @State private var showClearConfirmation = false
    @State private var showDueOnly = false

    let dataLoader = DataLoader.shared

    var dueForReviewCount: Int {
        let now = Date.now
        return wrongAnswers.filter { $0.nextReviewDate <= now }.count
    }

    var filteredRecords: [WrongAnswerRecord] {
        var records = Array(wrongAnswers)
        if showDueOnly {
            let now = Date.now
            records = records.filter { $0.nextReviewDate <= now }
        }
        if let moduleId = selectedModule {
            records = records.filter { $0.moduleId == moduleId }
        }
        return records
    }

    var groupedByModule: [(String, [WrongAnswerRecord])] {
        let grouped = Dictionary(grouping: filteredRecords, by: \.moduleId)
        return grouped.sorted { $0.key < $1.key }
    }

    // Pre-built question lookup cache for the current filtered set
    private var questionCache: [String: Question] {
        var cache: [String: Question] = [:]
        for moduleId in Set(filteredRecords.map(\.moduleId)) {
            for q in dataLoader.questions(for: moduleId) {
                cache[q.id] = q
            }
        }
        return cache
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
                let cache = questionCache
                List {
                    // Module filter
                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FilterChip(label: "全部", isSelected: !showDueOnly && selectedModule == nil) {
                                    showDueOnly = false
                                    selectedModule = nil
                                }
                                if dueForReviewCount > 0 {
                                    FilterChip(label: "待复习 (\(dueForReviewCount))", isSelected: showDueOnly) {
                                        showDueOnly.toggle()
                                        if showDueOnly { selectedModule = nil }
                                    }
                                }
                                ForEach(dataLoader.modules.filter { m in
                                    wrongAnswers.contains(where: { $0.moduleId == m.id })
                                }) { module in
                                    FilterChip(
                                        label: "模块 \(module.number)",
                                        isSelected: selectedModule == module.id
                                    ) {
                                        selectedModule = module.id
                                        showDueOnly = false
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
                                WrongAnswerRow(record: record, question: cache[record.questionId])
                            }
                            .onDelete { indexSet in
                                deleteRecords(records, at: indexSet)
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
                    Button("标记全部已掌握", role: .destructive) {
                        markAllMastered()
                    }
                    Button("清除全部错题", role: .destructive) {
                        showClearConfirmation = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("确认清除全部错题", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("清除全部", role: .destructive) { clearAll() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作不可撤销，共 \(wrongAnswers.count) 条错题将被删除")
        }
    }

    private func deleteRecords(_ records: [WrongAnswerRecord], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(records[index])
        }
    }

    private func markAllMastered() {
        for record in wrongAnswers {
            record.isMastered = true
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
    let question: Question?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let question {
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
        .swipeActions(edge: .trailing) {
            Button {
                record.isMastered = true
            } label: {
                Label("已掌握", systemImage: "checkmark.circle")
            }
            .tint(.green)
        }
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
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

import SwiftUI
import SwiftData

enum QuestionBankType: String, CaseIterable {
    case chapter = "章节练习"
    case mock = "模拟卷"

    var icon: String {
        switch self {
        case .chapter: "book.fill"
        case .mock: "doc.text.fill"
        }
    }
}

struct MockExam: Identifiable {
    let id: String
    let tag: String
    let title: String
    let subtitle: String
    let icon: String
    let questionCount: Int
}

struct QuizHomeView: View {
    let dataLoader = DataLoader.shared
    @Query(sort: \WrongAnswerRecord.timestamp, order: .reverse) private var allWrongAnswers: [WrongAnswerRecord]
    @State private var selectedBankType: QuestionBankType = .chapter
    @State private var selectedModule: String? = nil
    @State private var selectedMode: QuizMode = .random
    @State private var questionCount: Int = 20
    @State private var selectedMock: MockExam? = nil
    @State private var showMockConfirmation = false
    @State private var navigateToQuiz = false

    @Environment(\.modelContext) private var modelContext

    private let countOptions = [10, 20, 30, 50]

    private var totalWrongByModule: [String: Int] {
        Dictionary(grouping: allWrongAnswers.filter { !$0.isMastered }, by: \.moduleId)
            .mapValues(\.count)
    }

    private let mockExams: [MockExam] = [
        MockExam(id: "mock-a", tag: "mock-a", title: "模拟卷 A", subtitle: "100 题 · 全真模拟", icon: "📝", questionCount: 100),
        MockExam(id: "mock-b", tag: "mock-b", title: "模拟卷 B", subtitle: "100 题 · 全真模拟", icon: "📝", questionCount: 100),
        MockExam(id: "mock-c", tag: "mock-c", title: "协会模考题", subtitle: "91 题 · 官方模拟", icon: "🏛️", questionCount: 91),
    ]

    var body: some View {
        Form {
            // Overview card
            Section {
                overviewCard
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            // Bank type selector
            Section("题库类型") {
                Picker("题库", selection: $selectedBankType) {
                    ForEach(QuestionBankType.allCases, id: \.self) { type in
                        Label(type.rawValue, systemImage: type.icon).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
            }

            if selectedBankType == .chapter {
                chapterSection
            } else {
                mockSection
            }
        }
        .navigationTitle("刷题")
        .confirmationDialog(
            "确认开始",
            isPresented: $showMockConfirmation,
            titleVisibility: .visible
        ) {
            if let mock = selectedMock {
                Button("开始 \(mock.title)（\(mock.questionCount) 题）") {
                    selectedMode = .sequential
                    navigateToQuiz = true
                }
                Button("取消", role: .cancel) {
                    selectedMock = nil
                }
            }
        } message: {
            if let mock = selectedMock {
                Text("即将开始 \(mock.title)，共 \(mock.questionCount) 题。确认开始吗？")
            }
        }
        .navigationDestination(isPresented: $navigateToQuiz) {
            QuizSessionView(
                viewModel: {
                    let vm = StudyViewModel()
                    if selectedBankType == .chapter {
                        vm.startSession(
                            moduleId: selectedModule,
                            mode: selectedMode,
                            questionCount: questionCount,
                            modelContext: modelContext
                        )
                    } else if let mock = selectedMock {
                        vm.startSession(
                            moduleId: nil,
                            mode: selectedMode == .wrongAnswers ? .random : selectedMode,
                            questionCount: nil, // Mock exams: all questions
                            tags: [mock.tag],
                            modelContext: modelContext
                        )
                    }
                    return vm
                }()
            )
        }
    }

    // MARK: - Chapter section

    private var chapterSection: some View {
        Group {
            Section("选择模块") {
                Picker("模块", selection: $selectedModule) {
                    Text("全部模块").tag(String?.none)
                    ForEach(dataLoader.modules) { module in
                        HStack {
                            Text("模块 \(module.number)")
                            Text(module.title.display)
                        }
                        .tag(Optional(module.id))
                    }
                }
            }

            Section("练习模式") {
                Picker("模式", selection: $selectedMode) {
                    ForEach(QuizMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("题目数量") {
                Picker("数量", selection: $questionCount) {
                    ForEach(countOptions, id: \.self) { count in
                        Text("\(count) 题").tag(count)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Button {
                    navigateToQuiz = true
                } label: {
                    Text("开始练习")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
                .buttonStyle(.borderedProminent)
                .disabled(maxAvailableQuestions == 0)
            } footer: {
                if maxAvailableQuestions == 0 {
                    Text("所选模块暂无题目")
                } else {
                    Text("共 \(maxAvailableQuestions) 题可用")
                }
            }
        }
    }

    // MARK: - Mock section

    private var mockSection: some View {
        Group {
            Section("选择试卷") {
                ForEach(mockExams) { mock in
                    Button {
                        selectedMock = mock
                        showMockConfirmation = true
                    } label: {
                        HStack(spacing: 14) {
                            Text(mock.icon)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mock.title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text(mock.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }

            Section("答题模式") {
                Picker("模式", selection: $selectedMode) {
                    Text("顺序").tag(QuizMode.sequential)
                    Text("随机").tag(QuizMode.random)
                }
                .pickerStyle(.segmented)
            }

            Section {
                // Mode picker already above; no extra button needed
            } footer: {
                Text("模拟卷为全真模拟，共 100 题，计时作答")
            }
        }
    }

    // MARK: - Overview card

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

    // MARK: - Computed

    private var maxAvailableQuestions: Int {
        if let moduleId = selectedModule {
            return dataLoader.questions(for: moduleId).count
        }
        return dataLoader.allQuestions().count
    }
}

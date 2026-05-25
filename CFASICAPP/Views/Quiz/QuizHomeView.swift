import SwiftUI
import SwiftData

struct QuizHomeView: View {
    let dataLoader = DataLoader.shared
    @State private var selectedModule: String? = nil
    @State private var selectedMode: QuizMode = .random
    @State private var questionCount: Int = 20
    @State private var navigateToQuiz = false

    @Environment(\.modelContext) private var modelContext

    private let countOptions = [10, 20, 30, 50]

    var body: some View {
        Form {
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
                        Text(mode.rawValue).tag(mode)
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
            }
        }
        .navigationTitle("刷题")
        .navigationDestination(isPresented: $navigateToQuiz) {
            QuizSessionView(
                viewModel: {
                    let vm = StudyViewModel()
                    vm.startSession(
                        moduleId: selectedModule,
                        mode: selectedMode,
                        questionCount: questionCount,
                        modelContext: modelContext
                    )
                    return vm
                }()
            )
        }
    }

    private var maxAvailableQuestions: Int {
        if let moduleId = selectedModule {
            return dataLoader.questions(for: moduleId).count
        }
        return dataLoader.allQuestions().count
    }
}

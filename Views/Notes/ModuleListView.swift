import SwiftUI
import SwiftData

struct ModuleListView: View {
    let dataLoader = DataLoader.shared

    var body: some View {
        List(dataLoader.modules) { module in
            NavigationLink(value: module) {
                ModuleRow(module: module)
            }
        }
        .navigationTitle("CFA-SIC 备考")
        .navigationDestination(for: ModuleInfo.self) { module in
            ContentListView(module: module)
        }
    }
}

struct ModuleRow: View {
    let module: ModuleInfo
    @Query private var wrongAnswers: [WrongAnswerRecord]

    init(module: ModuleInfo) {
        self.module = module
        _wrongAnswers = Query(filter: #Predicate<WrongAnswerRecord> { $0.moduleId == module.id && $0.isMastered == false })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("模块 \(module.number)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let weight = module.examWeight {
                    Text(weight)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }

            Text(module.title.display)
                .font(.headline)

            HStack(spacing: 12) {
                Label("\(module.questionCount) 题", systemImage: "questionmark.circle")
                if !wrongAnswers.isEmpty {
                    Label("\(wrongAnswers.count) 错题", systemImage: "xmark.circle")
                        .foregroundStyle(.red)
                }
                if !module.content.isEmpty {
                    Label("\(module.content.count) 资料", systemImage: "doc.text")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

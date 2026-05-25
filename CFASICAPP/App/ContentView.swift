import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("笔记", systemImage: "book.fill") {
                NavigationStack {
                    ModuleListView()
                }
            }

            Tab("刷题", systemImage: "pencil.circle.fill") {
                NavigationStack {
                    QuizHomeView()
                }
            }

            Tab("错题", systemImage: "xmark.circle.fill") {
                NavigationStack {
                    ErrorBookView()
                }
            }

            Tab("术语", systemImage: "text.book.closed.fill") {
                NavigationStack {
                    GlossaryListView()
                }
            }

            Tab("进度", systemImage: "chart.bar.fill") {
                NavigationStack {
                    ProgressDashboardView()
                }
            }
        }
    }
}

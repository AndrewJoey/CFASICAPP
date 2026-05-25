import SwiftUI

struct ContentListView: View {
    let module: ModuleInfo
    let dataLoader = DataLoader.shared

    var body: some View {
        Group {
            if module.content.count == 1, let onlyContent = module.content.first {
                MarkdownReaderView(
                    module: module,
                    moduleContent: onlyContent
                )
            } else {
                List(module.content) { content in
                    NavigationLink {
                        MarkdownReaderView(module: module, moduleContent: content)
                    } label: {
                        Label(content.title.display, systemImage: content.icon)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(module.title.display)
        .navigationBarTitleDisplayMode(.inline)
    }
}

import SwiftUI

struct ContentListView: View {
    let module: ModuleInfo
    let dataLoader = DataLoader.shared

    var body: some View {
        Group {
            if module.content.count == 1, let onlyContent = module.content.first {
                contentView(onlyContent)
            } else {
                List(module.content) { content in
                    NavigationLink {
                        contentView(content)
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

    @ViewBuilder
    private func contentView(_ content: ModuleContent) -> some View {
        if content.type == "textbook" {
            let path = content.files?["zh"]
            let url = path.flatMap { dataLoader.resolvePDF(relativePath: $0) }
            PDFReaderView(title: content.title.display, pdfURL: url)
        } else {
            MarkdownReaderView(module: module, moduleContent: content)
        }
    }
}

import SwiftUI
import MarkdownUI

struct MarkdownReaderView: View {
    let module: ModuleInfo
    let moduleContent: ModuleContent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let path = moduleContent.files?["zh"],
                   let markdown = DataLoader.shared.loadMarkdown(relativePath: path) {
                    Markdown(markdown)
                        .markdownTheme(.customStudy)
                        .padding()
                } else {
                    ContentUnavailableView(
                        "内容未找到",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("该内容尚未添加")
                    )
                }
            }
        }
        .navigationTitle(moduleContent.title.display)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Custom Markdown Theme

extension Theme {
    static let customStudy = Theme()
        .text {
            ForegroundColor(.primary)
            BackgroundColor(.clear)
            FontSize(16)
        }
        .heading1 { config in
            config.label
                .markdownMargin(top: 16, bottom: 12)
                .markdownFontSize(24)
                .fontWeight(.bold)
        }
        .heading2 { config in
            config.label
                .markdownMargin(top: 14, bottom: 8)
                .markdownFontSize(20)
                .fontWeight(.semibold)
        }
        .heading3 { config in
            config.label
                .markdownMargin(top: 12, bottom: 6)
                .markdownFontSize(17)
                .fontWeight(.semibold)
        }
        .code {
            FontFamily(.monospaced)
            FontSize(14)
            BackgroundColor(Color(.systemGray6))
        }
        .blockquote { config in
            config.label
                .markdownPadding(12)
                .markdownMargin(top: 8, bottom: 8)
                .background(Color(.systemBlue).opacity(0.08))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemBlue).opacity(0.2), lineWidth: 1)
                )
        }
        .table { config in
            config.label
                .markdownTableBorderStyle(.init(color: .secondary.opacity(0.3)))
                .markdownTableBackgroundStyle(
                    .alternatingRows(Color(.systemGray6), Color.clear)
                )
                .markdownMargin(top: 8, bottom: 8)
        }
}

import SwiftUI
import MarkdownUI
import SwiftData

struct MarkdownReaderView: View {
    let module: ModuleInfo
    let moduleContent: ModuleContent

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showTOC = false
    @State private var headings: [(level: Int, text: String, offset: CGFloat)] = []
    @State private var scrollPosition: CGFloat = 0
    @State private var markdown: String?

    // Find prev/next modules
    private var allModules: [ModuleInfo] {
        DataLoader.shared.modules
    }
    private var currentModuleIndex: Int? {
        allModules.firstIndex(where: { $0.id == module.id })
    }
    private var prevModule: ModuleInfo? {
        guard let idx = currentModuleIndex, idx > 0 else { return nil }
        return allModules[idx - 1]
    }
    private var nextModule: ModuleInfo? {
        guard let idx = currentModuleIndex, idx < allModules.count - 1 else { return nil }
        return allModules[idx + 1]
    }

    var body: some View {
        Group {
            if let markdown {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // Module header
                            moduleHeader
                                .padding(.bottom, 16)

                            Markdown(markdown)
                                .markdownTheme(.customStudy)
                                .padding(.horizontal)

                            // Next chapter link
                            if let next = nextModule {
                                nextChapterLink(next)
                                    .padding(.top, 32)
                                    .padding(.horizontal)
                                    .padding(.bottom, 40)
                            }
                        }
                        .background(GeometryReader { geo in
                            Color.clear.preference(
                                key: ScrollOffsetKey.self,
                                value: geo.frame(in: .named("scroll")).minY
                            )
                        })
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { value in
                        scrollPosition = -value
                    }
                    .sheet(isPresented: $showTOC) {
                        TOCView(headings: headings) { offset in
                            withAnimation {
                                proxy.scrollTo("heading-\(offset)", anchor: .top)
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView(
                    "内容未找到",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("该内容尚未添加")
                )
            }
        }
        .navigationTitle(module.title.display)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                // Textbook PDF button
                let zhURL = DataLoader.shared.resolvePDF(relativePath: "content/textbook/2026v7CHNTB.pdf")
                let enURL = DataLoader.shared.resolvePDF(relativePath: "content/textbook/2026v7ENGTB.pdf")
                if zhURL != nil || enURL != nil {
                    NavigationLink {
                        PDFReaderView(title: "原版教材", chineseURL: zhURL, englishURL: enURL)
                    } label: {
                        Image(systemName: "book.closed.fill")
                    }
                }

                // TOC button
                Button {
                    showTOC = true
                } label: {
                    Image(systemName: "list.bullet")
                }
                .disabled(headings.isEmpty)
            }
        }
        .onAppear {
            loadContent()
            restoreReadingProgress()
        }
        .onDisappear {
            saveReadingProgress()
        }
    }

    // MARK: - Module header

    private var moduleHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(format: "模块 %02d", module.number))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
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
                .font(.title2)
                .bold()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
    }

    // MARK: - Next chapter link

    private func nextChapterLink(_ next: ModuleInfo) -> some View {
        NavigationLink {
            MarkdownReaderView(module: next, moduleContent: next.content[0])
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("下一步")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("模块 \(next.number)：\(next.title.display)")
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Data

    private func loadContent() {
        if let path = moduleContent.files?["zh"] {
            markdown = DataLoader.shared.loadMarkdown(relativePath: path)
            if let md = markdown {
                headings = extractHeadings(from: md)
            }
        }
    }

    private func extractHeadings(from text: String) -> [(level: Int, text: String, offset: CGFloat)] {
        var result: [(level: Int, text: String, offset: CGFloat)] = []
        for line in text.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("# ") {
                result.append((level: 1, text: String(trimmed.dropFirst(2)), offset: CGFloat(result.count)))
            } else if trimmed.hasPrefix("## ") {
                result.append((level: 2, text: String(trimmed.dropFirst(3)), offset: CGFloat(result.count)))
            } else if trimmed.hasPrefix("### ") {
                result.append((level: 3, text: String(trimmed.dropFirst(4)), offset: CGFloat(result.count)))
            }
        }
        return result
    }

    // MARK: - Reading progress

    private func saveReadingProgress() {
        let id = "\(module.id)-\(moduleContent.type)"
        let descriptor = FetchDescriptor<ReadingProgress>(
            predicate: #Predicate<ReadingProgress> { $0.id == id }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            existing.scrollPosition = scrollPosition
            existing.lastRead = .now
        } else {
            let progress = ReadingProgress(
                id: id,
                moduleId: module.id,
                contentType: moduleContent.type,
                scrollPosition: scrollPosition
            )
            modelContext.insert(progress)
        }
    }

    private func restoreReadingProgress() {
        let id = "\(module.id)-\(moduleContent.type)"
        let descriptor = FetchDescriptor<ReadingProgress>(
            predicate: #Predicate<ReadingProgress> { $0.id == id }
        )
        if let progress = try? modelContext.fetch(descriptor).first {
            scrollPosition = progress.scrollPosition
        }
    }
}

// MARK: - TOC View

private struct TOCView: View {
    let headings: [(level: Int, text: String, offset: CGFloat)]
    let onSelect: (CGFloat) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(headings, id: \.offset) { heading in
                Button {
                    onSelect(heading.offset)
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        if heading.level > 1 {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: CGFloat(heading.level - 1) * 12, height: 2)
                        }
                        Text(heading.text)
                            .font(heading.level == 1 ? .headline : .subheadline)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 2)
                }
                .buttonStyle(.plain)
            }
            .listStyle(.plain)
            .navigationTitle("目录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Scroll offset preference key

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
                .markdownMargin(top: 20, bottom: 12)
                .font(.system(size: 24, weight: .bold))
                .id("heading-\(config.content)")
        }
        .heading2 { config in
            config.label
                .markdownMargin(top: 16, bottom: 8)
                .font(.system(size: 20, weight: .semibold))
                .id("heading-\(config.content)")
        }
        .heading3 { config in
            config.label
                .markdownMargin(top: 12, bottom: 6)
                .font(.system(size: 17, weight: .semibold))
                .id("heading-\(config.content)")
        }
        .code {
            FontFamily(.system(.monospaced))
            FontSize(14)
            BackgroundColor(Color(.systemGray6))
        }
        .blockquote { config in
            config.label
                .padding(12)
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

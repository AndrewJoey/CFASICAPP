import SwiftUI
import PDFKit

struct PDFReaderView: View {
    let title: String
    let chineseURL: URL?
    let englishURL: URL?

    @Environment(\.dismiss) private var dismiss
    @State private var currentPage: Int = 1
    @State private var totalPages: Int = 0
    @State private var useEnglish: Bool = false

    private var currentURL: URL? {
        useEnglish ? englishURL : chineseURL
    }

    init(title: String, chineseURL: URL? = nil, englishURL: URL? = nil, pdfURL: URL? = nil) {
        self.title = title
        self.chineseURL = chineseURL ?? pdfURL
        self.englishURL = englishURL
    }

    var body: some View {
        Group {
            if let url = currentURL {
                PDFKitView(url: url, currentPage: $currentPage, totalPages: $totalPages)
                    .id(useEnglish) // Force reload on language switch
                    .ignoresSafeArea(edges: .bottom)
            } else {
                ContentUnavailableView(
                    "PDF 未找到",
                    systemImage: "doc.richtext",
                    description: Text("原版教材文件尚未添加")
                )
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                // Language toggle (only show if both versions exist)
                if chineseURL != nil && englishURL != nil {
                    Button {
                        useEnglish.toggle()
                        currentPage = 1
                    } label: {
                        Text(useEnglish ? "EN" : "中")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(useEnglish ? Color.blue : Color.orange)
                            .cornerRadius(6)
                    }
                }
            }

            if totalPages > 0 {
                ToolbarItem(placement: .bottomBar) {
                    Text("第 \(currentPage) / \(totalPages) 页")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - PDFKit UIViewRepresentable

private struct PDFKitView: UIViewRepresentable {
    let url: URL
    @Binding var currentPage: Int
    @Binding var totalPages: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(currentPage: $currentPage, totalPages: $totalPages)
    }

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical

        if let document = PDFDocument(url: url) {
            pdfView.document = document
            totalPages = document.pageCount
        }

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: pdfView
        )

        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        if let document = PDFDocument(url: url) {
            pdfView.document = document
            totalPages = document.pageCount
            currentPage = 1
        }
    }

    static func dismantleUIView(_ pdfView: PDFView, coordinator: Coordinator) {
        NotificationCenter.default.removeObserver(coordinator, name: .PDFViewPageChanged, object: pdfView)
    }

    class Coordinator: NSObject {
        @Binding var currentPage: Int
        @Binding var totalPages: Int

        init(currentPage: Binding<Int>, totalPages: Binding<Int>) {
            _currentPage = currentPage
            _totalPages = totalPages
        }

        @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let page = pdfView.currentPage,
                  let index = pdfView.document?.index(for: page) else { return }
            currentPage = index + 1
        }
    }
}

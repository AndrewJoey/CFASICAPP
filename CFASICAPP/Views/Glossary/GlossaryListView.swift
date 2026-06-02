import SwiftUI

struct GlossaryListView: View {
    let dataLoader = DataLoader.shared
    @State private var searchText = ""
    @State private var showFlashcards = false
    @State private var showHighFreqOnly = false
    @State private var flashcardVM: GlossaryViewModel?
    @State private var showSingleFlashcard = false

    var filteredTerms: [GlossaryTerm] {
        var terms = dataLoader.glossary
        if showHighFreqOnly {
            terms = terms.filter(\.isHighFrequency)
        }
        if !searchText.isEmpty {
            terms = terms.filter {
                $0.english.localizedCaseInsensitiveContains(searchText) ||
                $0.chinese.contains(searchText) ||
                $0.explanation.display.localizedCaseInsensitiveContains(searchText)
            }
        }
        return terms.sorted { $0.english.lowercased() < $1.english.lowercased() }
    }

    var grouped: [(String, [GlossaryTerm])] {
        Dictionary(grouping: filteredTerms, by: \.letter)
            .sorted { $0.key < $1.key }
    }

    var body: some View {
        List {
            ForEach(grouped, id: \.0) { letter, terms in
                Section {
                    ForEach(terms) { term in
                        Button {
                            let ordered = [term] + filteredTerms.filter { $0.id != term.id }
                            flashcardVM = GlossaryViewModel(terms: ordered)
                            showSingleFlashcard = true
                        } label: {
                            GlossaryRow(term: term)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text(letter)
                }
            }
        }
        .searchable(text: $searchText, prompt: "搜索术语...")
        .listStyle(.insetGrouped)
        .navigationTitle("术语表")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showHighFreqOnly.toggle()
                } label: {
                    Image(systemName: showHighFreqOnly ? "star.fill" : "star")
                        .foregroundStyle(showHighFreqOnly ? .yellow : .secondary)
                }
                .accessibilityLabel(showHighFreqOnly ? "显示全部术语" : "仅显示高频术语")

                Button {
                    flashcardVM = GlossaryViewModel(terms: Array(filteredTerms))
                    showFlashcards = true
                } label: {
                    Image(systemName: "rectangle.on.rectangle.angled")
                }
                .accessibilityLabel("闪卡模式")
            }
        }
        .sheet(isPresented: $showSingleFlashcard) {
            if let vm = flashcardVM {
                NavigationStack {
                    FlashcardView(viewModel: vm)
                }
            }
        }
        .fullScreenCover(isPresented: $showFlashcards) {
            NavigationStack {
                FlashcardView(viewModel: GlossaryViewModel(terms: Array(filteredTerms)))
            }
        }
    }
}

private struct GlossaryRow: View {
    let term: GlossaryTerm

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(term.english)
                    .font(.subheadline)
                    .bold()
                if term.isHighFrequency {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                }
            }
            Text(term.chinese)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

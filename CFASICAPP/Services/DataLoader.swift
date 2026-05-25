import Foundation

@Observable
final class DataLoader {
    static let shared = DataLoader()

    var modules: [ModuleInfo] = []
    var glossary: [GlossaryTerm] = []
    private var questionsCache: [String: [Question]] = [:]

    private init() {
        loadModules()
        loadGlossary()
    }

    // MARK: - Modules

    private func loadModules() {
        guard let url = Bundle.main.url(forResource: "modules", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error: Could not load modules.json")
            return
        }
        modules = (try? JSONDecoder().decode([ModuleInfo].self, from: data)) ?? []
    }

    private func loadGlossary() {
        guard let url = Bundle.main.url(forResource: "glossary", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Error: Could not load glossary.json")
            return
        }
        glossary = (try? JSONDecoder().decode([GlossaryTerm].self, from: data)) ?? []
    }

    // MARK: - Questions

    func questions(for moduleId: String) -> [Question] {
        if let cached = questionsCache[moduleId] {
            return cached
        }
        guard let module = modules.first(where: { $0.id == moduleId }) else { return [] }

        let path = module.questionsFile
        let pathURL = URL(fileURLWithPath: path)
        let resourceName = pathURL.deletingPathExtension().lastPathComponent
        let ext = pathURL.pathExtension

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: ext),
              let data = try? Data(contentsOf: url) else {
            return []
        }

        let questions = (try? JSONDecoder().decode([Question].self, from: data)) ?? []
        questionsCache[moduleId] = questions
        return questions
    }

    func allQuestions() -> [Question] {
        modules.flatMap { questions(for: $0.id) }
    }

    // MARK: - Notes / Content

    func loadMarkdown(relativePath: String) -> String? {
        let pathURL = URL(fileURLWithPath: relativePath)
        let resourceName = pathURL.deletingPathExtension().lastPathComponent
        let ext = pathURL.pathExtension

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: ext) else {
            return nil
        }
        return try? String(contentsOf: url, encoding: .utf8)
    }

    // MARK: - Helpers

    func module(by id: String) -> ModuleInfo? {
        modules.first(where: { $0.id == id })
    }

    func glossaryTerms(groupedByLetter: Bool = false) -> [(String, [GlossaryTerm])] {
        let sorted = glossary.sorted { $0.english.lowercased() < $1.english.lowercased() }
        if groupedByLetter {
            return Dictionary(grouping: sorted, by: \.letter)
                .sorted { $0.key < $1.key }
        }
        return [("", sorted)]
    }
}

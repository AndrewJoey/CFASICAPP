import XCTest
@testable import CFASICAPP

@MainActor
final class DataLoaderTests: XCTestCase {
    let loader = DataLoader.shared

    // MARK: - Module Questions

    func testQuestionsForModule_returnsNonEmpty() {
        let questions = loader.questions(for: "module-01")
        XCTAssertFalse(questions.isEmpty, "module-01 should have questions")
    }

    func testQuestionsForModule_invalidModule_returnsEmpty() {
        let questions = loader.questions(for: "nonexistent-module")
        XCTAssertTrue(questions.isEmpty)
    }

    // MARK: - File-based Questions (Mock Exams)

    func testQuestionsForFile_mockA_returnsNonEmpty() {
        let questions = loader.questions(forFile: "mock-a.json")
        XCTAssertFalse(questions.isEmpty, "mock-a.json should have questions")
    }

    func testQuestionsForFile_mockB_returnsNonEmpty() {
        let questions = loader.questions(forFile: "mock-b.json")
        XCTAssertFalse(questions.isEmpty, "mock-b.json should have questions")
    }

    func testQuestionsForFile_mockC_returnsNonEmpty() {
        let questions = loader.questions(forFile: "mock-c.json")
        XCTAssertFalse(questions.isEmpty, "mock-c.json should have questions")
    }

    func testQuestionsForFile_invalidFile_returnsEmpty() {
        let questions = loader.questions(forFile: "nonexistent.json")
        XCTAssertTrue(questions.isEmpty)
    }

    // MARK: - Tag Filtering

    func testQuestionsMatchingTags_noMatch_returnsEmpty() {
        let questions = loader.questions(matchingTags: ["nonexistent-tag"])
        XCTAssertTrue(questions.isEmpty)
    }

    func testQuestionsFromFiles_mockA_returnsNonEmpty() {
        let questions = loader.questions(fromFiles: ["mock-a.json"], matchingTags: ["mock-a"])
        XCTAssertFalse(questions.isEmpty, "mock-a questions should be loadable")
    }

    // MARK: - PDF Resolution

    func testResolvePDF_nonexistent_returnsNil() {
        let url = loader.resolvePDF(relativePath: "content/textbook/nonexistent.pdf")
        XCTAssertNil(url)
    }

    // MARK: - All Questions

    func testAllQuestions_returnsNonEmpty() {
        let questions = loader.allQuestions()
        XCTAssertFalse(questions.isEmpty)
    }

    // MARK: - Modules

    func testModules_count_is7() {
        XCTAssertEqual(loader.modules.count, 7)
    }

    func testModule_byId_returnsCorrect() {
        let module = loader.module(by: "module-01")
        XCTAssertNotNil(module)
        XCTAssertEqual(module?.number, 1)
    }
}

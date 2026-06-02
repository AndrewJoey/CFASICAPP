import XCTest
@testable import CFASICAPP

@MainActor
final class GlossaryViewModelTests: XCTestCase {

    private func makeTerms(count: Int, highFreqCount: Int = 0) -> [GlossaryTerm] {
        (0..<count).map { i in
            GlossaryTerm(
                id: "term-\(i)",
                english: "Term \(i)",
                chinese: "术语 \(i)",
                explanation: LocalizedString(zh: "Explanation \(i)", en: nil),
                isHighFrequency: i < highFreqCount,
                letter: String(UnicodeScalar(65 + (i % 26))!),
                category: nil
            )
        }
    }

    // MARK: - Navigation

    func testNext_withinBounds() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 5))
        vm.currentIndex = 0

        vm.next()
        XCTAssertEqual(vm.currentIndex, 1)
    }

    func testNext_atEnd_doesNotAdvance() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 5))
        vm.currentIndex = 4 // Last index

        vm.next()
        XCTAssertEqual(vm.currentIndex, 4, "Should not advance past last index")
    }

    func testPrevious_withinBounds() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 5))
        vm.currentIndex = 3

        vm.previous()
        XCTAssertEqual(vm.currentIndex, 2)
    }

    func testPrevious_atStart_doesNotAdvance() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 5))
        vm.currentIndex = 0

        vm.previous()
        XCTAssertEqual(vm.currentIndex, 0, "Should not go below 0")
    }

    // MARK: - Current Term

    func testCurrentTerm_returnsCorrectTerm() {
        let terms = makeTerms(count: 5)
        let vm = GlossaryViewModel(terms: terms)
        vm.currentIndex = 2

        XCTAssertNotNil(vm.currentTerm)
        // Note: terms are shuffled in init, so we can't assert exact ID
        // but we can assert it exists
    }

    func testCurrentTerm_outOfBounds_returnsNil() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 3))
        vm.currentIndex = 10

        XCTAssertNil(vm.currentTerm)
    }

    // MARK: - Can Go Forward/Back

    func testCanGoForward_atStart() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 5))
        vm.currentIndex = 0
        XCTAssertTrue(vm.canGoForward)
    }

    func testCanGoForward_atEnd() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 5))
        vm.currentIndex = 4
        XCTAssertFalse(vm.canGoForward)
    }

    func testCanGoBack_atStart() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 5))
        vm.currentIndex = 0
        XCTAssertFalse(vm.canGoBack)
    }

    func testCanGoBack_atMiddle() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 5))
        vm.currentIndex = 2
        XCTAssertTrue(vm.canGoBack)
    }

    // MARK: - High Frequency Filter

    func testShowHighFrequencyOnly_filtersCorrectly() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 10, highFreqCount: 3))
        vm.showHighFrequencyOnly = true

        XCTAssertEqual(vm.activeTerms.count, 3)
    }

    func testShowHighFrequencyOnly_resetsIndex() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 10, highFreqCount: 3))
        vm.currentIndex = 8

        vm.showHighFrequencyOnly = true
        XCTAssertEqual(vm.currentIndex, 0, "Index should reset when filter changes")
    }

    func testShowHighFrequencyOnly_resetsFlip() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 10, highFreqCount: 3))
        vm.isFlipped = true

        vm.showHighFrequencyOnly = true
        XCTAssertFalse(vm.isFlipped, "Flip state should reset when filter changes")
    }

    // MARK: - Flip

    func testFlip_togglesState() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 5))
        XCTAssertFalse(vm.isFlipped)

        vm.flip()
        XCTAssertTrue(vm.isFlipped)

        vm.flip()
        XCTAssertFalse(vm.isFlipped)
    }

    // MARK: - Shuffle

    func testShuffle_resetsIndex() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 10))
        vm.currentIndex = 7

        vm.shuffle()
        XCTAssertEqual(vm.currentIndex, 0)
    }

    func testShuffle_resetsFlip() {
        let vm = GlossaryViewModel(terms: makeTerms(count: 10))
        vm.isFlipped = true

        vm.shuffle()
        XCTAssertFalse(vm.isFlipped)
    }

    // MARK: - Empty Terms

    func testEmptyTerms_currentTermIsNil() {
        let vm = GlossaryViewModel(terms: [])
        XCTAssertNil(vm.currentTerm)
    }

    func testEmptyTerms_cannotGoForward() {
        let vm = GlossaryViewModel(terms: [])
        XCTAssertFalse(vm.canGoForward)
    }

    func testEmptyTerms_cannotGoBack() {
        let vm = GlossaryViewModel(terms: [])
        XCTAssertFalse(vm.canGoBack)
    }
}

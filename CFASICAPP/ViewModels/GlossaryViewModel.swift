import Foundation
import SwiftUI

@Observable
final class GlossaryViewModel {
    var allTerms: [GlossaryTerm]
    var currentIndex: Int = 0
    var isFlipped: Bool = false
    var showHighFrequencyOnly: Bool = false

    var activeTerms: [GlossaryTerm] {
        if showHighFrequencyOnly {
            return allTerms.filter(\.isHighFrequency)
        }
        return allTerms
    }

    var currentTerm: GlossaryTerm? {
        guard currentIndex < activeTerms.count else { return nil }
        return activeTerms[currentIndex]
    }

    var canGoBack: Bool { currentIndex > 0 }
    var canGoForward: Bool { currentIndex < activeTerms.count - 1 }

    init(terms: [GlossaryTerm]) {
        self.allTerms = terms.shuffled()
    }

    func flip() {
        withAnimation(.easeInOut(duration: 0.4)) {
            isFlipped.toggle()
        }
    }

    func next() {
        guard canGoForward else { return }
        isFlipped = false
        currentIndex += 1
    }

    func previous() {
        guard canGoBack else { return }
        isFlipped = false
        currentIndex -= 1
    }

    func shuffle() {
        allTerms.shuffle()
        currentIndex = 0
        isFlipped = false
    }
}

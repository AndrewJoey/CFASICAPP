import Foundation

struct LocalizedString: Codable, ExpressibleByStringLiteral, Equatable {
    let zh: String
    let en: String?

    var display: String { zh }

    init(zh: String, en: String? = nil) {
        self.zh = zh
        self.en = en
    }

    init(stringLiteral value: String) {
        self.zh = value
        self.en = nil
    }
}

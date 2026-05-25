import Foundation
import SwiftData

@Model
final class ReadingProgress {
    @Attribute(.unique) var id: String
    var moduleId: String
    var contentType: String
    var scrollPosition: Double
    var lastRead: Date

    init(
        id: String,
        moduleId: String,
        contentType: String,
        scrollPosition: Double = 0,
        lastRead: Date = .now
    ) {
        self.id = id
        self.moduleId = moduleId
        self.contentType = contentType
        self.scrollPosition = scrollPosition
        self.lastRead = lastRead
    }
}

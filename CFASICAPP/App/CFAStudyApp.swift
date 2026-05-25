import SwiftUI
import SwiftData

@main
struct CFAStudyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [WrongAnswerRecord.self, StudyDayRecord.self, ReadingProgress.self])
    }
}

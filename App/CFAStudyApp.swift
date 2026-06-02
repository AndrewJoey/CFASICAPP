import SwiftUI
import SwiftData
import os

@main
struct CFAStudyApp: App {
    let container: ModelContainer
    @Environment(\.scenePhase) private var scenePhase
    @State private var notificationManager = NotificationManager.shared

    init() {
        do {
            container = try ModelContainer(for: WrongAnswerRecord.self, StudyDayRecord.self, ReadingProgress.self)
        } catch {
            os_log(.error, "SwiftData init failed: %{public}@. Falling back to in-memory store.", error.localizedDescription)
            let schema = Schema([WrongAnswerRecord.self, StudyDayRecord.self, ReadingProgress.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                container = try ModelContainer(for: schema, configurations: config)
            } catch {
                fatalError("Cannot create SwiftData container: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await notificationManager.requestAuthorization()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        notificationManager.checkAuthorizationStatus()
                    }
                }
        }
        .modelContainer(container)
    }
}

import Foundation
import UserNotifications
import SwiftData
import os

@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    var isAuthorized = false

    private let reminderIdentifier = "daily-study-reminder"
    private let reminderHour = 20 // 8 PM
    private let reminderMinute = 0

    private init() {}

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            if granted {
                scheduleDailyReminder()
            }
        } catch {
            os_log(.error, "Notification auth error: %{public}@", error.localizedDescription)
        }
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "继续学习 📚"
        content.body = "今天还没有练习哦，打开 App 保持学习 streak！"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: reminderIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                os_log(.error, "Failed to schedule reminder: %{public}@", error.localizedDescription)
            }
        }
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }

    /// Called when app enters foreground. Cancels today's reminder if user has already studied.
    func checkAndReschedule(modelContext: ModelContext) {
        guard isAuthorized else { return }

        let today = Calendar.current.startOfDay(for: Date())
        let id = Self.dateFormatter.string(from: today)
        let descriptor = FetchDescriptor<StudyDayRecord>(
            predicate: #Predicate<StudyDayRecord> { $0.id == id }
        )

        let hasStudiedToday = (try? modelContext.fetchCount(descriptor)) ?? 0 > 0

        if hasStudiedToday {
            // Cancel today's reminder, schedule for tomorrow
            cancelDailyReminder()
            scheduleDailyReminder()
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

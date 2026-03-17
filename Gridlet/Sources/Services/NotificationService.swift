import Foundation
import UserNotifications

/// Manages local notifications for daily puzzle reminders.
final class NotificationService: @unchecked Sendable {
    static let shared = NotificationService()

    /// UserInfo key included in daily reminder notifications.
    static let dailyReminderActionKey = "openDaily"

    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifier = "daily-puzzle-reminder"

    private init() {}

    // MARK: - Permission

    /// Request notification permission. Returns true if granted.
    @discardableResult
    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Whether the user has granted notification permission.
    func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    // MARK: - Scheduling

    /// Schedule a daily reminder notification for this evening if the daily puzzle
    /// hasn't been completed yet. Cancels any existing reminder first.
    func scheduleDailyReminderIfNeeded(stats: PlayerStats, preferredHour: Int = 18) {
        cancelDailyReminder()

        // Don't schedule if today's daily is already done.
        if stats.lastDailyCompletedDate == PlayerStats.todayString() {
            return
        }

        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = .current

        // Build today's reminder time.
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = preferredHour
        components.minute = 0
        components.second = 0

        guard let reminderDate = calendar.date(from: components) else { return }

        // If the preferred time already passed today, skip — don't schedule for tomorrow.
        guard reminderDate > now else { return }

        let content = Self.makeReminderContent(streak: stats.currentStreak)
        let triggerComponents = calendar.dateComponents([.hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    /// Cancel any pending daily reminder.
    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
    }

    // MARK: - Dev / Testing

    /// Fire a test notification in 5 seconds using the real reminder content.
    func scheduleTestNotification(streak: Int) {
        let content = Self.makeReminderContent(streak: streak)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "daily-puzzle-reminder-test",
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    // MARK: - Content

    private static func makeReminderContent(streak: Int) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.interruptionLevel = .passive
        content.relevanceScore = 0.5
        content.userInfo = [dailyReminderActionKey: true]

        if streak > 0 {
            content.title = "🔥 Don't Break Your Streak!"
            content.body = "You're on a \(streak)-day streak. Today's puzzle is still unsolved — tap to play!"
        } else {
            content.title = "🧩 Daily Puzzle Waiting"
            content.body = "A fresh daily crossword is ready for you. Can you solve it?"
        }

        return content
    }
}

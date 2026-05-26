//
//  NotificationService.swift
//  GlowProtocol
//
//  Schedules + cancels local notifications:
//   • Daily reminder (user-configurable time)
//   • Nightly streak evaluation (23:59:50)
//

import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()
    static let dailyReminderID = "sam.GlowProtocol.dailyReminder"
    static let midnightCheckID = "sam.GlowProtocol.midnightCheck"
    static let graceAvailableID = "sam.GlowProtocol.graceAvailable"

    private init() {}

    func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
        }
    }

    func scheduleDailyReminder(hour: Int, minute: Int) async {
        await requestAuthorizationIfNeeded()
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.dailyReminderID])

        let content = UNMutableNotificationContent()
        content.title = "Time to glow."
        content.body = "Your protocol is waiting. Open Glow Protocol."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: Self.dailyReminderID, content: content, trigger: trigger)
        try? await center.add(request)
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [Self.dailyReminderID]
        )
    }

    func scheduleMidnightCheck() async {
        await requestAuthorizationIfNeeded()
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.midnightCheckID])

        let content = UNMutableNotificationContent()
        content.title = "Day check."
        content.body = "Glow Protocol is evaluating today's habits."
        content.sound = nil

        var components = DateComponents()
        components.hour = 23
        components.minute = 59
        components.second = 50

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: Self.midnightCheckID, content: content, trigger: trigger)
        try? await center.add(request)
    }

    func postGraceAvailableNotification() async {
        await requestAuthorizationIfNeeded()
        let content = UNMutableNotificationContent()
        content.title = "Grace day available."
        content.body = "Open Glow Protocol to decide whether to use it."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: Self.graceAvailableID, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

//
//  NotificationManager.swift
//  plant_midapp
//
//  Created by Danah Aleyadhi on 27/10/2025.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // MARK: - Authorization

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                print("✅ Permission granted")
            } else {
                print("❌ Permission denied")
            }
        }
    }

    // MARK: - Public API

    // Note: hour/minute are no longer used to anchor scheduling.
    // The trigger will start from "now" (when this is called), matching the user's save time.
    func scheduleNotifications(for plant: Plant, at hour: Int = 9, minute: Int = 0) {
        // Cancel existing for id, then reschedule
        cancelNotifications(for: plant.id)

        // Create request(s) based on wateringDays
        let requests = buildRequests(for: plant)

        let center = UNUserNotificationCenter.current()
        for req in requests {
            center.add(req) { error in
                if let error = error {
                    print("Failed to schedule notification for \(plant.name): \(error)")
                }
            }
        }
    }

    func cancelNotifications(for plantID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers(for: plantID))
    }

    // MARK: - Test helpers

    // A) Repeating every 60 seconds (minimum allowed for repeating interval triggers)
    func scheduleRepeatingTestNotificationEvery60Seconds() {
        let id = "test.repeating.60s"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = "Test (60s)"
        content.body = "This repeats every 60 seconds."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule 60s repeating test: \(error)")
            } else {
                print("Scheduled 60s repeating test notification.")
            }
        }
    }

    // B) One-off 30-second test (does not repeat due to system limits)
    func scheduleOneOffTestNotificationIn30Seconds() {
        let id = "test.oneoff.30s"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = "Test (30s)"
        content.body = "This fired 30 seconds after scheduling."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule 30s one-off test: \(error)")
            } else {
                print("Scheduled 30s one-off test notification.")
            }
        }
    }

    // MARK: - Helpers

    private func buildRequests(for plant: Plant) -> [UNNotificationRequest] {
        let title = "Hey! Let's water \(plant.name)!"
        let amountText = plant.waterAmount.isEmpty ? "" : " • \(plant.waterAmount)"
        let body = "Time to give \(plant.name) a sip 💧\(amountText)"

        let schedule = parseSchedule(from: plant.wateringDays)

        switch schedule {
        case .every10SecondsTest:
            // For testing: fire once after 10 seconds.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            return [request(id: identifier(for: plant.id, suffix: "every-10-seconds-once"), title: title, body: body, trigger: trigger)]

        case .daily:
            // Repeat every 24h from now (user's save time)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(24 * 3600), repeats: true)
            return [request(id: identifier(for: plant.id, suffix: "daily"), title: title, body: body, trigger: trigger)]

        case .everyNDays(let n):
            if n == 7 {
                // Treat as weekly interval from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(7 * 24 * 3600), repeats: true)
                return [request(id: identifier(for: plant.id, suffix: "weekly-7"), title: title, body: body, trigger: trigger)]
            } else if n == 14 {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(14 * 24 * 3600), repeats: true)
                return [request(id: identifier(for: plant.id, suffix: "biweekly-14"), title: title, body: body, trigger: trigger)]
            } else {
                let interval = TimeInterval(n * 24 * 3600)
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
                return [request(id: identifier(for: plant.id, suffix: "every-\(n)-days"), title: title, body: body, trigger: trigger)]
            }

        case .weekly:
            // Repeat every 7 days from now (user's save time)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(7 * 24 * 3600), repeats: true)
            return [request(id: identifier(for: plant.id, suffix: "weekly"), title: title, body: body, trigger: trigger)]

        case .biweekly:
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(14 * 24 * 3600), repeats: true)
            return [request(id: identifier(for: plant.id, suffix: "biweekly"), title: title, body: body, trigger: trigger)]

        case .unknown:
            // Fallback: repeat daily from now
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(24 * 3600), repeats: true)
            return [request(id: identifier(for: plant.id, suffix: "fallback-daily"), title: title, body: body, trigger: trigger)]
        }
    }

    // MARK: - Schedule parsing

    private enum WateringSchedule {
        case daily
        case everyNDays(Int) // 2,3,10,7,14...
        case weekly
        case biweekly
        case every10SecondsTest
        case unknown
    }

    private func parseSchedule(from text: String) -> WateringSchedule {
        let lower = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if lower == "every 10 seconds (test)" || lower == "every 10 seconds" {
            return .every10SecondsTest
        }

        if lower == "every day" || lower == "everyday" || lower == "daily" {
            return .daily
        }

        if lower.contains("once a week") || lower == "weekly" {
            return .weekly
        }

        if lower.contains("every 2 weeks") || lower.contains("biweekly") {
            return .biweekly
        }

        // Match "every N days"
        if lower.hasPrefix("every ") && lower.contains(" day") {
            let parts = lower
                .replacingOccurrences(of: "every ", with: "")
                .replacingOccurrences(of: " days", with: "")
                .replacingOccurrences(of: " day", with: "")
                .split(separator: " ")
            if let first = parts.first, let n = Int(first) {
                return .everyNDays(n)
            }
        }

        // Some explicit values from your UI list
        switch lower {
        case "every 2 days": return .everyNDays(2)
        case "every 3 days": return .everyNDays(3)
        case "every 10 days": return .everyNDays(10)
        default:
            return .unknown
        }
    }

    // MARK: - Request builder

    private func request(id: String, title: String, body: String, trigger: UNNotificationTrigger) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }

    // MARK: - Identifiers

    private func identifier(for plantID: UUID, suffix: String) -> String {
        "plant.\(plantID.uuidString).\(suffix)"
    }

    private func identifiers(for plantID: UUID) -> [String] {
        [
            identifier(for: plantID, suffix: "daily"),
            identifier(for: plantID, suffix: "weekly"),
            identifier(for: plantID, suffix: "biweekly"),
            identifier(for: plantID, suffix: "biweekly-14"),
            identifier(for: plantID, suffix: "weekly-7"),
            identifier(for: plantID, suffix: "fallback-daily"),
            identifier(for: plantID, suffix: "every-2-days"),
            identifier(for: plantID, suffix: "every-3-days"),
            identifier(for: plantID, suffix: "every-10-days"),
            identifier(for: plantID, suffix: "every-10-seconds-once"),
            "test.repeating.60s",
            "test.oneoff.30s"
        ]
    }
}

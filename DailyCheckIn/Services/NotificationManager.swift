//
//  NotificationManager.swift
//  DailyCheckIn
//
//  Created by Wahid on 21.08.26.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // Berechtigung anfragen
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleNotification(for activity: Activity, time: Date, weekdays: Set<Int>?) {
        var updatedActivity = activity
        updatedActivity.dailyTimes = [time]
        if let weekdays = weekdays {
            updatedActivity.selectedWeekdays = weekdays
        }
        scheduleNotifications(for: updatedActivity)
    }

    func scheduleNotifications(for activity: Activity) {
        cancelNotifications(for: activity)
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = activity.title
        content.body = activity.subtitle.isEmpty ? "Time for your activity!" : activity.subtitle
        content.sound = .default

        switch activity.recurrence {
        case .daily:
            for (index, time) in activity.dailyTimes.enumerated() {
                let components = Calendar.current.dateComponents([.hour, .minute], from: time)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(activity.id.uuidString)_daily_\(index)",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }

        case .weekly:
            let time = activity.dailyTimes.first ?? Date()
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)

            for day in activity.selectedWeekdays {
                var components = DateComponents()
                components.weekday = day
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute

                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(activity.id.uuidString)_weekly_\(day)",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }

        case .monthly:
            let interval = TimeInterval(activity.monthlyIntervalDays * 86400)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(activity.id.uuidString)_monthly",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    // Aliase zum Löschen
    func cancelNotification(for activityID: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let idsToRemove = requests
                .filter { $0.identifier.starts(with: activityID.uuidString) }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }

    func cancelNotifications(for activity: Activity) {
        cancelNotification(for: activity.id)
    }
}

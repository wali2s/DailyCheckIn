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

    // Alias für CreateMomentView
    func scheduleNotification(for moment: Moment, time: Date, weekdays: Set<Int>?) {
        var updatedMoment = moment
        updatedMoment.dailyTimes = [time]
        if let weekdays = weekdays {
            updatedMoment.selectedWeekdays = weekdays
        }
        scheduleNotifications(for: updatedMoment)
    }

    // Hauptmethode
    func scheduleNotifications(for moment: Moment) {
        cancelNotifications(for: moment)
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = moment.title
        content.body = moment.subtitle.isEmpty ? "Time for your moment!" : moment.subtitle
        content.sound = .default

        switch moment.recurrence {
        case .daily:
            for (index, time) in moment.dailyTimes.enumerated() {
                let components = Calendar.current.dateComponents([.hour, .minute], from: time)
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(moment.id.uuidString)_daily_\(index)",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }

        case .weekly:
            let time = moment.dailyTimes.first ?? Date()
            let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: time)

            for day in moment.selectedWeekdays {
                var components = DateComponents()
                components.weekday = day
                components.hour = timeComponents.hour
                components.minute = timeComponents.minute

                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(moment.id.uuidString)_weekly_\(day)",
                    content: content,
                    trigger: trigger
                )
                center.add(request)
            }

        case .monthly:
            let interval = TimeInterval(moment.monthlyIntervalDays * 86400)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(moment.id.uuidString)_monthly",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }

    // Aliase zum Löschen
    func cancelNotification(for momentID: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let idsToRemove = requests
                .filter { $0.identifier.starts(with: momentID.uuidString) }
                .map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idsToRemove)
        }
    }

    func cancelNotifications(for moment: Moment) {
        cancelNotification(for: moment.id)
    }
}

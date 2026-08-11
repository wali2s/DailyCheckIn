//
//  NotificationService.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import Foundation
import Combine
import UserNotifications

final class NotificationService {
    
    private let notificationCenter: UNUserNotificationCenter
    
    private let personalReminderIdentifier =
        "personal.checkin.reminder"
    
    private let professionalReminderIdentifier =
        "professional.checkin.reminder"
    
    init(
        notificationCenter: UNUserNotificationCenter =
            .current()
    ) {
        self.notificationCenter = notificationCenter
    }
    
    func requestAuthorization() -> AnyPublisher<Bool, Never> {
        Future { [notificationCenter] promise in
            notificationCenter.requestAuthorization(
                options: [
                    .alert,
                    .sound,
                    .badge
                ]
            ) { granted, _ in
                promise(.success(granted))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func schedulePersonalReminder(
        hour: Int,
        minute: Int
    ) -> AnyPublisher<Void, Error> {
        scheduleReminder(
            identifier: personalReminderIdentifier,
            title: "Personal Check-In",
            body: "Take a moment to reflect on your personal day.",
            hour: hour,
            minute: minute
        )
    }
    
    func scheduleProfessionalReminder(
        hour: Int,
        minute: Int
    ) -> AnyPublisher<Void, Error> {
        scheduleReminder(
            identifier: professionalReminderIdentifier,
            title: "Professional Check-In",
            body: "Reflect on your professional day.",
            hour: hour,
            minute: minute
        )
    }
    
    func cancelPersonalReminder() {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [
                personalReminderIdentifier
            ]
        )
    }
    
    func cancelProfessionalReminder() {
        notificationCenter.removePendingNotificationRequests(
            withIdentifiers: [
                professionalReminderIdentifier
            ]
        )
    }
    
    private func scheduleReminder(
        identifier: String,
        title: String,
        body: String,
        hour: Int,
        minute: Int
    ) -> AnyPublisher<Void, Error> {
        Future { [notificationCenter] promise in
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )
            
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )
            
            notificationCenter.removePendingNotificationRequests(
                withIdentifiers: [
                    identifier
                ]
            )
            
            notificationCenter.add(request) { error in
                if let error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

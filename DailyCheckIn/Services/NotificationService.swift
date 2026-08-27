//
//  NotificationService.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import Foundation
import Combine
import UserNotifications

final class NotificationService:
    NSObject,
    UNUserNotificationCenterDelegate {
    
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
        
        super.init()
        
        self.notificationCenter.delegate = self
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
            body: "Take a activity to reflect on your personal day.",
            reminderType: "personal",
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
            reminderType: "professional",
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
        reminderType: String,
        hour: Int,
        minute: Int
    ) -> AnyPublisher<Void, Error> {
        Future { [notificationCenter] promise in
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            content.userInfo = [
                "reminderType": reminderType
            ]
            
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
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
            @escaping (
                UNNotificationPresentationOptions
            ) -> Void
    ) {
        completionHandler([
            .banner,
            .sound,
            .badge
        ])
    }
    
    func notificationPermissionStatus()
        -> AnyPublisher<UNAuthorizationStatus, Never> {
        
        Future { [notificationCenter] promise in
            notificationCenter.getNotificationSettings { settings in
                promise(
                    .success(
                        settings.authorizationStatus
                    )
                )
            }
        }
        .eraseToAnyPublisher()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler:
            @escaping () -> Void
    ) {
        let userInfo =
            response.notification.request.content.userInfo
        
        guard let reminderType =
            userInfo["reminderType"] as? String
        else {
            completionHandler()
            return
        }
        
        NotificationCenter.default.post(
            name: .checkInReminderSelected,
            object: reminderType
        )
        
        completionHandler()
    }
}

extension Notification.Name {
    static let checkInReminderSelected =
        Notification.Name(
            "checkInReminderSelected"
        )
}

//
//  SettingsViewModel.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    
    @Published private(set) var personalReminderEnabled: Bool
    @Published private(set) var professionalReminderEnabled: Bool
    
    @Published private(set) var personalReminderTime: Date
    @Published private(set) var professionalReminderTime: Date
    
    @Published private(set) var statusMessage: String = ""
    
    private let notificationService: NotificationService
    private let userDefaults: UserDefaults
    private let calendar = Calendar.current
    
    private var cancellables = Set<AnyCancellable>()
    
    private let personalReminderEnabledKey =
        "personal_reminder_enabled"
    
    private let professionalReminderEnabledKey =
        "professional_reminder_enabled"
    
    private let personalReminderHourKey =
        "personal_reminder_hour"
    
    private let personalReminderMinuteKey =
        "personal_reminder_minute"
    
    private let professionalReminderHourKey =
        "professional_reminder_hour"
    
    private let professionalReminderMinuteKey =
        "professional_reminder_minute"
    
    init(
        notificationService: NotificationService =
            NotificationService(),
        userDefaults: UserDefaults = .standard
    ) {
        self.notificationService = notificationService
        self.userDefaults = userDefaults
        
        self.personalReminderEnabled = userDefaults.bool(
            forKey: personalReminderEnabledKey
        )
        
        self.professionalReminderEnabled = userDefaults.bool(
            forKey: professionalReminderEnabledKey
        )
        
        self.personalReminderTime = Self.loadTime(
            from: userDefaults,
            hourKey: personalReminderHourKey,
            minuteKey: personalReminderMinuteKey,
            defaultHour: 20,
            defaultMinute: 0
        )
        
        self.professionalReminderTime = Self.loadTime(
            from: userDefaults,
            hourKey: professionalReminderHourKey,
            minuteKey: professionalReminderMinuteKey,
            defaultHour: 17,
            defaultMinute: 30
        )
    }
    
    func updatePersonalReminderEnabled(
        _ isEnabled: Bool
    ) {
        personalReminderEnabled = isEnabled
        
        userDefaults.set(
            isEnabled,
            forKey: personalReminderEnabledKey
        )
        
        if isEnabled {
            schedulePersonalReminder()
        } else {
            notificationService.cancelPersonalReminder()
            statusMessage = "Personal reminder disabled."
        }
    }
    
    func updateProfessionalReminderEnabled(
        _ isEnabled: Bool
    ) {
        professionalReminderEnabled = isEnabled
        
        userDefaults.set(
            isEnabled,
            forKey: professionalReminderEnabledKey
        )
        
        if isEnabled {
            scheduleProfessionalReminder()
        } else {
            notificationService.cancelProfessionalReminder()
            statusMessage = "Professional reminder disabled."
        }
    }
    
    func updatePersonalReminderTime(
        _ time: Date
    ) {
        personalReminderTime = time
        
        saveTime(
            time,
            hourKey: personalReminderHourKey,
            minuteKey: personalReminderMinuteKey
        )
        
        if personalReminderEnabled {
            schedulePersonalReminder()
        }
    }
    
    func updateProfessionalReminderTime(
        _ time: Date
    ) {
        professionalReminderTime = time
        
        saveTime(
            time,
            hourKey: professionalReminderHourKey,
            minuteKey: professionalReminderMinuteKey
        )
        
        if professionalReminderEnabled {
            scheduleProfessionalReminder()
        }
    }
    
    private func schedulePersonalReminder() {
        let components = calendar.dateComponents(
            [.hour, .minute],
            from: personalReminderTime
        )
        
        guard let hour = components.hour,
              let minute = components.minute else {
            return
        }
        
        notificationService
            .requestAuthorization()
            .flatMap { [notificationService] granted
                -> AnyPublisher<Void, Error> in
                
                guard granted else {
                    return Fail(
                        error: SettingsError
                            .notificationPermissionDenied
                    )
                    .eraseToAnyPublisher()
                }
                
                return notificationService
                    .schedulePersonalReminder(
                        hour: hour,
                        minute: minute
                    )
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.statusMessage =
                            "Could not schedule personal reminder."
                    }
                },
                receiveValue: { [weak self] in
                    self?.statusMessage =
                        "Personal reminder scheduled."
                }
            )
            .store(in: &cancellables)
    }
    
    private func scheduleProfessionalReminder() {
        let components = calendar.dateComponents(
            [.hour, .minute],
            from: professionalReminderTime
        )
        
        guard let hour = components.hour,
              let minute = components.minute else {
            return
        }
        
        notificationService
            .requestAuthorization()
            .flatMap { [notificationService] granted
                -> AnyPublisher<Void, Error> in
                
                guard granted else {
                    return Fail(
                        error: SettingsError
                            .notificationPermissionDenied
                    )
                    .eraseToAnyPublisher()
                }
                
                return notificationService
                    .scheduleProfessionalReminder(
                        hour: hour,
                        minute: minute
                    )
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure = completion {
                        self?.statusMessage =
                            "Could not schedule professional reminder."
                    }
                },
                receiveValue: { [weak self] in
                    self?.statusMessage =
                        "Professional reminder scheduled."
                }
            )
            .store(in: &cancellables)
    }
    
    private func saveTime(
        _ date: Date,
        hourKey: String,
        minuteKey: String
    ) {
        let components = calendar.dateComponents(
            [.hour, .minute],
            from: date
        )
        
        userDefaults.set(
            components.hour ?? 0,
            forKey: hourKey
        )
        
        userDefaults.set(
            components.minute ?? 0,
            forKey: minuteKey
        )
    }
    
    private static func loadTime(
        from userDefaults: UserDefaults,
        hourKey: String,
        minuteKey: String,
        defaultHour: Int,
        defaultMinute: Int
    ) -> Date {
        let hour = userDefaults.object(
            forKey: hourKey
        ) as? Int ?? defaultHour
        
        let minute = userDefaults.object(
            forKey: minuteKey
        ) as? Int ?? defaultMinute
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        return Calendar.current.date(
            from: components
        ) ?? Date()
    }
    
    func setStatusMessage(
        _ message: String
    ) {
        statusMessage = message
    }
}

enum SettingsError: Error {
    case notificationPermissionDenied
}

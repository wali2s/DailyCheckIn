//
//  Activity.swift
//  DailyCheckIn
//
//  Created by Wahid on 20.08.26.
//

import Foundation

enum RecurrenceType: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var id: String { rawValue }
}

struct Activity: Identifiable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var iconName: String
    var period: ActivityPeriod
    var targetMinutes: Int
    var recurrence: RecurrenceType
    var dailyTimes: [Date]
    var selectedWeekdays: Set<Int>
    var monthlyIntervalDays: Int
    
    var isActive: Bool
    var notificationsEnabled: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String = "",
        iconName: String = "",
        period: ActivityPeriod = .morning,
        recurrence: RecurrenceType = .daily,
        targetMinutes: Int = 15,
        dailyTimes: [Date] = [Date()],
        selectedWeekdays: Set<Int>? = [2],
        monthlyIntervalDays: Int? = 30,
        isActive: Bool = true,
        notificationsEnabled: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.period = period
        self.targetMinutes = targetMinutes
        self.recurrence = recurrence
        self.dailyTimes = dailyTimes
        self.selectedWeekdays = selectedWeekdays ?? []
        self.monthlyIntervalDays = monthlyIntervalDays ?? 30
        
        self.isActive = isActive
        self.notificationsEnabled = notificationsEnabled
    }
}


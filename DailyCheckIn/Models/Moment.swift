//
//  Moment.swift
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

struct Moment: Identifiable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var iconName: String
    var period: MomentPeriod
    var isCompleted: Bool
    var targetMinutes: Int
    var recurrence: RecurrenceType
    var dailyTimes: [Date]
    var selectedWeekdays: Set<Int>
    var monthlyIntervalDays: Int
    
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String = "",
        iconName: String = "",
        period: MomentPeriod = .morning,
        isCompleted: Bool = false,
        recurrence: RecurrenceType = .daily,
        targetMinutes: Int = 15,
        dailyTimes: [Date] = [Date()],
        selectedWeekdays: Set<Int>? = [2],
        monthlyIntervalDays: Int? = 30
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.period = period
        self.isCompleted = isCompleted
        self.recurrence = recurrence
        self.dailyTimes = dailyTimes
        self.selectedWeekdays = selectedWeekdays ?? []
        self.monthlyIntervalDays = monthlyIntervalDays ?? 30
        self.targetMinutes = targetMinutes
    }
}

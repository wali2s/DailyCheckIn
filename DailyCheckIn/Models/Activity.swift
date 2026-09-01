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
    
    // Ziel-Tage pro Woche (z. B. 7 für täglich, oder die Anzahl der ausgewählten Tage)
    var targetDaysPerWeek: Int
    
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
        targetDaysPerWeek: Int? = nil,
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
        
        let weekdays = selectedWeekdays ?? []
        self.selectedWeekdays = weekdays
        self.monthlyIntervalDays = monthlyIntervalDays ?? 30
        
        // Wenn targetDaysPerWeek nicht explizit übergeben wird, berechnen wir es anhand der Recurrence
        if let targetDays = targetDaysPerWeek {
            self.targetDaysPerWeek = targetDays
        } else {
            switch recurrence {
            case .daily:
                self.targetDaysPerWeek = 7
            case .weekly:
                self.targetDaysPerWeek = weekdays.isEmpty ? 7 : weekdays.count
            case .monthly:
                self.targetDaysPerWeek = 1
            }
        }
        
        self.isActive = isActive
        self.notificationsEnabled = notificationsEnabled
    }
}

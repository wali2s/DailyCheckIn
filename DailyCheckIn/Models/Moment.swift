//
//  Moment.swift
//  DailyCheckIn
//
//  Created by Wahid on 20.08.26.
//

import Foundation

enum MomentPeriod: String, Codable, CaseIterable, Hashable, Identifiable {
    case today
    case week
    case month
    
    var id: String { rawValue }
}

struct Moment: Identifiable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var period: MomentPeriod
    var isCompleted: Bool
    var iconName: String
    
    
    var targetMinutes: Int?
    var selectedWeekdays: Set<Int>?
    var daysPerMonth: Int?

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String = "",
        period: MomentPeriod,
        isCompleted: Bool = false,
        iconName: String = "",
        targetMinutes: Int? = nil,
        selectedWeekdays: Set<Int>? = nil,
        daysPerMonth: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.period = period
        self.isCompleted = isCompleted
        self.iconName = iconName
        self.targetMinutes = targetMinutes
        self.selectedWeekdays = selectedWeekdays
        self.daysPerMonth = daysPerMonth
    }
}


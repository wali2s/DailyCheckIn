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
    var startDate: Date
    var title: String
    var subtitle: String
    var iconName: String
    var period: ActivityPeriod
    var targetMinutes: Int
    var recurrence: RecurrenceType
    var dailyTimes: [Date]
    var selectedWeekdays: Set<Int>
    var monthlyIntervalDays: Int
    
    var targetDaysPerWeek: Int
    
    var isActive: Bool
    var notificationsEnabled: Bool
    
    init(
        id: UUID = UUID(),
        startDate: Date = Date(),
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
        self.startDate = startDate
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
    
    enum CodingKeys: String, CodingKey {
        case id
        case startDate
        case title
        case subtitle
        case iconName
        case period
        case targetMinutes
        case recurrence
        case dailyTimes
        case selectedWeekdays
        case monthlyIntervalDays
        case targetDaysPerWeek
        case isActive
        case notificationsEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        self.init(
            id: try container.decode(UUID.self, forKey: .id),
            startDate: try container.decodeIfPresent(
                Date.self,
                forKey: .startDate
            ) ?? Date(),
            title: try container.decode(
                String.self,
                forKey: .title
            ),
            subtitle: try container.decodeIfPresent(
                String.self,
                forKey: .subtitle
            ) ?? "",
            iconName: try container.decodeIfPresent(
                String.self,
                forKey: .iconName
            ) ?? "",
            period: try container.decodeIfPresent(
                ActivityPeriod.self,
                forKey: .period
            ) ?? .morning,
            recurrence: try container.decodeIfPresent(
                RecurrenceType.self,
                forKey: .recurrence
            ) ?? .daily,
            targetMinutes: try container.decodeIfPresent(
                Int.self,
                forKey: .targetMinutes
            ) ?? 15,
            dailyTimes: try container.decodeIfPresent(
                [Date].self,
                forKey: .dailyTimes
            ) ?? [Date()],
            selectedWeekdays: try container.decodeIfPresent(
                Set<Int>.self,
                forKey: .selectedWeekdays
            ),
            monthlyIntervalDays: try container.decodeIfPresent(
                Int.self,
                forKey: .monthlyIntervalDays
            ),
            targetDaysPerWeek: try container.decodeIfPresent(
                Int.self,
                forKey: .targetDaysPerWeek
            ),
            isActive: try container.decodeIfPresent(
                Bool.self,
                forKey: .isActive
            ) ?? true,
            notificationsEnabled: try container.decodeIfPresent(
                Bool.self,
                forKey: .notificationsEnabled
            ) ?? false
        )
    }
}

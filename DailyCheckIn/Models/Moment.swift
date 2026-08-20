//
//  Moment.swift
//  DailyCheckIn
//
//  Created by Wahid on 20.08.26.
//

import Foundation

enum MomentPeriod: String, Codable, CaseIterable, Hashable {
    case today
    case week
    case month
}


struct Moment: Identifiable, Codable, Hashable {
    
    let id: UUID
    var title: String
    var subtitle: String
    var period: MomentPeriod
    
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String = "",
        period: MomentPeriod,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.period = period
        self.isCompleted = isCompleted
    }
}



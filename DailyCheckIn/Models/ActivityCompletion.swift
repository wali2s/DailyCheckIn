//
//  ActivityCompletion.swift
//  DailyCheckIn
//
//  Created by Wahid on 25.08.26.
//

import Foundation

struct ActivityCompletion: Identifiable, Codable, Hashable {
    
    let id: UUID
    let ActivityID: UUID
    let date: Date
    
    init(
        id: UUID = UUID(),
        activityID: UUID,
        date: Date = Date()
    ) {
        self.id = id
        self.ActivityID = activityID
        self.date = date
    }
}

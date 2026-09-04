//
//  DailyCheckInBackup.swift
//  DailyCheckIn
//
//  Created by Wahid on 04.09.26.
//

import Foundation

struct DailyCheckInBackup: Codable {
    static let currentVersion = 1

    let version: Int
    let exportedAt: Date
    let checkIns: [CheckIn]
    let activities: [Activity]
    let activityCompletions: [ActivityCompletion]

    init(
        version: Int = DailyCheckInBackup.currentVersion,
        exportedAt: Date = Date(),
        checkIns: [CheckIn],
        activities: [Activity],
        activityCompletions: [ActivityCompletion]
    ) {
        self.version = version
        self.exportedAt = exportedAt
        self.checkIns = checkIns
        self.activities = activities
        self.activityCompletions = activityCompletions
    }
}

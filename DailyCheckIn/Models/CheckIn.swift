//
//  CheckIn.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import Foundation

struct CheckIn: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var space: JournalSpace
    var mood: Mood
    var energyLevel: Int
    var stressLevel: Int
    var note: String
    var tags: [String]
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        space: JournalSpace,
        mood: Mood,
        energyLevel: Int = 3,
        stressLevel: Int = 3,
        note:String = "",
        tags: [String] = []
    ) {
        self.id = id
        self.date = date
        self.space = space
        self.mood = mood
        self.energyLevel = energyLevel
        self.stressLevel = stressLevel
        self.note = note
        self.tags = tags
    }
}

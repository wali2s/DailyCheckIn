//
//  CheckInViewModel.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import Foundation
import Combine

final class CheckinViewModel: ObservableObject {
    
    let space: JournalSpace
    
    @Published var mood: Mood
    @Published var energyLevel: Int
    @Published var stressLevel: Int
    @Published var note: String
    @Published var tagsText: String

    
    init(space: JournalSpace, existingCheckin: CheckIn? = nil) {
        self.space = space
        
        self.mood = existingCheckin?.mood ?? .neutral
        self.energyLevel = existingCheckin?.energyLevel ?? 3
        self.stressLevel = existingCheckin?.stressLevel ?? 3
        self.note = existingCheckin?.note ?? ""
        self.tagsText = existingCheckin?.tags.joined(separator: ", ") ?? ""
    }
    
    func makeCheckin() -> CheckIn {
        CheckIn(
            space: space,
            mood: mood,
            energyLevel: energyLevel,
            stressLevel: stressLevel,
            note: note,
            tags: parsedTags
        )
    }
    
    private var parsedTags: [String] {
        tagsText
            .split(separator: ",")
            .map {$0.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter{!$0.isEmpty}
    }
}

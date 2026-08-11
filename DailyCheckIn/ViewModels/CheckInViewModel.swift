//
//  CheckInViewModel.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import Foundation
import Combine

final class CheckInViewModel: ObservableObject {
    
    let space: JournalSpace
    
    @Published var mood: Mood
    @Published var energyLevel: Int
    @Published var stressLevel: Int
    @Published var note: String
    @Published var tagsText: String
    
    private let checkInID: UUID
    private let checkInDate: Date
    
    init(
        space: JournalSpace,
        existingCheckIn: CheckIn? = nil
    ) {
        self.space = space
        
        self.checkInID = existingCheckIn?.id ?? UUID()
        self.checkInDate = existingCheckIn?.date ?? Date()
        
        self.mood = existingCheckIn?.mood ?? .neutral
        self.energyLevel = existingCheckIn?.energyLevel ?? 3
        self.stressLevel = existingCheckIn?.stressLevel ?? 3
        self.note = existingCheckIn?.note ?? ""
        self.tagsText = existingCheckIn?.tags.joined(
            separator: ", "
        ) ?? ""
    }
    
    func makeCheckIn() -> CheckIn {
        CheckIn(
            id: checkInID,
            date: checkInDate,
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
            .map {
                $0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
            }
            .filter {
                !$0.isEmpty
            }
    }
}

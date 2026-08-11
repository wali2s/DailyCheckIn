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
    
    @Published var mood: Mood = .neutral
    @Published var energyLevel: Int = 3
    @Published var stressLevel: Int = 3
    @Published var note: String = ""
    
    init(space: JournalSpace) {
        self.space = space
    }
    
    func makeCheckin() -> CheckIn {
        CheckIn(
            space: space,
            mood: mood,
            energyLevel: energyLevel,
            stressLevel: stressLevel,
            note: note
        )
    }
}

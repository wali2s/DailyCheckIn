//
//  HomeViewModel.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    
    @Published private (set) var checkIns: [CheckIn] = []
    @Published var selectedSpace: JournalSpace = .personal
    
    private let calendar = Calendar.current
    
    var todayCheckIns: [CheckIn] {
        checkIns.filter { checkin in
            calendar.isDateInToday(checkin.date)
        }
    }
    
    var personalCheckInToday: CheckIn? {
        todayCheckIns.first { checkin in
            checkin.space == .personal}
    }
    
    var professinalCheckInToday: CheckIn? {
        todayCheckIns.first { checkin in
            checkin.space == .professional}
    }
    
    init() {
        loadSampleData()
    }
    
    func addCheckIn(_ checkIn: CheckIn) {
        checkIns.append(checkIn)
    }
    
    func deleteCheckIn(_ checkIn: CheckIn) {
        checkIns.removeAll { existingCheckIn in
            existingCheckIn.id == checkIn.id
        }
    }
    
    func checkIn ( for space: JournalSpace) -> CheckIn? {
        todayCheckIns.first { checkin in
            checkin.space == space
        }
    }
    
    private func loadSampleData() {
        let personalCheckIn = CheckIn(
                    space: .personal,
                    mood: .good,
                    energyLevel: 4,
                    stressLevel: 2,
                    notes: "Had a calm and productive day.",
                    tags: ["Calm", "Productive"]
                )
                
                checkIns = [personalCheckIn]
    }
}

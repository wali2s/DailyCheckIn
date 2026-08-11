//
//  HomeViewModel.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    
    @Published private(set) var checkIns: [CheckIn] = []
    @Published var selectedSpace: JournalSpace = .personal
    
    private let calendar = Calendar.current
    private let storageService: CheckInStorageService
    
    
    
    init(storageService: CheckInStorageService) {
        self.storageService = storageService
        self.checkIns = storageService.loadCheckIns()
        
    }
    
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
    
    func addCheckIn(_ checkIn: CheckIn) {
        if let existingIndex = checkIns.firstIndex(where: { existingCheckIn in
            existingCheckIn.space == checkIn.space &&
            calendar.isDate(
                existingCheckIn.date,
                inSameDayAs: checkIn.date
            )
        }) {
            let existingCheckIn = checkIns[existingIndex]
            
            let updatedCheckIn = CheckIn(
                id: existingCheckIn.id,
                date: checkIn.date,
                space: checkIn.space,
                mood: checkIn.mood,
                energyLevel: checkIn.energyLevel,
                stressLevel: checkIn.stressLevel,
                note: checkIn.note,
                tags: checkIn.tags
            )
            
            checkIns[existingIndex] = updatedCheckIn
        } else {
            checkIns.append(checkIn)
        }
        
        saveCheckIns()
    }
    
    func deleteCheckIn(_ checkIn: CheckIn) {
        checkIns.removeAll { existingCheckIn in
            existingCheckIn.id == checkIn.id
        }
        saveCheckIns()
    }
    
    func checkIn ( for space: JournalSpace) -> CheckIn? {
        todayCheckIns.first { checkin in
            checkin.space == space
        }
    }
    
    
    private func saveCheckIns() {
        storageService.saveCheckIns(checkIns)
    }
}

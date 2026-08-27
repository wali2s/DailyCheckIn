//
//  HomeViewModel.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    
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
    
    var currentStreak: Int {
        currentStreak(for: nil)
    }

    func currentStreak(
        for space: JournalSpace?
    ) -> Int {
        let relevantCheckIns: [CheckIn]
        
        if let space {
            relevantCheckIns = checkIns.filter {
                $0.space == space
            }
        } else {
            relevantCheckIns = checkIns
        }
        
        let checkInDays = Set(
            relevantCheckIns.map { checkIn in
                calendar.startOfDay(
                    for: checkIn.date
                )
            }
        )
        
        var streak = 0
        var currentDate = calendar.startOfDay(
            for: Date()
        )
        
        while checkInDays.contains(currentDate) {
            streak += 1
            
            guard let previousDate = calendar.date(
                byAdding: .day,
                value: -1,
                to: currentDate
            ) else {
                break
            }
            
            currentDate = previousDate
        }
        
        return streak
    }
    
    var personalCheckInToday: CheckIn? {
        todayCheckIns.first { checkin in
            checkin.space == .personal}
    }
    
    @available(*, deprecated, message: "Use professionalCheckInToday instead.")
    var professinalCheckInToday: CheckIn? {
        professionalCheckInToday
    }

    var professionalCheckInToday: CheckIn? {
        todayCheckIns.first { checkin in
            checkin.space == .professional
        }
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
    
    func deleteAllCheckIns() {
        checkIns.removeAll()
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
    
    var completedSpacesToday: Int {
        JournalSpace.allCases.filter { space in
            checkIn(for: space) != nil
        }
        .count
    }
    
    var totalSpaces: Int {
        JournalSpace.allCases.count
    }
    
    var dailyCompletionProgress: Double {
        guard totalSpaces > 0 else { return 0}
        
        return Double (completedSpacesToday) / Double(totalSpaces)
    }
    
    var dailyCompletionMessage: String {
        if completedSpacesToday == 0 {
            return "Start your daily check-in."
        }
        
        return "All spaces completed today."
    }
}


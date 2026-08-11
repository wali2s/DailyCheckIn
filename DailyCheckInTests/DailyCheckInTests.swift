//
//  DailyCheckInTests.swift
//  DailyCheckInTests
//
//  Created by Wahid on 10.08.26.
//

import Testing
@testable import DailyCheckIn

struct DailyCheckInTests {

    @Test
    func checkInStoreProvidedValues() {
        let checkIn = CheckIn (
            space: .personal,
            mood: .good,
            energyLevel: 4,
            stressLevel: 2,
            note: "had a productive day",
            tags: ["Productive"]
        )
        
        #expect(checkIn.space == .personal)
        #expect(checkIn.mood == .good)
        #expect(checkIn.energyLevel == 4)
        #expect(checkIn.stressLevel == 2)
        #expect(checkIn.note == "Had a productive day.")
        #expect(checkIn.tags == ["Productive"])
    }
    
    @Test
    func homeViewModelCanAddCheckIn() {
        let viewModel = HomeViewModel()
        let initialCount = viewModel.checkIns.count
        
        let checkIn = CheckIn(
            space: .professional,
            mood: .neutral,
            energyLevel: 3,
            stressLevel: 3,
            note: "Worked on the app"
        )
        
        viewModel.addCheckIn(checkIn)
        
        #expect( viewModel.checkIns.count == initialCount + 1)
        #expect(viewModel.checkIn(for: .professional)?.id == checkIn.id)
    }
    
    @Test
    func CheckInViewModelCreatesCorrectCheckIn() {
        let viewModel = CheckinViewModel(space: .professional)
        
        viewModel.mood = .veryGood
        viewModel.energyLevel = 5
        viewModel.stressLevel = 1
        viewModel.note = "Finished an important task."
        
        let checkIn = viewModel.makeCheckin()
        
        #expect(checkIn.space == .professional)
        #expect(checkIn.mood == .veryGood)
        #expect(checkIn.energyLevel == 5)
        #expect(checkIn.stressLevel == 1)
        #expect(checkIn.note == "Finished an important task.")

        
    }
}


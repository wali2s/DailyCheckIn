//
//  DailyCheckInTests.swift
//  DailyCheckInTests
//
//  Created by Wahid on 10.08.26.
//

import Foundation
import Testing

@testable import DailyCheckIn

struct DailyCheckInTests {
    
    @Test
    func checkInStoresProvidedValues() {
        let checkIn = CheckIn(
            space: .personal,
            mood: .good,
            energyLevel: 4,
            stressLevel: 2,
            note: "Had a productive day.",
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
    func checkInViewModelCreatesCorrectCheckIn() {
        let viewModel = CheckinViewModel(
            space: .professional
        )
        
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
    
    @Test
    func homeViewModelCanAddCheckIn() {
        let suiteName = "DailyCheckIn.HomeViewModelTests"
        
        let testDefaults = UserDefaults(
            suiteName: suiteName
        )!
        
        testDefaults.removePersistentDomain(
            forName: suiteName
        )
        
        defer {
            testDefaults.removePersistentDomain(
                forName: suiteName
            )
        }
        
        let storageService = UserDefaultsCheckInStorageService(
            userDefaults: testDefaults
        )
        
        let viewModel = HomeViewModel(
            storageService: storageService
        )
        
        #expect(viewModel.checkIns.isEmpty)
        
        let checkIn = CheckIn(
            space: .professional,
            mood: .neutral,
            energyLevel: 3,
            stressLevel: 3,
            note: "Worked on the app."
        )
        
        viewModel.addCheckIn(checkIn)
        
        #expect(viewModel.checkIns.count == 1)
        #expect(
            viewModel.checkIn(
                for: .professional
            )?.id == checkIn.id
        )
    }
    
    @Test
    func storageSavesAndLoadsCheckIns() {
        let suiteName = "DailyCheckIn.StorageTests"
        
        let testDefaults = UserDefaults(
            suiteName: suiteName
        )!
        
        testDefaults.removePersistentDomain(
            forName: suiteName
        )
        
        defer {
            testDefaults.removePersistentDomain(
                forName: suiteName
            )
        }
        
        let storageService = UserDefaultsCheckInStorageService(
            userDefaults: testDefaults
        )
        
        let originalCheckIn = CheckIn(
            space: .professional,
            mood: .good,
            energyLevel: 4,
            stressLevel: 2,
            note: "Worked on persistence.",
            tags: ["Development"]
        )
        
        storageService.saveCheckIns(
            [originalCheckIn]
        )
        
        let loadedCheckIns = storageService.loadCheckIns()
        
        #expect(loadedCheckIns.count == 1)
        #expect(
            loadedCheckIns.first?.id == originalCheckIn.id
        )
        #expect(
            loadedCheckIns.first?.space == .professional
        )
        #expect(
            loadedCheckIns.first?.mood == .good
        )
        #expect(
            loadedCheckIns.first?.energyLevel == 4
        )
        #expect(
            loadedCheckIns.first?.stressLevel == 2
        )
        #expect(
            loadedCheckIns.first?.note == "Worked on persistence."
        )
        #expect(
            loadedCheckIns.first?.tags == ["Development"]
        )
    }
    
    @Test
    func storageReturnsEmptyArrayWhenNoDataExists() {
        let suiteName = "DailyCheckIn.EmptyStorageTests"
        
        let testDefaults = UserDefaults(
            suiteName: suiteName
        )!
        
        testDefaults.removePersistentDomain(
            forName: suiteName
        )
        
        defer {
            testDefaults.removePersistentDomain(
                forName: suiteName
            )
        }
        
        let storageService = UserDefaultsCheckInStorageService(
            userDefaults: testDefaults
        )
        
        let loadedCheckIns = storageService.loadCheckIns()
        
        #expect(loadedCheckIns.isEmpty)
    }
}

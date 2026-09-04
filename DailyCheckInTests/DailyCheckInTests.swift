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
            focusLevel: 5,
            socialBattery: 4,
            physicalTension: 2,
            note: "Had a productive day.",
            tags: ["Productive"]
        )
        
        #expect(checkIn.space == .personal)
        #expect(checkIn.mood == .good)
        #expect(checkIn.energyLevel == 4)
        #expect(checkIn.stressLevel == 2)
        #expect(checkIn.focusLevel == 5)
        #expect(checkIn.socialBattery == 4)
        #expect(checkIn.physicalTension == 2)
        #expect(checkIn.note == "Had a productive day.")
        #expect(checkIn.tags == ["Productive"])
    }
    
    @Test
    func checkInViewModelCreatesCorrectCheckIn() {
        let viewModel = CheckInViewModel(
            space: .professional
        )
        
        viewModel.mood = .happy
        viewModel.energyLevel = 5
        viewModel.stressLevel = 1
        viewModel.focusLevel = 4
        viewModel.socialBattery = 2
        viewModel.physicalTension = 3
        viewModel.note = "Finished an important task."
        
        let checkIn = viewModel.makeCheckIn()
        
        #expect(checkIn.space == .professional)
        #expect(checkIn.mood == .happy)
        #expect(checkIn.energyLevel == 5)
        #expect(checkIn.stressLevel == 1)
        #expect(checkIn.focusLevel == 4)
        #expect(checkIn.socialBattery == 2)
        #expect(checkIn.physicalTension == 3)
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
            focusLevel: 5,
            socialBattery: 4,
            physicalTension: 2,
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
            loadedCheckIns.first?.focusLevel == 5
        )
        #expect(
            loadedCheckIns.first?.socialBattery == 4
        )
        #expect(
            loadedCheckIns.first?.physicalTension == 2
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

    @Test
    func updatingCheckInPreservesFactorsAndDetailedMetrics() throws {
        let storageService = InMemoryCheckInStorageService()
        let viewModel = HomeViewModel(storageService: storageService)
        let date = Date()
        let existingCheckIn = CheckIn(
            date: date,
            space: .personal,
            mood: .neutral,
            energyLevel: 3,
            stressLevel: 3,
            focusLevel: 2,
            socialBattery: 2,
            physicalTension: 4,
            note: "Before editing.",
            tags: ["Rest"],
            personalFactors: [.sleepiness],
            professionalFactors: []
        )
        viewModel.addCheckIn(existingCheckIn)

        let updatedCheckIn = CheckIn(
            date: date,
            space: .personal,
            mood: .good,
            energyLevel: 4,
            stressLevel: 2,
            focusLevel: 5,
            socialBattery: 4,
            physicalTension: 3,
            note: "After editing.",
            tags: ["Walk"],
            personalFactors: [.rested, .relaxed],
            professionalFactors: []
        )
        viewModel.addCheckIn(updatedCheckIn)

        let savedCheckIn = try #require(viewModel.checkIn(for: .personal))
        #expect(viewModel.checkIns.count == 1)
        #expect(savedCheckIn.id == existingCheckIn.id)
        #expect(savedCheckIn.focusLevel == 5)
        #expect(savedCheckIn.socialBattery == 4)
        #expect(savedCheckIn.physicalTension == 3)
        #expect(savedCheckIn.personalFactors == [.rested, .relaxed])
        #expect(savedCheckIn.tags == ["Walk"])
    }

    @Test
    func decodingLegacyCheckInUsesNeutralDefaultsForDetailedMetrics() throws {
        let data = Data("""
        {
          "id": "00000000-0000-0000-0000-000000000001",
          "date": "2026-09-02T12:00:00Z",
          "space": "personal",
          "mood": "neutral",
          "energyLevel": 3,
          "stressLevel": 3,
          "note": "Legacy entry",
          "tags": [],
          "personalFactors": [],
          "professionalFactors": []
        }
        """.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let checkIn = try decoder.decode(CheckIn.self, from: data)

        #expect(checkIn.focusLevel == 3)
        #expect(checkIn.socialBattery == 3)
        #expect(checkIn.physicalTension == 3)
    }

    @Test
    func updatingActivityPreservesAllStoredValues() {
        let storageService = InMemoryActivityStorageService()
        let viewModel = ActivityViewModel(storageService: storageService)
        let reminderTime = Date(timeIntervalSince1970: 1_725_315_600)
        let activity = Activity(
            title: "Read",
            subtitle: "A chapter before bed.",
            iconName: "book.fill",
            period: .evening,
            recurrence: .weekly,
            targetMinutes: 30,
            dailyTimes: [reminderTime],
            selectedWeekdays: [2, 4, 6],
            monthlyIntervalDays: 12,
            targetDaysPerWeek: 3,
            isActive: false,
            notificationsEnabled: true
        )
        viewModel.addActivity(activity)

        viewModel.updateActivity(activity)

        let savedActivity = viewModel.activities.first
        #expect(savedActivity?.id == activity.id)
        #expect(savedActivity?.subtitle == "A chapter before bed.")
        #expect(savedActivity?.targetMinutes == 30)
        #expect(savedActivity?.dailyTimes == [reminderTime])
        #expect(savedActivity?.selectedWeekdays == [2, 4, 6])
        #expect(savedActivity?.monthlyIntervalDays == 12)
        #expect(savedActivity?.targetDaysPerWeek == 3)
        #expect(savedActivity?.isActive == false)
        #expect(savedActivity?.notificationsEnabled == true)
    }
    
    @Test
    func userCanCreateOneCheckInForEachSpacePerDay() {
        let suiteName = "DailyCheckIn.DailySpacesTests"

        let testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)

        defer {
            testDefaults.removePersistentDomain(forName: suiteName)
        }

        let storageService = UserDefaultsCheckInStorageService(
            userDefaults: testDefaults
        )

        let viewModel = HomeViewModel(
            storageService: storageService
        )

        let personalCheckIn = CheckIn(
            space: .personal,
            mood: .neutral
        )

        let professionalCheckIn = CheckIn(
            space: .professional,
            mood: .good
        )

        let updatedPersonalCheckIn = CheckIn(
            space: .personal,
            mood: .happy
        )

        viewModel.addCheckIn(personalCheckIn)
        viewModel.addCheckIn(professionalCheckIn)
        viewModel.addCheckIn(updatedPersonalCheckIn)

        #expect(viewModel.checkIns.count == 2)
        #expect(viewModel.checkIn(for: .personal)?.mood == .happy)
        #expect(viewModel.checkIn(for: .professional)?.mood == .good)
    }
    
    @Test
    func statisticsCalculateDetailedMetricAveragesForSelectedSpace() {
        let suiteName = "DailyCheckIn.StatisticsTests"

        let testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)

        defer {
            testDefaults.removePersistentDomain(forName: suiteName)
        }

        let storageService = UserDefaultsCheckInStorageService(
            userDefaults: testDefaults
        )

        storageService.saveCheckIns([
            CheckIn(
                space: .personal,
                mood: .neutral,
                focusLevel: 2,
                socialBattery: 3,
                physicalTension: 1
            ),
            CheckIn(
                space: .personal,
                mood: .good,
                focusLevel: 4,
                socialBattery: 5,
                physicalTension: 5
            ),
            CheckIn(
                space: .professional,
                mood: .happy,
                focusLevel: 5,
                socialBattery: 1,
                physicalTension: 2
            )
        ])

        let homeViewModel = HomeViewModel(
            storageService: storageService
        )

        let statisticsViewModel = StatisticsViewModel(
            homeViewModel: homeViewModel
        )

        statisticsViewModel.selectedSpace = .personal
        statisticsViewModel.selectedPeriod = .allTime

        #expect(statisticsViewModel.averageFocus == 3)
        #expect(statisticsViewModel.averageSocialBattery == 4)
        #expect(statisticsViewModel.averagePhysicalTension == 3)
    }
    
    @Test
    func insightsRequireAtLeastThreeCheckIns() {
        let suiteName = "DailyCheckIn.InsightThresholdTests"

        let testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)

        defer {
            testDefaults.removePersistentDomain(forName: suiteName)
        }

        let storageService = UserDefaultsCheckInStorageService(
            userDefaults: testDefaults
        )

        storageService.saveCheckIns([
            CheckIn(
                space: .personal,
                mood: .good
            ),
            CheckIn(
                space: .personal,
                mood: .neutral
            )
        ])

        let homeViewModel = HomeViewModel(
            storageService: storageService
        )

        let statisticsViewModel = StatisticsViewModel(
            homeViewModel: homeViewModel
        )

        statisticsViewModel.selectedSpace = .personal
        statisticsViewModel.selectedPeriod = .allTime

        #expect(statisticsViewModel.hasEnoughDataForInsights == false)
        #expect(statisticsViewModel.insights.isEmpty)
    }
    
    @Test
    func statisticsShowMostFrequentPersonalFactors() {
        let suiteName = "DailyCheckIn.FactorStatisticsTests"

        let testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)

        defer {
            testDefaults.removePersistentDomain(forName: suiteName)
        }

        let storageService = UserDefaultsCheckInStorageService(
            userDefaults: testDefaults
        )

        storageService.saveCheckIns([
            CheckIn(
                space: .personal,
                mood: .good,
                personalFactors: [.rested, .relaxed]
            ),
            CheckIn(
                space: .personal,
                mood: .happy,
                personalFactors: [.rested]
            ),
            CheckIn(
                space: .professional,
                mood: .good,
                professionalFactors: [.focus]
            )
        ])

        let homeViewModel = HomeViewModel(
            storageService: storageService
        )

        let statisticsViewModel = StatisticsViewModel(
            homeViewModel: homeViewModel
        )

        statisticsViewModel.selectedSpace = .personal
        statisticsViewModel.selectedPeriod = .allTime

        #expect(
            statisticsViewModel.mostFrequentFactors.map(\.title)
            == ["Rested", "Relaxed"]
        )

        #expect(
            statisticsViewModel.mostFrequentFactors.map(\.count)
            == [2, 1]
        )
    }
    
    @Test
    func factorMoodComparisonShowsMoodDifference() throws {
        let suiteName = "DailyCheckIn.FactorMoodComparisonTests"

        let testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)

        defer {
            testDefaults.removePersistentDomain(forName: suiteName)
        }

        let storageService = UserDefaultsCheckInStorageService(
            userDefaults: testDefaults
        )

        let calendar = Calendar.current
        let today = Date()

        let checkIns = [
            CheckIn(
                date: calendar.date(
                    byAdding: .day,
                    value: -5,
                    to: today
                )!,
                space: .personal,
                mood: .happy,
                personalFactors: [.rested]
            ),
            CheckIn(
                date: calendar.date(
                    byAdding: .day,
                    value: -4,
                    to: today
                )!,
                space: .personal,
                mood: .happy,
                personalFactors: [.rested]
            ),
            CheckIn(
                date: calendar.date(
                    byAdding: .day,
                    value: -3,
                    to: today
                )!,
                space: .personal,
                mood: .happy,
                personalFactors: [.rested]
            ),
            CheckIn(
                date: calendar.date(
                    byAdding: .day,
                    value: -2,
                    to: today
                )!,
                space: .personal,
                mood: .sad
            ),
            CheckIn(
                date: calendar.date(
                    byAdding: .day,
                    value: -1,
                    to: today
                )!,
                space: .personal,
                mood: .sad
            ),
            CheckIn(
                date: today,
                space: .personal,
                mood: .sad
            )
        ]

        storageService.saveCheckIns(checkIns)

        let homeViewModel = HomeViewModel(
            storageService: storageService
        )

        let statisticsViewModel = StatisticsViewModel(
            homeViewModel: homeViewModel
        )

        statisticsViewModel.selectedSpace = .personal
        statisticsViewModel.selectedPeriod = .allTime

        let comparison = try #require(
            statisticsViewModel.factorMoodComparisons.first
        )

        #expect(comparison.title == "Rested")
        #expect(comparison.occurrenceCount == 3)
        #expect(comparison.averageMoodWithFactor == 5)
        #expect(comparison.averageMoodWithoutFactor == 2)
        #expect(comparison.moodDifference == 3)
    }
    
    @Test
    func checkInViewModelRestoresDetailedMetricsWhenEditing() {
        let existingCheckIn = CheckIn(
            space: .personal,
            mood: .good,
            focusLevel: 4,
            socialBattery: 2,
            physicalTension: 5
        )

        let viewModel = CheckInViewModel(
            space: .personal,
            existingCheckIn: existingCheckIn
        )

        #expect(viewModel.focusLevel == 4)
        #expect(viewModel.socialBattery == 2)
        #expect(viewModel.physicalTension == 5)
    }
    
    @Test
    func statisticsMetricReturnsTheCorrectCheckInValue() {
        let checkIn = CheckIn(
            space: .personal,
            mood: .good,
            energyLevel: 3,
            stressLevel: 2,
            focusLevel: 4,
            socialBattery: 5,
            physicalTension: 1
        )

        #expect(StatisticsMetric.mood.value(for: checkIn) == 4)
        #expect(StatisticsMetric.energy.value(for: checkIn) == 3)
        #expect(StatisticsMetric.stress.value(for: checkIn) == 2)
        #expect(StatisticsMetric.focus.value(for: checkIn) == 4)
        #expect(StatisticsMetric.socialBattery.value(for: checkIn) == 5)
        #expect(StatisticsMetric.physicalComfort.value(for: checkIn) == 1)
    }
    
    @Test
    func backupStoresAllUserData() throws {
        let checkIn = CheckIn(
            space: .personal,
            mood: .good,
            focusLevel: 4,
            personalFactors: [.rested]
        )

        let activity = Activity(
            title: "Read",
            iconName: "book.fill",
            targetMinutes: 20
        )

        let completion = ActivityCompletion(
            activityID: activity.id
        )

        let backup = DailyCheckInBackup(
            checkIns: [checkIn],
            activities: [activity],
            activityCompletions: [completion]
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = try encoder.encode(backup)

        let restoredBackup = try decoder.decode(
            DailyCheckInBackup.self,
            from: data
        )

        #expect(
            restoredBackup.version
            == DailyCheckInBackup.currentVersion
        )

        #expect(restoredBackup.checkIns.first?.id == checkIn.id)
        #expect(restoredBackup.checkIns.first?.focusLevel == 4)
        #expect(restoredBackup.activities.first?.id == activity.id)
        #expect(
            restoredBackup.activityCompletions.first?.ActivityID
            == activity.id
        )
    }
    
    @Test
    func exportServiceCreatesDecodableBackupData() throws {
        let checkIn = CheckIn(
            space: .professional,
            mood: .good,
            focusLevel: 4
        )

        let backup = DailyCheckInBackup(
            checkIns: [checkIn],
            activities: [],
            activityCompletions: []
        )

        let exportService = CheckInExportService()

        let data = try exportService.makeBackupData(
            from: backup
        )

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let restoredBackup = try decoder.decode(
            DailyCheckInBackup.self,
            from: data
        )

        #expect(restoredBackup.checkIns.count == 1)
        #expect(restoredBackup.checkIns.first?.id == checkIn.id)
        #expect(restoredBackup.checkIns.first?.focusLevel == 4)
    }
    
    @Test
    func exportServiceCreatesBackupJSONFile() throws {
        let backup = DailyCheckInBackup(
            checkIns: [
                CheckIn(
                    space: .personal,
                    mood: .good
                )
            ],
            activities: [],
            activityCompletions: []
        )

        let exportService = CheckInExportService()

        let fileURL = try exportService.makeBackupFile(
            from: backup
        )

        defer {
            try? FileManager.default.removeItem(
                at: fileURL
            )
        }

        #expect(fileURL.pathExtension == "json")
        #expect(FileManager.default.fileExists(atPath: fileURL.path))

        let data = try Data(contentsOf: fileURL)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let restoredBackup = try decoder.decode(
            DailyCheckInBackup.self,
            from: data
        )

        #expect(restoredBackup.checkIns.count == 1)
        #expect(
            restoredBackup.checkIns.first?.mood == .good
        )
    }
    
    @Test
    func importServiceDecodesValidBackup() throws {
        let originalBackup = DailyCheckInBackup(
            checkIns: [
                CheckIn(
                    space: .personal,
                    mood: .happy,
                    focusLevel: 5
                )
            ],
            activities: [],
            activityCompletions: []
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(originalBackup)

        let importService = BackupImportService()

        let importedBackup = try importService.decodeBackup(
            from: data
        )

        #expect(
            importedBackup.version
            == DailyCheckInBackup.currentVersion
        )

        #expect(importedBackup.checkIns.count == 1)
        #expect(importedBackup.checkIns.first?.mood == .happy)
        #expect(importedBackup.checkIns.first?.focusLevel == 5)
    }
    
    @Test
    func mergeImportKeepsLocalDataAndAddsMissingData() {
        let suiteName = "DailyCheckIn.MergeImportTests"

        let testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)

        defer {
            testDefaults.removePersistentDomain(forName: suiteName)
        }

        let checkInStorage = UserDefaultsCheckInStorageService(
            userDefaults: testDefaults
        )

        let activityStorage = UserDefaultsActivityStorageService(
            userDefaults: testDefaults
        )

        activityStorage.saveActivities([])
        activityStorage.saveCompletions([])

        let homeViewModel = HomeViewModel(
            storageService: checkInStorage
        )

        let activityViewModel = ActivityViewModel(
            storageService: activityStorage
        )

        let today = Date()

        let localPersonalCheckIn = CheckIn(
            date: today,
            space: .personal,
            mood: .neutral
        )

        let importedDuplicatePersonalCheckIn = CheckIn(
            date: today,
            space: .personal,
            mood: .happy
        )

        let importedWorkCheckIn = CheckIn(
            date: today,
            space: .professional,
            mood: .good
        )

        homeViewModel.addCheckIn(localPersonalCheckIn)

        homeViewModel.mergeCheckIns(
            from: [
                importedDuplicatePersonalCheckIn,
                importedWorkCheckIn
            ]
        )

        #expect(homeViewModel.checkIns.count == 2)

        #expect(
            homeViewModel.checkIn(for: .personal)?.mood
            == .neutral
        )

        #expect(
            homeViewModel.checkIn(for: .professional)?.mood
            == .good
        )

        let localActivity = Activity(
            title: "Read",
            iconName: "book.fill"
        )

        let importedActivity = Activity(
            title: "Walk",
            iconName: "figure.walk"
        )

        activityViewModel.addActivity(localActivity)

        let importedCompletion = ActivityCompletion(
            activityID: importedActivity.id
        )

        activityViewModel.mergeStoredData(
            activities: [
                localActivity,
                importedActivity
            ],
            completions: [
                importedCompletion
            ]
        )

        #expect(activityViewModel.activities.count == 2)
        #expect(activityViewModel.completions.count == 1)

        #expect(
            activityViewModel.activities.contains {
                $0.id == importedActivity.id
            }
        )

        #expect(
            activityViewModel.completions.first?.ActivityID
            == importedActivity.id
        )
    }
    
    @Test
    func exportServiceCreatesSafetyBackupBeforeImport() throws {
        let backup = DailyCheckInBackup(
            checkIns: [
                CheckIn(
                    space: .personal,
                    mood: .good
                )
            ],
            activities: [],
            activityCompletions: []
        )

        let exportService = CheckInExportService()

        let fileURL = try exportService.makeSafetyBackupFile(
            from: backup
        )

        defer {
            try? FileManager.default.removeItem(
                at: fileURL
            )
        }

        #expect(FileManager.default.fileExists(atPath: fileURL.path))
        #expect(fileURL.pathExtension == "json")

        let data = try Data(contentsOf: fileURL)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let restoredBackup = try decoder.decode(
            DailyCheckInBackup.self,
            from: data
        )

        #expect(restoredBackup.checkIns.count == 1)
        #expect(restoredBackup.checkIns.first?.mood == .good)
    }
    
    @Test
    func exportServiceFindsLatestSafetyBackup() throws {
        let backup = DailyCheckInBackup(
            checkIns: [
                CheckIn(
                    space: .personal,
                    mood: .good
                )
            ],
            activities: [],
            activityCompletions: []
        )

        let exportService = CheckInExportService()

        let safetyBackupURL = try exportService.makeSafetyBackupFile(
            from: backup
        )

        defer {
            try? FileManager.default.removeItem(
                at: safetyBackupURL
            )
        }

        let latestBackupURL = try #require(
            exportService.latestSafetyBackupFile()
        )

        #expect(latestBackupURL == safetyBackupURL)
    }
    
    @Test
    @MainActor
    func appLockRequiresSuccessfulAuthentication() async {
        let suiteName = "DailyCheckIn.AppLockTests"

        let testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)

        defer {
            testDefaults.removePersistentDomain(forName: suiteName)
        }

        let failedLockViewModel = AppLockViewModel(
            authenticationService:
                MockDeviceAuthenticationService(
                    authenticationResult: false
                ),
            userDefaults: testDefaults
        )

        failedLockViewModel.setEnabled(true)

        #expect(failedLockViewModel.isUnlocked == false)

        await failedLockViewModel.unlock()

        #expect(failedLockViewModel.isUnlocked == false)

        let successfulLockViewModel = AppLockViewModel(
            authenticationService:
                MockDeviceAuthenticationService(
                    authenticationResult: true
                ),
            userDefaults: testDefaults
        )

        await successfulLockViewModel.unlock()

        #expect(successfulLockViewModel.isUnlocked == true)
    }
    
    @Test
    @MainActor
    func enabledLockPersistsAndStartsLockedAfterRelaunch() {
        let suiteName = "DailyCheckIn.AppLockPersistenceTests"

        let testDefaults = UserDefaults(suiteName: suiteName)!

        testDefaults.removePersistentDomain(forName: suiteName)

        defer {
            testDefaults.removePersistentDomain(forName: suiteName)
        }

        let firstLaunchViewModel = AppLockViewModel(
            authenticationService: MockDeviceAuthenticationService(
                authenticationResult: true
            ),
            userDefaults: testDefaults
        )

        #expect(firstLaunchViewModel.isEnabled == false)
        #expect(firstLaunchViewModel.isUnlocked == true)

        firstLaunchViewModel.setEnabled(true)

        #expect(firstLaunchViewModel.isEnabled == true)
        #expect(firstLaunchViewModel.isUnlocked == false)

        let relaunchedViewModel = AppLockViewModel(
            authenticationService: MockDeviceAuthenticationService(
                authenticationResult: true
            ),
            userDefaults: testDefaults
        )

        #expect(relaunchedViewModel.isEnabled == true)
        #expect(relaunchedViewModel.isUnlocked == false)
    }
    
    @Test
    func exportingTwiceCreatesTwoDifferentBackupFiles() throws {
        let exportService = CheckInExportService()

        let backup = DailyCheckInBackup(
            checkIns: [
                CheckIn(
                    space: .personal,
                    mood: .good
                )
            ],
            activities: [],
            activityCompletions: []
        )

        let firstURL = try exportService.makeBackupFile(
            from: backup
        )

        let secondURL = try exportService.makeBackupFile(
            from: backup
        )

        defer {
            try? FileManager.default.removeItem(at: firstURL)
            try? FileManager.default.removeItem(at: secondURL)
        }

        #expect(firstURL != secondURL)

        #expect(
            FileManager.default.fileExists(
                atPath: firstURL.path
            )
        )

        #expect(
            FileManager.default.fileExists(
                atPath: secondURL.path
            )
        )
    }
    
    @Test
    func importServiceRejectsUnsupportedBackupVersion() throws {
        let unsupportedBackup = DailyCheckInBackup(
            version: DailyCheckInBackup.currentVersion + 1,
            checkIns: [],
            activities: [],
            activityCompletions: []
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(unsupportedBackup)

        let importService = BackupImportService()

        #expect(
            throws: BackupImportError.self
        ) {
            try importService.decodeBackup(from: data)
        }
    }
    
    @Test
    func deletingAllActivityDataClearsAndPersistsEmptyData() {
        let storageService = InMemoryActivityStorageService()

        let viewModel = ActivityViewModel(
            storageService: storageService
        )

        let activity = Activity(
            title: "Evening walk"
        )

        let completion = ActivityCompletion(
            activityID: activity.id
        )

        viewModel.replaceStoredData(
            activities: [activity],
            completions: [completion]
        )

        viewModel.deleteAllStoredData()

        #expect(viewModel.activities.isEmpty)
        #expect(viewModel.completions.isEmpty)

        let reloadedViewModel = ActivityViewModel(
            storageService: storageService
        )

        #expect(reloadedViewModel.activities.isEmpty)
        #expect(reloadedViewModel.completions.isEmpty)
    }
    
    @Test
    func activityMoodComparisonShowsMoodDifference() throws {
        let homeStorage = InMemoryCheckInStorageService()
        let activityStorage = InMemoryActivityStorageService()

        let homeViewModel = HomeViewModel(
            storageService: homeStorage
        )

        let activityViewModel = ActivityViewModel(
            storageService: activityStorage
        )

        let activity = Activity(
            title: "Evening Walk"
        )

        let calendar = Calendar.current
        let today = Date()

        let completedDayOne = calendar.date(
            byAdding: .day,
            value: -4,
            to: today
        )!

        let completedDayTwo = calendar.date(
            byAdding: .day,
            value: -3,
            to: today
        )!

        let otherDayOne = calendar.date(
            byAdding: .day,
            value: -2,
            to: today
        )!

        let otherDayTwo = calendar.date(
            byAdding: .day,
            value: -1,
            to: today
        )!

        homeViewModel.addCheckIn(
            CheckIn(
                date: completedDayOne,
                space: .personal,
                mood: .happy
            )
        )

        homeViewModel.addCheckIn(
            CheckIn(
                date: completedDayTwo,
                space: .personal,
                mood: .happy
            )
        )

        homeViewModel.addCheckIn(
            CheckIn(
                date: otherDayOne,
                space: .personal,
                mood: .sad
            )
        )

        homeViewModel.addCheckIn(
            CheckIn(
                date: otherDayTwo,
                space: .personal,
                mood: .sad
            )
        )

        activityViewModel.replaceStoredData(
            activities: [activity],
            completions: [
                ActivityCompletion(
                    activityID: activity.id,
                    date: completedDayOne
                ),
                ActivityCompletion(
                    activityID: activity.id,
                    date: completedDayTwo
                )
            ]
        )

        let statisticsViewModel = StatisticsViewModel(
            homeViewModel: homeViewModel,
            activityViewModel: activityViewModel
        )

        statisticsViewModel.selectedSpace = .personal
        statisticsViewModel.selectedPeriod = .allTime

        let comparison = try #require(
            statisticsViewModel.activityMoodComparisons.first
        )

        #expect(comparison.title == "Evening Walk")
        #expect(comparison.completedCheckInCount == 2)
        #expect(comparison.averageMoodOnCompletedDays == 5)
        #expect(comparison.averageMoodOnOtherDays == 2)
        #expect(comparison.moodDifference == 3)
    }
    
    @Test
    func activityMoodComparisonRequiresEnoughData() {
        let homeViewModel = HomeViewModel(
            storageService: InMemoryCheckInStorageService()
        )

        let activityViewModel = ActivityViewModel(
            storageService: InMemoryActivityStorageService()
        )

        let activity = Activity(title: "Evening Walk")
        let calendar = Calendar.current
        let today = Date()

        let completedDay = calendar.date(
            byAdding: .day,
            value: -2,
            to: today
        )!

        let otherDay = calendar.date(
            byAdding: .day,
            value: -1,
            to: today
        )!

        homeViewModel.addCheckIn(
            CheckIn(
                date: completedDay,
                space: .personal,
                mood: .happy
            )
        )

        homeViewModel.addCheckIn(
            CheckIn(
                date: otherDay,
                space: .personal,
                mood: .sad
            )
        )

        activityViewModel.replaceStoredData(
            activities: [activity],
            completions: [
                ActivityCompletion(
                    activityID: activity.id,
                    date: completedDay
                )
            ]
        )

        let statisticsViewModel = StatisticsViewModel(
            homeViewModel: homeViewModel,
            activityViewModel: activityViewModel
        )

        statisticsViewModel.selectedSpace = .personal
        statisticsViewModel.selectedPeriod = .allTime

        #expect(
            statisticsViewModel.activityMoodComparisons.isEmpty
        )
    }
}

private final class InMemoryCheckInStorageService: CheckInStorageService {
    private var storedCheckIns: [CheckIn] = []

    func loadCheckIns() -> [CheckIn] {
        storedCheckIns
    }

    func saveCheckIns(_ checkIns: [CheckIn]) {
        storedCheckIns = checkIns
    }
}

private final class InMemoryActivityStorageService: ActivityStorageService {
    private var storedActivities: [Activity] = []
    private var storedCompletions: [ActivityCompletion] = []

    func loadActivities() -> [Activity] {
        storedActivities
    }

    func saveActivities(_ activities: [Activity]) {
        storedActivities = activities
    }

    func loadCompletions() -> [ActivityCompletion] {
        storedCompletions
    }

    func saveCompletions(_ completions: [ActivityCompletion]) {
        storedCompletions = completions
    }
}

private final class MockDeviceAuthenticationService:
    DeviceAuthenticating {

    let authenticationResult: Bool

    init(authenticationResult: Bool) {
        self.authenticationResult = authenticationResult
    }

    func authenticate() async -> Bool {
        authenticationResult
    }
    
    
}

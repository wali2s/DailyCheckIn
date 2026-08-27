//
//  ActivityStorageService.swift
//  DailyCheckIn
//
//  Created by Wahid on 21.08.26.
//

import Foundation

protocol ActivityStorageService {
    func loadActivities() -> [Activity]
    func saveActivities(_ activity: [Activity])
    
    func loadCompletions() -> [ActivityCompletion]
    func saveCompletions(_ completions: [ActivityCompletion])
}

final class UserDefaultsActivityStorageService: ActivityStorageService {
    
    private let userDefaults: UserDefaults
    
    private let ActivitysStorageKey = "saved_activity"
    private let completionsStorageKey = "saved_activity_completions"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - Activity
    
    func loadActivities() -> [Activity] {
        guard let data = userDefaults.data(
            forKey: ActivitysStorageKey
        ) else {
            return [
                Activity(
                    title: "20 min Guitar",
                    subtitle: "Take some time for yourself.",
                    iconName: "guitars.fill",
                    period: .morning
                )
            ]
        }
        
        do {
            return try decoder.decode(
                [Activity].self,
                from: data
            )
        } catch {
            print(
                "Failed to load Activitys: \(error)"
            )
            return []
        }
    }
    
    func saveActivities(
        _ activitys: [Activity]
    ) {
        do {
            let data = try encoder.encode(
                activitys
            )
            
            userDefaults.set(
                data,
                forKey: ActivitysStorageKey
            )
        } catch {
            print(
                "Failed to save activitys: \(error)"
            )
        }
    }
    
    // MARK: - Completions
    
    func loadCompletions() -> [ActivityCompletion] {
        guard let data = userDefaults.data(
            forKey: completionsStorageKey
        ) else {
            return []
        }
        
        do {
            return try decoder.decode(
                [ActivityCompletion].self,
                from: data
            )
        } catch {
            print(
                "Failed to load Activity completions: \(error)"
            )
            return []
        }
    }
    
    func saveCompletions(
        _ completions: [ActivityCompletion]
    ) {
        do {
            let data = try encoder.encode(
                completions
            )
            
            userDefaults.set(
                data,
                forKey: completionsStorageKey
            )
        } catch {
            print(
                "Failed to save Activity completions: \(error)"
            )
        }
    }
}

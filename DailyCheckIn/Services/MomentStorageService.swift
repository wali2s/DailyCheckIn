//
//  MomentStorageService.swift
//  DailyCheckIn
//
//  Created by Wahid on 21.08.26.
//

import Foundation

protocol MomentStorageService {
    func loadMoments() -> [Moment]
    func saveMoments(_ moments: [Moment])
}

final class UserDefaultsMomentStorageService: MomentStorageService {
    
    private let userDefaults: UserDefaults
    private let storageKey = "saved_moments"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func loadMoments() -> [Moment] {
        guard let data = userDefaults.data(forKey: storageKey) else {
            // Default setup for the very first launch
            return [
                Moment(
                    title: "20 min Guitar",
                    subtitle: "Take some time for yourself.",
                    period: .today,
                    iconName: "guitars.fill"
                )
            ]
        }
        
        do {
            return try decoder.decode([Moment].self, from: data)
        } catch {
            print("Failed to load moments: \(error)")
            return []
        }
    }
    
    func saveMoments(_ moments: [Moment]) {
        do {
            let data = try encoder.encode(moments)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            print("Failed to save moments: \(error)")
        }
    }
}

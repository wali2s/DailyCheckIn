//
//  CheckInStorageService.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import Foundation

protocol CheckInStorageService {
    func loadCheckIns() -> [CheckIn]
    func saveCheckIns(_ checkIns: [CheckIn])
}

final class UserDefaultsCheckInStorageService: CheckInStorageService {
    
    private let userDeafauls: UserDefaults
    private let storageKey = "saved_check-ins"
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDeafauls = userDefaults
    }
    
    func loadCheckIns() -> [CheckIn] {
        guard let data = userDeafauls.data(forKey: storageKey) else {
            return []
        }
        
        do {
            return try decoder.decode([CheckIn].self, from: data)
        } catch {
            print("Failed to load check-ins: \(error)")
            return []
        }
    }
    
    func saveCheckIns(_ checkIns: [CheckIn]) {
        do {
            let data = try encoder.encode(checkIns)
            userDeafauls.set(data, forKey: storageKey)
        } catch {
            print("Failed to save check-ins: \(error)")
        }
    }
}

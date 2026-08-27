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
    
    private let userDefaults: UserDefaults
    private let storageKey = "saved_check-ins"
    
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func loadCheckIns() -> [CheckIn] {
        guard let data = userDefaults.data(forKey: storageKey) else {
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
            userDefaults.set(data, forKey: storageKey)
        } catch {
            print("Failed to save check-ins: \(error)")
        }
    }
}


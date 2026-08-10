//
//  Mood.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import Foundation

enum Mood: Int, CaseIterable, Codable, Identifiable, Hashable {
    case veryLow = 1
    case low = 2
    case neutral = 3
    case good = 4
    case veryGood = 5
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .veryLow: return "Very Low"
        case .low: return "Low"
        case .neutral: return "Neutral"
        case .good: return "Good"
        case .veryGood: return "Very Good"
        }
    }
    
    var emoji: String {
        switch self {
        case .veryLow:
            return "😞"
        case .low:
            return "🙁"
        case .neutral:
            return "😐"
        case .good:
            return "🙂"
        case .veryGood:
            return "😄"
        }
    }
}

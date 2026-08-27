//
//  ActivityPeriod.swift
//  DailyCheckIn
//
//  Created by Wahid on 24.08.26.
//

import SwiftUI

enum ActivityPeriod: String, Codable, CaseIterable, Identifiable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
    case anytime = "Anytime"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .morning:
            return "sun.max.fill"
        case .afternoon:
            return "sun.horizon.fill"
        case .evening:
            return "moon.stars.fill"
        case .anytime:
            return "clock.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .morning:
            return .orange
        case .afternoon:
            return .yellow
        case .evening:
            return .indigo
        case .anytime:
            return .teal
        }
    }
}

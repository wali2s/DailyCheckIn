//
//  JournalSpace.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import Foundation

enum JournalSpace: String, CaseIterable, Codable, Identifiable, Hashable {
    case personal
    case professional
    
    var id: String { rawValue }
    var title: String {
        switch self {
        case .personal: return "Private"
        case .professional: return "Work"
        }
    }
    
    var subtitle : String {
        switch self {
        case .personal : return "Your personal daily life"
        case .professional: return "Your professional life"
        }
    }
    
    var iconName: String {
        switch self {
        case .personal: return "house.fill"
        case .professional: return "briefcase.fill"
        }
    }
}

//
//  Mood.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import SwiftUI

enum Mood: String, CaseIterable, Codable, Hashable, Identifiable {
    
    case calm
    case good
    case happy
    case neutral
    case sad
    case angry
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .calm:
            return "Calm"
        case .good:
            return "Good"
        case .happy:
            return "Happy"
        case .neutral:
            return "Neutral"
        case .sad:
            return "Sad"
        case .angry:
            return "Angry"
        }
    }
    
    var iconName: String {
        switch self {
        case .calm:
            return "leaf.fill"
        case .good:
            return "sun.max.fill"
        case .happy:
            return "face.smiling.fill"
        case .neutral:
            return "circle.dotted"
        case .sad:
            return "cloud.rain.fill"
        case .angry:
            return "flame.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .calm:
            return AppColors.accentMint
        case .good:
            return AppColors.accentYellow
        case .happy:
            return AppColors.accentPink
        case .neutral:
            return AppColors.textSecondary
        case .sad:
            return AppColors.accentBlue
        case .angry:
            return .red.opacity(0.75)
        }
    }
    
    var score: Double {
        switch self {
        case .happy:
            return 5.0
        case .good:
            return 4.0
        case .calm:
            return 4.0
        case .neutral:
            return 3.0
        case .sad:
            return 2.0
        case .angry:
            return 1.0
        }
    }
}

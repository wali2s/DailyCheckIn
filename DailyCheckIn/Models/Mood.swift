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
            return "Low"
        case .angry:
            return "Tense"
        }
    }
    
    var imageName: String {
        switch self {
        case .calm:
            return "mood-calm"
        case .good:
            return "mood-good"
        case .happy:
            return "mood-happy"
        case .neutral:
            return "mood-neutral"
        case .sad:
            return "mood-sad"
        case .angry:
            return "mood-angry"
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
    
    var backgroundColor: Color {
        switch self {
        case .calm:
            return Color(
                red: 0.91,
                green: 0.94,
                blue: 0.88
            )
            
        case .good:
            return Color(
                red: 0.99,
                green: 0.95,
                blue: 0.86
            )
            
        case .happy:
            return Color(
                red: 0.99,
                green: 0.91,
                blue: 0.87
            )
            
        case .neutral:
            return Color(
                red: 0.90,
                green: 0.91,
                blue: 0.94
            )
            
        case .sad:
            return Color(
                red: 0.89,
                green: 0.90,
                blue: 0.97
            )
            
        case .angry:
            return Color(
                red: 0.99,
                green: 0.90,
                blue: 0.87
            )
        }
    }
    
    var titleColor: Color {
        switch self {
        case .calm:
            return Color(
                red: 0.30,
                green: 0.40,
                blue: 0.27
            )
            
        case .good:
            return Color(
                red: 0.55,
                green: 0.38,
                blue: 0.10
            )
            
        case .happy:
            return Color(
                red: 0.66,
                green: 0.34,
                blue: 0.25
            )
            
        case .neutral:
            return Color(
                red: 0.34,
                green: 0.40,
                blue: 0.50
            )
            
        case .sad:
            return Color(
                red: 0.34,
                green: 0.39,
                blue: 0.61
            )
            
        case .angry:
            return Color(
                red: 0.63,
                green: 0.25,
                blue: 0.19
            )
        }
    }
    
    var factorSelectedColor: Color {
        switch self {
        case .calm:
            return Color(
                red: 0.74,
                green: 0.82,
                blue: 0.69
            )
            
        case .good:
            return Color(
                red: 0.96,
                green: 0.79,
                blue: 0.43
            )
            
        case .happy:
            return Color(
                red: 0.95,
                green: 0.63,
                blue: 0.52
            )
            
        case .neutral:
            return Color(
                red: 0.63,
                green: 0.68,
                blue: 0.78
            )
            
        case .sad:
            return Color(
                red: 0.62,
                green: 0.67,
                blue: 0.86
            )
            
        case .angry:
            return Color(
                red: 0.90,
                green: 0.48,
                blue: 0.39
            )
        }
    }
    
    var chartColor: Color {
        switch self {
        case .calm:
            return Color(
                red: 0.72,
                green: 0.77,
                blue: 0.65
            )
            
        case .good:
            return Color(
                red: 0.95,
                green: 0.70,
                blue: 0.31
            )
            
        case .happy:
            return Color(
                red: 0.94,
                green: 0.57,
                blue: 0.46
            )
            
        case .neutral:
            return Color(
                red: 0.58,
                green: 0.63,
                blue: 0.72
            )
            
        case .sad:
            return Color(
                red: 0.56,
                green: 0.61,
                blue: 0.79
            )
            
        case .angry:
            return Color(
                red: 0.86,
                green: 0.38,
                blue: 0.31
            )
        }
    }
    
    var chartImageName: String {
            switch self {
            case .calm:
                return "mood-calm-chart"
            case .good:
                return "mood-good-chart"
            case .happy:
                return "mood-happy-chart"
            case .neutral:
                return "mood-neutral-chart"
            case .sad:
                return "mood-sad-chart"
            case .angry:
                return "mood-angry-chart"
            }
        }
    
    
    var sfSymbolName: String {
        switch self {
        case .calm:
            return "face.smiling"
        case .good:
            return "face.smiling.badge.plus"
        case .happy:
            return "face.starstruck"
        case .neutral:
            return "face.dashed"
        case .sad:
            return "face.smiling"
        case .angry:
            return "face.smiling.inverse"
        }
    }
    
}

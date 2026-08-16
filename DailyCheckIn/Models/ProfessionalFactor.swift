//
//  ProfessionalFactor.swift
//  DailyCheckIn
//
//  Created by Wahid on 15.08.26.
//

import Foundation

enum ProfessionalFactor: String, Codable, CaseIterable, Identifiable {
    case workload
    case focus
    case motivation
    case productivity
    case workSatisfaction
    case timePressure
    case workLifeBalance
    case collaboration
    case progress
    case confidence

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .workload:
            return "Workload"
        case .focus:
            return "Focus"
        case .motivation:
            return "Motivation"
        case .productivity:
            return "Productivity"
        case .workSatisfaction:
            return "Work Satisfaction"
        case .timePressure:
            return "Time Pressure"
        case .workLifeBalance:
            return "Work-Life Balance"
        case .collaboration:
            return "Collaboration"
        case .progress:
            return "Progress"
        case .confidence:
            return "Confidence"
        }
    }

    var systemImage: String {
        switch self {
        case .workload:
            return "briefcase.fill"
        case .focus:
            return "scope"
        case .motivation:
            return "flag.fill"
        case .productivity:
            return "checkmark.circle.fill"
        case .workSatisfaction:
            return "hand.thumbsup.fill"
        case .timePressure:
            return "clock.fill"
        case .workLifeBalance:
            return "scale.3d"
        case .collaboration:
            return "person.2.fill"
        case .progress:
            return "chart.line.uptrend.xyaxis"
        case .confidence:
            return "shield.fill"
        }
    }
}

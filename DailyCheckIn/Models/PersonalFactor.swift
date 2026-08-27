//
//  PersonelFactor.swift
//  DailyCheckIn
//
//  Created by Wahid on 15.08.26.
//

import Foundation

enum PersonalFactor: String, Codable, CaseIterable, Identifiable {
    case rested
    case connected
    case grateful
    case energized
    case accomplished
    case relaxed
    case loved
    case hopeful
    case inspired
    case supported
    case sleepiness
    case sadness
    case anxiety
    case stress
    case loneliness
    case insomnia
    case anger
    case apathy
    case envy
    case other

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .rested:
            return "Rested"
        case .connected:
            return "Connected"
        case .grateful:
            return "Grateful"
        case .energized:
            return "Energized"
        case .accomplished:
            return "Accomplished"
        case .relaxed:
            return "Relaxed"
        case .loved:
            return "Loved"
        case .hopeful:
            return "Hopeful"
        case .inspired:
            return "Inspired"
        case .supported:
            return "Supported"
        case .sleepiness:
            return "Sleepiness"
        case .sadness:
            return "Sadness"
        case .anxiety:
            return "Anxiety"
        case .stress:
            return "Stress"
        case .loneliness:
            return "Loneliness"
        case .insomnia:
            return "Insomnia"
        case .anger:
            return "Anger"
        case .apathy:
            return "Apathy"
        case .envy:
            return "Envy"
        case .other:
            return "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .rested:
            return "bed.double.fill"
        case .connected:
            return "person.2.fill"
        case .grateful:
            return "heart.fill"
        case .energized:
            return "bolt.fill"
        case .accomplished:
            return "checkmark.seal.fill"
        case .relaxed:
            return "leaf.fill"
        case .loved:
            return "heart.circle.fill"
        case .hopeful:
            return "sunrise.fill"
        case .inspired:
            return "sparkles"
        case .supported:
            return "hands.sparkles.fill"
        case .sleepiness:
            return "bed.double.fill"
        case .sadness:
            return "cloud.rain.fill"
        case .anxiety:
            return "brain.head.profile"
        case .stress:
            return "waveform.path.ecg"
        case .loneliness:
            return "person.fill.questionmark"
        case .insomnia:
            return "moon.stars.fill"
        case .anger:
            return "flame.fill"
        case .apathy:
            return "minus.circle.fill"
        case .envy:
            return "eye.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
}

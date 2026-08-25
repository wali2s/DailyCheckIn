//
//  CheckInViewModel.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import Foundation
import Combine

enum ReflectionInputType: String, CaseIterable, Identifiable {
    case sliders = "Gefühls-Check"
    case note = "Notiz"
    
    var id: String { self.rawValue }
}


final class CheckInViewModel: ObservableObject {
    
    let space: JournalSpace
    
    var availablePersonalFactors: [PersonalFactor] {
        switch mood {
        case .calm:
            return [
                .rested,
                .relaxed,
                .connected,
                .grateful,
                .supported,
                .hopeful,
                .other
            ]

        case .good:
            return [
                .accomplished,
                .energized,
                .connected,
                .grateful,
                .inspired,
                .supported,
                .relaxed,
                .other
            ]

        case .happy:
            return [
                .loved,
                .connected,
                .grateful,
                .accomplished,
                .energized,
                .inspired,
                .hopeful,
                .other
            ]

        case .neutral:
            return [
                .rested,
                .connected,
                .grateful,
                .energized,
                .relaxed,
                .sleepiness,
                .stress,
                .other
            ]

        case .sad:
            return [
                .sadness,
                .loneliness,
                .sleepiness,
                .anxiety,
                .stress,
                .insomnia,
                .apathy,
                .envy,
                .supported,
                .other
            ]

        case .angry:
            return [
                .anger,
                .stress,
                .anxiety,
                .sleepiness,
                .apathy,
                .loneliness,
                .insomnia,
                .other
            ]
        }
    }
    
    @Published var reflectionType: ReflectionInputType = .sliders
    @Published var mood: Mood
    @Published var energyLevel: Int
    @Published var stressLevel: Int
    @Published var personalFactors: Set<PersonalFactor>
    @Published var professionalFactors: Set<ProfessionalFactor>
    @Published var note: String
    
    @Published var focusLevel: Double = 3.0
    @Published var socialBattery: Double = 3.0
    @Published var physicalTension: Double = 3.0
    
    private let checkInID: UUID
    private let checkInDate: Date
    
    init(
        space: JournalSpace,
        existingCheckIn: CheckIn? = nil
    ) {
        self.space = space
        
        self.checkInID = existingCheckIn?.id ?? UUID()
        self.checkInDate = existingCheckIn?.date ?? Date()
        
        self.mood = existingCheckIn?.mood ?? .neutral
        self.energyLevel = existingCheckIn?.energyLevel ?? 3
        self.stressLevel = existingCheckIn?.stressLevel ?? 3
        self.personalFactors = Set(
            existingCheckIn?.personalFactors ?? []
        )
        self.professionalFactors = Set(
            existingCheckIn?.professionalFactors ?? []
        )
        self.note = existingCheckIn?.note ?? ""
       
    }
    
    func makeCheckIn() -> CheckIn {
        CheckIn(
            id: checkInID,
            date: checkInDate,
            space: space,
            mood: mood,
            energyLevel: energyLevel,
            stressLevel: stressLevel,
            note: note,
            personalFactors: Array(personalFactors),
            professionalFactors: Array(professionalFactors)
        )
    }
}

//
//  CheckIn.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import Foundation

struct CheckIn: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var space: JournalSpace
    var mood: Mood
    var energyLevel: Int
    var stressLevel: Int
    var note: String
    var tags: [String]
    var personalFactors: [PersonalFactor]
    var professionalFactors: [ProfessionalFactor]
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        space: JournalSpace,
        mood: Mood,
        energyLevel: Int = 3,
        stressLevel: Int = 3,
        note:String = "",
        tags: [String] = [],
        personalFactors: [PersonalFactor] = [],
        professionalFactors: [ProfessionalFactor] = []
    ) {
        self.id = id
        self.date = date
        self.space = space
        self.mood = mood
        self.energyLevel = energyLevel
        self.stressLevel = stressLevel
        self.note = note
        self.tags = tags
        self.personalFactors = personalFactors
        self.professionalFactors = professionalFactors
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case date
        case space
        case mood
        case energyLevel
        case stressLevel
        case note
        case tags
        case personalFactors
        case professionalFactors
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        space = try container.decode(JournalSpace.self, forKey: .space)
        mood = try container.decode(Mood.self, forKey: .mood)
        energyLevel = try container.decodeIfPresent(
            Int.self,
            forKey: .energyLevel
        ) ?? 3
        stressLevel = try container.decodeIfPresent(
            Int.self,
            forKey: .stressLevel
        ) ?? 3
        note = try container.decodeIfPresent(
            String.self,
            forKey: .note
        ) ?? ""
        tags = try container.decodeIfPresent(
            [String].self,
            forKey: .tags
        ) ?? []
        personalFactors = try container.decodeIfPresent(
            [PersonalFactor].self,
            forKey: .personalFactors
        ) ?? []
        professionalFactors = try container.decodeIfPresent(
            [ProfessionalFactor].self,
            forKey: .professionalFactors
        ) ?? []
    }
}

//
//  CheckInEvaluator.swift
//  DailyCheckIn
//
//  Created by Wahid on 17.08.26.
//

import Foundation

struct CheckInEvaluator {
    
    func evaluate(_ checkIn: CheckIn) -> CheckInEvaluation {
        
        let moodScore = checkIn.mood.score
        let energyScore = Double(checkIn.energyLevel)
        
        let stressScore = Double(
            6 - checkIn.stressLevel
        )
        
        let overallScore =
            (moodScore * 0.50) +
            (energyScore * 0.30) +
            (stressScore * 0.20)
        
        return CheckInEvaluation(
            overallScore: overallScore,
            moodScore: moodScore,
            energyScore: energyScore,
            stressScore: stressScore
        )
    }
}

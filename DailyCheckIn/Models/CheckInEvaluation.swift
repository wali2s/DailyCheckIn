//
//  CheckInEvaluation.swift
//  DailyCheckIn
//
//  Created by Wahid on 17.08.26.
//

import Foundation

struct CheckInEvaluation {
    
    let overallScore: Double
    let moodScore: Double
    let energyScore: Double
    let stressScore: Double
    
    var overallPercentage: Int {
        Int((overallScore * 20).rounded())
    }
}

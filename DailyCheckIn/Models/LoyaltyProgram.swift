//
//  LoyaltyProgram.swift
//  DailyCheckIn
//
//  Created by Wahid on 28.09.26.
//

import Foundation

struct LoyaltyProgram: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let rewardTitle: String
    let requiredPoints: Int

    var earnedPoints: Int
    var isActive: Bool

    var availableRewards: Int {
        guard requiredPoints > 0 else {
            return 0
        }

        return earnedPoints / requiredPoints
    }

    var pointsTowardNextReward: Int {
        guard requiredPoints > 0 else {
            return 0
        }

        return earnedPoints % requiredPoints
    }

    var progress: Double {
        guard requiredPoints > 0 else {
            return 0
        }

        return Double(pointsTowardNextReward)
            / Double(requiredPoints)
    }

    var remainingPoints: Int {
        guard requiredPoints > 0 else {
            return 0
        }

        return requiredPoints - pointsTowardNextReward
    }

    var isRewardReady: Bool {
        availableRewards > 0
    }
}

extension LoyaltyProgram {
    static let previewPrograms: [LoyaltyProgram] = [
        LoyaltyProgram(
            id: "coffee-card",
            title: "Coffee Card",
            subtitle: "Collect 7 coffees",
            iconName: "cup.and.saucer.fill",
            rewardTitle: "1 coffee on us",
            requiredPoints: 7,
            earnedPoints: 0,
            isActive: true
        ),
        LoyaltyProgram(
            id: "iced-drinks-card",
            title: "Iced Drinks Card",
            subtitle: "Collect 5 iced drinks",
            iconName: "cup.and.saucer.fill",
            rewardTitle: "1 iced drink on us",
            requiredPoints: 5,
            earnedPoints: 0,
            isActive: true
        )
    ]
}

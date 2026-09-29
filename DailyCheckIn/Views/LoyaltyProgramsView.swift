//
//  LoyaltyProgramsView.swift
//  DailyCheckIn
//
//  Created by Wahid on 28.09.26.
//

import SwiftUI

struct LoyaltyProgramsView: View {
    private let programs = LoyaltyProgram.previewPrograms

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.standard
            ) {
                rewardCodeCard
                introductionCard

                ForEach(programs) { program in
                    loyaltyProgramCard(program)
                }

                privacyNote
            }
            .padding(AppSpacing.standard)
        }
        .background(
            AppColors.warmCanvas.ignoresSafeArea()
        )
        .navigationTitle("Dein CheckIn Rewards")
        .navigationBarTitleDisplayMode(.large)
        .accessibilityIdentifier("loyaltyProgramsView")
    }
    
    private var rewardCodeCard: some View {
        VStack(
            alignment: .center,
            spacing: AppSpacing.compact
        ) {
            Text("Your reward code")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            Text("Show this at Dein CheckIn after your purchase.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.textSecondary)

            Image(systemName: "qrcode")
                .font(.system(size: 132, weight: .regular))
                .foregroundStyle(AppColors.rewardsEspresso)
                .frame(width: 190, height: 190)
                .background(AppColors.rewardsCream)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppCornerRadius.standard,
                        style: .continuous
                    )
                )
                .accessibilityIdentifier("loyaltyRewardQRCode")

            Text("Pilot preview — scanning will be added later.")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .appCardStyle(
            backgroundColor: AppColors.surfaceWarm
        )
    }

    private var introductionCard: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.small
        ) {
            Label(
                "A little thank you",
                systemImage: "heart.fill"
            )
            .font(.headline)
            .foregroundStyle(AppColors.textPrimary)

            Text(
                "Collect points when you visit Dein CheckIn "
                + "and enjoy a drink on us."
            )
            .font(.subheadline)
            .foregroundStyle(AppColors.textSecondary)
        }
        .appCardStyle(
            backgroundColor: AppColors.surfaceWarm
        )
    }

    private func loyaltyProgramCard(
        _ program: LoyaltyProgram
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.compact
        ) {
            HStack(
                alignment: .top,
                spacing: AppSpacing.compact
            ) {
                ZStack {
                    Circle()
                        .fill(
                            AppColors.rewardsCaramel.opacity(0.18)
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: program.iconName)
                        .font(.title3)
                        .foregroundStyle(AppColors.primaryAction)
                }

                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.extraSmall
                ) {
                    Text(program.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(program.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()
            }

            ProgressView(value: program.progress)
                .tint(AppColors.accentMint)

            VStack(
                alignment: .leading,
                spacing: AppSpacing.small
            ) {
                if program.isRewardReady {
                    Label(
                        rewardReadyText(for: program),
                        systemImage: "gift.fill"
                    )
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.rewardsEspresso)
                    .padding(.horizontal, AppSpacing.compact)
                    .padding(.vertical, AppSpacing.small)
                    .background(
                        AppColors.rewardsCaramel.opacity(0.22)
                    )
                    .clipShape(
                        Capsule()
                    )
                }

                HStack {
                    Text(
                        "\(program.pointsTowardNextReward) / "
                        + "\(program.requiredPoints) points"
                    )
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary)

                    Spacer()

                    Text(
                        program.isRewardReady
                        ? "For your next drink"
                        : "\(program.remainingPoints) to go"
                    )
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textSecondary)
                }
            }

            Divider()

            Label(
                program.rewardTitle,
                systemImage: "gift.fill"
            )
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(AppColors.primaryAction)
        }
        .appCardStyle(
            backgroundColor: AppColors.surface
        )
        .accessibilityIdentifier(
            "loyaltyProgramCard.\(program.id)"
        )
    }
    
    private func rewardReadyText(
        for program: LoyaltyProgram
    ) -> String {
        if program.availableRewards == 1 {
            return "1 free drink ready"
        }

        return "\(program.availableRewards) free drinks ready"
    }

    private var privacyNote: some View {
        HStack(
            alignment: .top,
            spacing: AppSpacing.small
        ) {
            Image(systemName: "lock.fill")
                .foregroundStyle(AppColors.textSecondary)

            Text(
                "Rewards are separate from your personal "
                + "check-ins, moods and notes."
            )
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.compact)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surfaceSecondary.opacity(0.55))
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.standard,
                style: .continuous
            )
        )
    }
    

}

#Preview {
    NavigationStack {
        LoyaltyProgramsView()
    }
}

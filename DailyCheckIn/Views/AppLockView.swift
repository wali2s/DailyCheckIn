//
//  AppLockView.swift
//  DailyCheckIn
//
//  Created by Wahid on 04.09.26.
//

import SwiftUI

struct AppLockView: View {
    let unlock: () -> Void

    var body: some View {
        ZStack {
            AppColors.warmCanvas
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            AppColors.accentMint.opacity(0.16)
                        )
                        .frame(width: 82, height: 82)

                    Image(systemName: "lock.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(AppColors.accentMint)
                }

                VStack(spacing: 8) {
                    Text("DailyCheckIn is locked")
                        .font(.system(
                            size: 26,
                            weight: .bold,
                            design: .rounded
                        ))
                        .foregroundStyle(AppColors.textPrimary)

                    Text(
                        "Unlock to view your private check-ins."
                    )
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppColors.textSecondary)
                }

                Button(action: unlock) {
                    HStack(spacing: 8) {
                        Image(systemName: "faceid")
                        Text("Unlock App")
                    }
                }
                .buttonStyle(
                    PrimaryButtonStyle(
                        backgroundColor: AppColors.primaryAction
                    )
                )
                .accessibilityIdentifier("unlockAppButton")
            }
            .padding(24)
        }
    }
}

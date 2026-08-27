//
//  ActivityCardView.swift
//  DailyCheckIn
//
//  Created by Wahid on 20.08.26.
//

import SwiftUI

struct ActivityCardView: View {
    let activity: Activity

    var body: some View {
        HStack(spacing: AppSpacing.standard) {
            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(activity.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                if !activity.subtitle.isEmpty {
                    Text(activity.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Text(activity.period.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, AppSpacing.small)
                .padding(.vertical, AppSpacing.extraSmall)
                .background(Color.secondary.opacity(0.12))
                .cornerRadius(AppCornerRadius.small)
        }
        .padding(AppSpacing.cardPadding)
        .modifier(AppCardModifier())
    }
}

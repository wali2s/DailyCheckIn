//
//  MomentCardView.swift
//  DailyCheckIn
//
//  Created by Wahid on 20.08.26.
//

import SwiftUI

struct MomentCardView: View {
    let moment: Moment

    var body: some View {
        HStack(spacing: AppSpacing.standard) {
            Image(systemName: moment.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(moment.isCompleted ? .accentColor : .gray)

            VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                Text(moment.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                if !moment.subtitle.isEmpty {
                    Text(moment.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            Text(moment.period.rawValue.capitalized)
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

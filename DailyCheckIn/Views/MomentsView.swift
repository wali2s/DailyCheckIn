//
//  MomentsView.swift
//  DailyCheckIn
//
//  Created by Wahid on 20.08.26.
//

import SwiftUI
import SwiftUI

struct MomentsView: View {
    
    @State private var moments: [Moment] = [
        Moment(
            title: "20 min Guitar",
            subtitle: "A little time for yourself.",
            period: .today
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.section
            ) {
                
                // MARK: - Header
                
                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.small
                ) {
                    Text("Moments")
                        .font(
                            .system(
                                size: 34,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                    
                    Text(
                        "What would you like to make time for?"
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        AppColors.textSecondary
                    )
                }
                
                // MARK: - Today
                
                if let todayMoment = moments.first(
                    where: { $0.period == .today }
                ) {
                    momentCard(
                        moment: todayMoment
                    )
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.standard)
        }
        .background(
            AppColors.warmCanvas
        )
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Moment Card
    
    private func momentCard(
        moment: Moment
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            
            HStack {
                Image(systemName: "guitars.fill")
                    .font(.title2)
                    .foregroundStyle(
                        AppColors.accentMint
                    )
                
                Spacer()
                
                Text("Today")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        AppColors.textSecondary
                    )
            }
            
            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                Text(moment.title)
                    .font(
                        .system(
                            size: 22,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        AppColors.textPrimary
                    )
                
                Text(moment.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(
                        AppColors.textSecondary
                    )
            }
            
            Button {
                completeMoment(moment)
            } label: {
                Text(
                    moment.isCompleted
                    ? "Completed"
                    : "Done"
                )
                .frame(
                    maxWidth: .infinity
                )
            }
            .buttonStyle(
                PrimaryButtonStyle(
                    backgroundColor: AppColors.primaryAction
                )
            )
        }
        .padding(AppSpacing.cardPadding)
        .background(
            AppColors.warmSurface
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.large,
                style: .continuous
            )
        )
        .shadow(
            color: Color.black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 4
        )
    }
    
    // MARK: - Actions
    
    private func completeMoment(
        _ moment: Moment
    ) {
        guard let index = moments.firstIndex(
            where: { $0.id == moment.id }
        ) else {
            return
        }
        
        moments[index].isCompleted.toggle()
    }
}

#Preview {
    MomentsView( )
}

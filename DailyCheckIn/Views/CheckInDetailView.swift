//
//  CheckInDetailView.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import SwiftUI

struct CheckInDetailView: View {
    
    let checkIn: CheckIn
    let onEdit: () -> Void
    
    init(
        checkIn: CheckIn,
        onEdit: @escaping () -> Void = {}
    ) {
        self.checkIn = checkIn
        self.onEdit = onEdit
    }
    
    private var accentColor: Color {
        switch checkIn.space {
        case .personal:
            return AppColors.accentMint
        case .professional:
            return AppColors.accentBlue
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.section
            ) {
                moodHeader
                
                overviewCard
                
                metricsCard
                
                noteCard
                
                if !checkIn.tags.isEmpty {
                    tagsCard
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.standard)
        }
        .scrollIndicators(.hidden)
        .background(AppColors.warmCanvas)
        .navigationTitle("Check-In Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
    
            ToolbarItem(
                placement: .navigationBarTrailing
            ) {
                Button("Edit") {
                    onEdit()
                }
                .fontWeight(.semibold)
                .tint(AppColors.textPrimary)
            }
        }
    }
    
    private var moodHeader: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            HStack(
                spacing: AppSpacing.standard
            ) {
                ZStack {
                    Circle()
                        .fill(
                            accentColor.opacity(0.25)
                        )
                        .frame(
                            width: 76,
                            height: 76
                        )
                    
                    Image(systemName: checkIn.mood.imageName)
                            .foregroundStyle(checkIn.mood.iconColor)
                }
                
                VStack(
                    alignment: .leading,
                    spacing: 5
                ) {
                    Text(checkIn.mood.title)
                        .font(.system(
                            size: 28,
                            weight: .bold,
                            design: .rounded
                        ))
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                    
                    Label(
                        checkIn.space.title,
                        systemImage: checkIn.space.iconName
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        AppColors.textSecondary
                    )
                }
                
                Spacer()
            }
            
            Text(
                checkIn.date.formatted(
                    date: .long,
                    time: .shortened
                )
            )
            .font(.subheadline)
            .foregroundStyle(
                AppColors.textSecondary
            )
        }
        .appCardStyle(
            backgroundColor: AppColors.warmSurface,
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
    }
    
    private var overviewCard: some View {
        detailCard(
            title: "Overview",
            systemImage: "circle.grid.2x2.fill"
        ) {
            VStack(
                spacing: AppSpacing.standard
            ) {
                DetailRow(
                    title: "Space",
                    value: checkIn.space.title,
                    systemImage: checkIn.space.iconName,
                    tint: accentColor
                )
                
                Divider()
                    .opacity(0.5)
                
                DetailRow(
                    title: "Mood",
                    value: checkIn.mood.title,
                    systemImage: "face.smiling",
                    tint: accentColor
                )
            }
        }
    }
    
    private var metricsCard: some View {
        detailCard(
            title: "Daily Metrics",
            systemImage: "chart.bar.fill"
        ) {
            VStack(
                spacing: AppSpacing.standard
            ) {
                MetricRow(
                    title: "Energy",
                    value: checkIn.energyLevel,
                    systemImage: "bolt.fill",
                    tint: AppColors.accentYellow
                )
                
                MetricRow(
                    title: "Stress",
                    value: checkIn.stressLevel,
                    systemImage: "waveform.path.ecg",
                    tint: AppColors.accentPink
                )
            }
        }
    }
    
    private var noteCard: some View {
        detailCard(
            title: "Note",
            systemImage: "note.text"
        ) {
            if checkIn.note.isEmpty {
                Text("No note added.")
                    .font(.subheadline)
                    .foregroundStyle(
                        AppColors.textSecondary
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            } else {
                Text(checkIn.note)
                    .font(.body)
                    .foregroundStyle(
                        AppColors.textPrimary
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
        }
    }
    
    private var tagsCard: some View {
        detailCard(
            title: "Tags",
            systemImage: "tag.fill"
        ) {
            LazyVGrid(
                columns: [
                    GridItem(
                        .adaptive(minimum: 100),
                        spacing: AppSpacing.small
                    )
                ],
                alignment: .leading,
                spacing: AppSpacing.small
            ) {
                ForEach(
                    checkIn.tags,
                    id: \.self
                ) { tag in
                    Text(tag)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            accentColor.opacity(0.22)
                        )
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private func detailCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            Label(
                title,
                systemImage: systemImage
            )
            .font(.headline)
            .foregroundStyle(
                AppColors.textPrimary
            )
            
            content()
        }
        .appCardStyle(
            backgroundColor: AppColors.warmSurface,
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
    }
}

private struct DetailRow: View {
    
    let title: String
    let value: String
    let systemImage: String
    let tint: Color
    
    var body: some View {
        HStack(
            spacing: AppSpacing.small
        ) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .frame(
                    width: 24
                )
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(
                    AppColors.textSecondary
                )
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(
                    AppColors.textPrimary
                )
                .multilineTextAlignment(.trailing)
        }
    }
}

private struct MetricRow: View {
    
    let title: String
    let value: Int
    let systemImage: String
    let tint: Color
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 8
        ) {
            HStack {
                Label(
                    title,
                    systemImage: systemImage
                )
                .font(.subheadline)
                .foregroundStyle(
                    AppColors.textSecondary
                )
                
                Spacer()
                
                Text("\(value)/5")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        AppColors.textPrimary
                    )
            }
            
            ProgressView(
                value: Double(value),
                total: 5
            )
            .tint(tint)
        }
    }
}

#Preview("Check-In Details") {
    NavigationStack {
        CheckInDetailView(
            checkIn: CheckIn(
                space: .professional,
                mood: .good,
                energyLevel: 4,
                stressLevel: 2,
                note: "Worked on the Daily Check-In app.",
                tags: [
                    "Development",
                    "Focus"
                ]
            )
        )
    }
}

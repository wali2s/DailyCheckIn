//
//  HomeView.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State private var selectedSpace: JournalSpace?
    
    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: AppSpacing.section
            ) {
                headerSection
                spacesSection
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, AppSpacing.standard)
        }
        .scrollIndicators(.hidden)
        .background(AppColors.warmCanvas)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(
                placement: .navigationBarTrailing
            ) {
                Text(
                    Date.now,
                    style: .date
                )
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
            }
        }
        .sheet(item: $selectedSpace) { space in
            CheckInView(
                space: space,
                existingCheckIn: viewModel.checkIn(
                    for: space
                )
            ) { newCheckIn in
                viewModel.addCheckIn(newCheckIn)
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .checkInReminderSelected
            )
        ) { notification in
            guard let reminderType =
                notification.object as? String
            else {
                return
            }
            
            switch reminderType {
            case "personal":
                selectedSpace = .personal
                
            case "professional":
                selectedSpace = .professional
                
            default:
                break
            }
        }
    }
    
    private var headerSection: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            HStack(
                alignment: .center,
                spacing: AppSpacing.standard
            ) {
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text("Hi, \(settingsViewModel.displayName)!")
                        .font(.system(
                            size: 34,
                            weight: .bold,
                            design: .rounded
                        ))
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                    
                    Text("How are you feeling today?")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                }
                
                Spacer()
                
                profileButton
            }
            
            Text(
                "Take a moment to check in with yourself."
            )
            .font(.subheadline)
            .foregroundStyle(
                AppColors.textSecondary
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }
    
    private var profileButton: some View {
        Button {
            // Wird im nächsten Schritt mit Profile/Settings verbunden.
        } label: {
            ZStack {
                Circle()
                    .fill(
                        AppColors.accentYellow.opacity(0.35)
                    )
                    .frame(
                        width: 52,
                        height: 52
                    )
                
                Image(systemName: "person.fill")
                    .font(.title3)
                    .foregroundStyle(
                        AppColors.textPrimary
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
        .accessibilityHint(
            "Opens your profile settings."
        )
    }
    
    private var spacesSection: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            Text("Your Spaces")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.textPrimary)
            
            ForEach(JournalSpace.allCases) { space in
                SpaceCheckInCard(
                    space: space,
                    checkIn: viewModel.checkIn(
                        for: space
                    ),
                    streak: viewModel.currentStreak(
                        for: space
                    ),
                    onCheckIn: {
                        selectedSpace = space
                    }
                )
            }
        }
    }
}

private struct DailyProgressCard: View {
    
    let completedSpaces: Int
    let totalSpaces: Int
    let progress: Double
    let message: String
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            HStack {
                HStack(
                    spacing: AppSpacing.small
                ) {
                    Image(
                        systemName: "checkmark.circle.fill"
                    )
                    .font(.title3)
                    .foregroundStyle(
                        AppColors.accentBlue
                    )
                    
                    Text("Today's Progress")
                        .font(.headline)
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                }
                
                Spacer()
                
                Text(
                    "\(completedSpaces)/\(totalSpaces)"
                )
                .font(.headline)
                .foregroundStyle(
                    AppColors.textSecondary
                )
            }
            
            ProgressView(
                value: progress,
                total: 1.0
            )
            .tint(AppColors.accentBlue)
            .scaleEffect(
                x: 1,
                y: 1.5,
                anchor: .center
            )
            
            Text(message)
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
}

private struct StreakCard: View {
    
    let streak: Int
    
    var body: some View {
        HStack(
            spacing: AppSpacing.standard
        ) {
            ZStack {
                Circle()
                    .fill(
                        AppColors.accentYellow
                            .opacity(0.25)
                    )
                    .frame(
                        width: 52,
                        height: 52
                    )
                
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(
                        AppColors.accentYellow
                    )
            }
            
            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text("Current Streak")
                    .font(.headline)
                    .foregroundStyle(
                        AppColors.textPrimary
                    )
                
                if streak == 0 {
                    Text("Start your streak today")
                        .font(.subheadline)
                        .foregroundStyle(
                            AppColors.textSecondary
                        )
                } else if streak == 1 {
                    Text("1 day")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                } else {
                    Text("\(streak) days")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                }
            }
            
            Spacer()
        }
        .appCardStyle(
            backgroundColor: AppColors.warmSurface,
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
    }
}

private struct SpaceCheckInCard: View {
    
    let space: JournalSpace
    let checkIn: CheckIn?
    let streak: Int
    let onCheckIn: () -> Void
    
    private var cardBackgroundColor: Color {
        AppColors.warmSurface
    }
    
    private var iconBackgroundColor: Color {
        switch space {
        case .personal:
            return AppColors.accentMint
        case .professional:
            return AppColors.accentBlue
        }
    }
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            header
            
            if let checkIn {
                existingCheckInContent(
                    checkIn
                )
            } else {
                emptyCheckInContent
            }
        }
        .appCardStyle(
            backgroundColor: cardBackgroundColor,
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
        .contentShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.large,
                style: .continuous
            )
        )
        .onTapGesture {
            onCheckIn()
        }
    }
    
    private var header: some View {
        HStack(
            alignment: .top,
            spacing: AppSpacing.standard
        ) {
            ZStack {
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.small,
                    style: .continuous
                )
                .fill(iconBackgroundColor)
                .frame(
                    width: 48,
                    height: 48
                )
                
                Image(systemName: space.iconName)
                    .font(.title3)
                    .foregroundStyle(.black)
            }
            
            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(space.title)
                    .font(.headline)
                    .foregroundStyle(
                        AppColors.textPrimary
                    )
                
                Text(space.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(
                        AppColors.textSecondary
                    )
            }
            
            Spacer()
        }
    }
    
    private func existingCheckInContent(
        _ checkIn: CheckIn
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            HStack(
                spacing: AppSpacing.standard
            ) {
                Image(systemName: checkIn.mood.imageName)
                        .foregroundStyle(checkIn.mood.iconColor)
                    .font(.system(size: 42))
                
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(checkIn.mood.title)
                        .font(.headline)
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                    
                    if checkIn.note.isEmpty {
                        Text("No note added.")
                            .font(.subheadline)
                            .foregroundStyle(
                                AppColors.textSecondary
                            )
                    } else {
                        Text(checkIn.note)
                            .font(.subheadline)
                            .foregroundStyle(
                                AppColors.textSecondary
                            )
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            
            HStack {
                Label(
                    "Energy \(checkIn.energyLevel)/5",
                    systemImage: "bolt.fill"
                )
                
                Spacer()
                
                Label(
                    "Stress \(checkIn.stressLevel)/5",
                    systemImage: "waveform.path.ecg"
                )
            }
            .font(.caption)
            .foregroundStyle(
                AppColors.textSecondary
            )
            
            HStack {
                Label(
                    "\(streak) day streak",
                    systemImage: "flame.fill"
                )
                .font(.caption)
                .foregroundStyle(
                    AppColors.accentYellow
                )
                
                Spacer()
            }
        }
    }
    
    private var emptyCheckInContent: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            Text("No check-in yet")
                .font(.headline)
                .foregroundStyle(
                    AppColors.textPrimary
                )
            
            Text(
                "Take a moment to reflect on your day."
            )
            .font(.subheadline)
            .foregroundStyle(
                AppColors.textSecondary
            )
            
            Button("Create Check-In") {
                onCheckIn()
            }
            .buttonStyle(
                PrimaryButtonStyle(
                    backgroundColor: iconBackgroundColor
                )
            )
            .accessibilityIdentifier(
                "createCheckInButton.\(space.rawValue)"
            )
        }
    }
}

#Preview("Home - New Design") {
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(
                storageService:
                    PreviewCheckInStorageService()
            ),
            settingsViewModel: SettingsViewModel()
        )
    }
}

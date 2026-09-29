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
    
    var onProfileTap: () -> Void = {}

    @State private var activeSpace: JournalSpace = .personal
    @State private var spaceScrollPosition: JournalSpace?
    @State private var navigationSelectedSpace: JournalSpace?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                headerSection
                if viewModel.checkIns.isEmpty {
                    firstCheckInWelcomeCard
                }
                dailyStatusCard
                spaceCarouselSection
                
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(AppColors.warmCanvas.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(Date.now, style: .date)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.warmSurface)
                    .clipShape(Capsule())
            }
        }
        .navigationDestination(item: $navigationSelectedSpace) { space in
            CheckInView(
                space: space,
                existingCheckIn: viewModel.checkIn(for: space)
            ) { newCheckIn in
                viewModel.addCheckIn(newCheckIn)
                navigationSelectedSpace = nil
                focusFirstOpenSpace()
            }
        }
        .onAppear {
            focusFirstOpenSpace()
            openPendingReminderIfNeeded()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .checkInReminderSelected
            )
        ) { notification in
            guard let reminderType = notification.object as? String else {
                return
            }

            openCheckInFromReminder(
                reminderType: reminderType
            )
        }
    }


    private var headerSection: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hi, \(settingsViewModel.displayName)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("How are you feeling today?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            profileButton
        }
    }
    
    private func focusFirstOpenSpace() {
        guard let openSpace = JournalSpace.allCases.first(where: {
            viewModel.checkIn(for: $0) == nil
        }) else {
            return
        }

        withAnimation(
            .spring(response: 0.38, dampingFraction: 0.84)
        ) {
            activeSpace = openSpace
            spaceScrollPosition = openSpace
        }
    }
    
    
    private func openPendingReminderIfNeeded() {
        guard let reminderType = UserDefaults.standard.string(
            forKey: NotificationService.pendingReminderTypeKey
        ) else {
            return
        }

        openCheckInFromReminder(
            reminderType: reminderType
        )
    }

    private func openCheckInFromReminder(
        reminderType: String
    ) {
        UserDefaults.standard.removeObject(
            forKey: NotificationService.pendingReminderTypeKey
        )

        let selectedSpace: JournalSpace?

        switch reminderType {
        case "personal":
            selectedSpace = .personal

        case "professional":
            selectedSpace = .professional

        default:
            selectedSpace = nil
        }

        guard let selectedSpace else {
            return
        }

        withAnimation(
            .spring(
                response: 0.38,
                dampingFraction: 0.84
            )
        ) {
            activeSpace = selectedSpace
            spaceScrollPosition = selectedSpace
        }

        DispatchQueue.main.async {
            guard viewModel.checkIn(for: selectedSpace) == nil else {
                return
            }

            navigationSelectedSpace = selectedSpace
        }
    }

    private var profileButton: some View {
        Button {
            onProfileTap()
        } label: {
            ZStack {
                Circle()
                    .fill(
                        AppColors.accentMint.opacity(0.20)
                    )
                    .frame(width: 48, height: 48)

                if profileInitial.isEmpty {
                    Image(systemName: "person.fill")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.primaryAction)
                } else {
                    Text(profileInitial)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.primaryAction)
                }
            }
            .overlay {
                Circle()
                    .stroke(
                        AppColors.accentMint.opacity(0.45),
                        lineWidth: 1.5
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
        .accessibilityHint("Opens your profile settings.")
    }
    

    private var profileInitial: String {
        let name = settingsViewModel.displayName
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard let firstCharacter = name.first else {
            return ""
        }

        return String(firstCharacter).uppercased()
    }
    
    // MARK: - DailyStaus

    private var dailyStatusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(dailyStatusColor.opacity(0.16))
                        .frame(width: 46, height: 46)

                    Image(systemName: dailyStatusIcon)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(dailyStatusColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Today's check-ins")
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(viewModel.dailyCompletionMessage)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            HStack(spacing: 10) {
                ForEach(JournalSpace.allCases) { space in
                    let isCompleted = viewModel.checkIn(for: space) != nil

                    Label(
                        space.title,
                        systemImage: isCompleted
                        ? "checkmark.circle.fill"
                        : space.iconName
                    )
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        isCompleted
                        ? AppColors.accentMint.opacity(0.8)
                        : AppColors.textSecondary
                    )
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        isCompleted
                        ? AppColors.accentMint.opacity(0.14)
                        : AppColors.warmCanvas
                    )
                    .clipShape(Capsule())
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.warmCanvas)
                        .frame(height: 8)

                    Capsule()
                        .fill(AppColors.accentMint.opacity(0.8))
                        .frame(
                            width: geometry.size.width
                                * viewModel.dailyCompletionProgress,
                            height: 8
                        )
                }
            }
            .frame(height: 8)
        }
        .padding(18)
        .background(AppColors.warmSurface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.large,
                style: .continuous
            )
        )
        .shadow(
            color: Color.black.opacity(0.035),
            radius: 10,
            x: 0,
            y: 3
        )
        .accessibilityElement(children: .combine)
    }
    
    private var dailyStatusColor: Color {
        viewModel.completedSpacesToday == viewModel.totalSpaces
        ? AppColors.accentMint.opacity(0.8)
        : AppColors.primaryAction
    }

    private var dailyStatusIcon: String {
        switch viewModel.completedSpacesToday {
        case 0:
            return "sun.max.fill"
        case 1:
            return "arrow.right.circle.fill"
        default:
            return "checkmark.seal.fill"
        }
    }
    
    //MARK: - Welcome CheckIN Card
    
    private var firstCheckInWelcomeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(AppColors.primaryAction)

                Text("Your journal starts here")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
            }

            Text(
                "A short check-in helps you notice how your private life and workday are going."
            )
            .font(.subheadline)
            .foregroundStyle(AppColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                ForEach(JournalSpace.allCases) { space in
                    Button {
                        navigationSelectedSpace = space
                    } label: {
                        Label(
                            space.title,
                            systemImage: space.iconName
                        )
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .foregroundStyle(AppColors.primaryAction)
                        .background(
                            AppColors.primaryAction.opacity(0.10)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: AppCornerRadius.standard,
                                style: .continuous
                            )
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(
                        "firstCheckInButton.\(space.rawValue)"
                    )
                    .accessibilityLabel(
                        "Start first \(space.title) check-in"
                    )
                }
            }
        }
        .padding(18)
        .background(AppColors.warmSurface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.large,
                style: .continuous
            )
        )
    }

    // MARK: - Space Carousel Section

    private var spaceCarouselSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Choose your check-in space")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text("Swipe horizontally to switch between your personal and work check-in.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            horizontalSpaceCarousel

            spacePaginationDots

            Button {
                navigationSelectedSpace = activeSpace
            } label: {
                HStack(spacing: 8) {
                    Text(
                        viewModel.checkIn(for: activeSpace) == nil
                        ? "Check In"
                        : "Edit Check-In"
                    )

                    Image(
                        systemName: viewModel.checkIn(for: activeSpace) == nil
                        ? "arrow.right"
                        : "pencil"
                    )
                }
            }
            .buttonStyle(
                PrimaryButtonStyle(
                    backgroundColor: AppColors.primaryAction.opacity(0.9)
                )
            )
            .accessibilityIdentifier("homeCheckInButton")
            .accessibilityLabel(
                viewModel.checkIn(for: activeSpace) == nil
                ? "Start \(activeSpace.title) check-in"
                : "Edit \(activeSpace.title) check-in"
            )
        }
    }

    // MARK: - Horizontal Space Carousel

    private var horizontalSpaceCarousel: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.76
            let cardHeight: CGFloat = 315
            let cardSpacing: CGFloat = 14
            let viewportWidth = geometry.size.width

            ScrollView(.horizontal) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(JournalSpace.allCases) { space in
                        GeometryReader { cardGeometry in
                            let cardMidX = cardGeometry
                                .frame(in: .named("spaceCarousel"))
                                .midX

                            let viewportMidX = viewportWidth / 2
                            let distance = abs(cardMidX - viewportMidX)

                            let progress = min(
                                distance / (cardWidth + cardSpacing),
                                1
                            )

                            let scale = 1 - (progress * 0.16)
                            let opacity = 1 - (progress * 0.46)

                            SpaceCarouselCard(
                                space: space,
                                isCompleted: viewModel.checkIn(for: space) != nil
                            )
                            .scaleEffect(scale)
                            .opacity(opacity)
                            .animation(
                                .easeOut(duration: 0.18),
                                value: progress
                            )
                            .onTapGesture {
                                withAnimation(
                                    .spring(
                                        response: 0.35,
                                        dampingFraction: 0.82
                                    )
                                ) {
                                    activeSpace = space
                                    spaceScrollPosition = space
                                }
                            }
                        }
                        .frame(
                            width: cardWidth,
                            height: cardHeight
                        )
                        .id(space)
                    }
                }
                .scrollTargetLayout()
                .padding(
                    .horizontal,
                    (viewportWidth - cardWidth) / 2
                )
            }
            .coordinateSpace(name: "spaceCarousel")
            .scrollIndicators(.hidden)
            .accessibilityIdentifier("checkInSpaceCarousel")
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $spaceScrollPosition)
            .onChange(of: spaceScrollPosition) { _, newSpace in
                guard let newSpace else {
                    return
                }

                withAnimation(.easeInOut(duration: 0.28)) {
                    activeSpace = newSpace
                }
            }
        }
        .frame(height: 330)
    }

    // MARK: - Pagination Dots

    private var spacePaginationDots: some View {
        HStack(spacing: 6) {
            ForEach(JournalSpace.allCases) { space in
                let isSelected = space == activeSpace

                Circle()
                    .fill(
                        isSelected
                        ? AppColors.primaryAction
                        : AppColors.textSecondary.opacity(0.25)
                    )
                    .frame(
                        width: isSelected ? 8 : 6,
                        height: isSelected ? 8 : 6
                    )
                    .scaleEffect(isSelected ? 1.12 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.22),
                        value: activeSpace
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Selected check-in space")
        .accessibilityValue(activeSpace.title)
    }
}




// MARK: - Space Carousel Card

private struct SpaceCarouselCard: View {

    let space: JournalSpace
    let isCompleted: Bool

    private var accentColor: Color {
        switch space {
        case .personal:
            return AppColors.accentMint

        case .professional:
            return AppColors.accentBlue
        }
    }

    private var imageName: String {
        switch space {
        case .personal:
            return "home"

        case .professional:
            return "work"
        }
    }

    private var statusTitle: String {
        isCompleted
        ? "Completed today"
        : "Ready for your check-in"
    }

    private var statusImage: String {
        isCompleted
        ? "checkmark.circle.fill"
        : "arrow.left.and.right"
    }

    var body: some View {
        VStack(spacing: 14) {
            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.24))
                    .frame(width: 178, height: 178)
                    .blur(radius: 22)

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 235, height: 235)
                    .opacity(0.92)
            }
            .frame(width: 240, height: 205)

            VStack(spacing: 5) {
                Text(space.title)
                    .font(.system(size: 23, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)

                Text(space.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 12)

                Label(statusTitle, systemImage: statusImage)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        isCompleted
                        ? accentColor
                        : AppColors.textSecondary
                    )
                    .padding(.top, 2)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(space.title)
        .accessibilityValue(statusTitle)
        .accessibilityHint(
            "Swipe horizontally to choose another space. Tap the Check In button to continue."
        )
    }
}

// MARK: - Preview

#Preview("Home View - Space Carousel") {
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(
                storageService: PreviewCheckInStorageService()
            ),
            settingsViewModel: SettingsViewModel()
        )
    }
}
 

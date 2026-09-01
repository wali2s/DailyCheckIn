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

    @State private var activeSpace: JournalSpace = .personal
    @State private var spaceScrollPosition: JournalSpace?
    @State private var navigationSelectedSpace: JournalSpace?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                headerSection

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
            }
        }
        .onAppear {
            spaceScrollPosition = activeSpace
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .checkInReminderSelected)
        ) { notification in
            guard let reminderType = notification.object as? String else {
                return
            }

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

            withAnimation(.spring(response: 0.38, dampingFraction: 0.84)) {
                activeSpace = selectedSpace
                spaceScrollPosition = selectedSpace
            }
        }
    }

    // MARK: - Header Section

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

    private var profileButton: some View {
        Button {
            // Profile / Settings action
        } label: {
            ZStack {
                Circle()
                    .fill(AppColors.textPrimary.opacity(0.06))
                    .frame(width: 48, height: 48)

                Image(systemName: "person.fill")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.65))
                    .scaleEffect(1.35)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
        .accessibilityHint("Opens your profile settings.")
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

    // Asset-Name muss exakt dem Namen in Assets.xcassets entsprechen.
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
                // Dezentes Leuchten hinter deinem Asset-Bild
                Circle()
                    .fill(accentColor.opacity(0.24))
                    .frame(width: 178, height: 178)
                    .blur(radius: 22)

                // Dein Bild aus Assets.xcassets
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
 

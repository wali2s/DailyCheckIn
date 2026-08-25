//
//  HomeView.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import SwiftUI

// MARK: - Space Color Palette

private enum SpaceColors {
    static let personalAccent = Color(red: 0.75, green: 0.55, blue: 0.20)
    static let professionalAccent = Color(red: 0.15, green: 0.38, blue: 0.45)
}

struct HomeView: View {

    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var settingsViewModel: SettingsViewModel
    @State private var selectedSpace: JournalSpace?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                spacesSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
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
        .navigationDestination(item: $selectedSpace) { space in
            CheckInView(
                space: space,
                existingCheckIn: viewModel.checkIn(for: space)
            ) { newCheckIn in
                viewModel.addCheckIn(newCheckIn)
                selectedSpace = nil
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .checkInReminderSelected)
        ) { notification in
            guard let reminderType = notification.object as? String else { return }

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
                    .foregroundStyle(SpaceColors.personalAccent).opacity(0.6)
                    .scaleEffect(1.35)
                    
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
        .accessibilityHint("Opens your profile settings.")
    }

    // MARK: - Spaces Section

    private var spacesSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Your Spaces")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            ForEach(JournalSpace.allCases) { space in
                SpaceCheckInCard(
                    space: space,
                    checkIn: viewModel.checkIn(for: space),
                    onCheckIn: {
                        selectedSpace = space
                    }
                )
            }
        }
    }
}

// MARK: - Harmonious & Colored Space Check-In Card

private struct SpaceCheckInCard: View {

    let space: JournalSpace
    let checkIn: CheckIn?
    let onCheckIn: () -> Void

    // Zuweisung der 2 Akzentfarben je nach Space
    private var accentColor: Color {
        switch space {
        case .personal:
            return SpaceColors.personalAccent
        case .professional:
            return SpaceColors.professionalAccent
        }
    }

    var body: some View {
        Button(action: onCheckIn) {
            VStack(alignment: .leading, spacing: 20) {
                topHeader

                if let checkIn {
                    completedContent(checkIn)
                } else {
                    pendingContent
                }
            }
            .padding(20)
            .background(
                ZStack {
                    AppColors.warmSurface

                    // Dezenter Farbverlauf mit der jeweiligen Akzentfarbe
                    LinearGradient(
                        colors: [
                            accentColor.opacity(checkIn != nil ? 0.08 : 0.04),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        accentColor.opacity(checkIn != nil ? 0.3 : 0.12),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.025), radius: 12, x: 0, y: 4)
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityIdentifier("spaceCard.\(space.rawValue)")
    }

    // MARK: - Subviews

    private var topHeader: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon Badge mit Akzentfarbe
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 52, height: 52)

                Image(systemName: space.iconName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(accentColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(space.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(AppColors.textPrimary)

                Text(space.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            // Status Pill mit Akzentfarbe
            HStack(spacing: 5) {
                Image(systemName: checkIn != nil ? "checkmark" : "sparkles")
                    .font(.caption2)
                    .fontWeight(.bold)

                Text(checkIn != nil ? "Completed" : "Pending")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(checkIn != nil ? accentColor : AppColors.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(accentColor.opacity(checkIn != nil ? 0.15 : 0.06))
            )
        }
    }

    private func completedContent(_ checkIn: CheckIn) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
                .background(accentColor.opacity(0.12))

            // Mood & Note Content
            HStack(spacing: 14) {
                Image(systemName: checkIn.mood.imageName)
                    .font(.system(size: 32))
                    .foregroundStyle(checkIn.mood.iconColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text(checkIn.mood.title)
                        .font(.headline)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(checkIn.note.isEmpty ? "No note added for today." : checkIn.note)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()
            }

            // Floating Metric Badges
            HStack(spacing: 8) {
                FloatingMetricBadge(
                    icon: "bolt.fill",
                    label: "Energy",
                    value: "\(checkIn.energyLevel)/5"
                )

                FloatingMetricBadge(
                    icon: "waveform.path.ecg",
                    label: "Stress",
                    value: "\(checkIn.stressLevel)/5"
                )

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(accentColor.opacity(0.7))
            }
        }
    }

    private var pendingContent: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Ready to reflect?")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary)

                Text("Tap anywhere to start your daily check-in.")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(accentColor)
                    .frame(width: 38, height: 38)

                Image(systemName: "arrow.right")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }
        .padding(.top, 2)
    }
}

// MARK: - Floating Metric Badge

private struct FloatingMetricBadge: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)

            Text("\(label) \(value)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppColors.warmCanvas)
        .clipShape(Capsule())
    }
}

// MARK: - Custom Pressable Button Style

private struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("Home View - Two Accents") {
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(
                storageService: PreviewCheckInStorageService()
            ),
            settingsViewModel: SettingsViewModel()
        )
    }
}

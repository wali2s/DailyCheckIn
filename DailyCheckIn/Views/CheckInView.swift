//
//  CheckInView.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import SwiftUI

struct CheckInView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: CheckInViewModel
    
    let isEditing: Bool
    let onSave: (CheckIn) -> Void
    
    init(
        space: JournalSpace,
        existingCheckIn: CheckIn? = nil,
        onSave: @escaping (CheckIn) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: CheckInViewModel(
                space: space,
                existingCheckIn: existingCheckIn
            )
        )
        
        self.isEditing = existingCheckIn != nil
        self.onSave = onSave
    }
    
    private var accentColor: Color {
        switch viewModel.space {
        case .personal:
            return AppColors.accentMint
        case .professional:
            return AppColors.accentBlue
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.section
                ) {
                    spaceHeader
                    moodSection
                    energySection
                    stressSection
                    reflectionSection
                    thoughtsSection
                    tagsSection
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.standard)
            }
            .scrollIndicators(.hidden)
            .background(AppColors.canvas)
            .navigationTitle(
                isEditing
                ? "Edit Check-In"
                : "New Check-In"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Save") {
                        saveCheckIn()
                    }
                    .fontWeight(.semibold)
                    .tint(AppColors.textPrimary)
                    .accessibilityIdentifier(
                        "saveCheckInButton"
                    )
                }
            }
        }
    }
    
    private var spaceHeader: some View {
        HStack(
            spacing: AppSpacing.standard
        ) {
            ZStack {
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.small,
                    style: .continuous
                )
                .fill(
                    accentColor.opacity(0.35)
                )
                .frame(
                    width: 52,
                    height: 52
                )
                
                Image(
                    systemName: viewModel.space.iconName
                )
                .font(.title3)
                .foregroundStyle(
                    AppColors.textPrimary
                )
            }
            
            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                Text(viewModel.space.title)
                    .font(.headline)
                    .foregroundStyle(
                        AppColors.textPrimary
                    )
                
                Text(
                    isEditing
                    ? "Update your reflection"
                    : "Take a moment for yourself"
                )
                .font(.subheadline)
                .foregroundStyle(
                    AppColors.textSecondary
                )
            }
            
            Spacer()
        }
        .appCardStyle(
            backgroundColor: AppColors.surface,
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
    }
    
    private var moodSection: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            sectionTitle(
                "How are you feeling?",
                systemImage: "face.smiling"
            )
            
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: AppSpacing.small
            ) {
                ForEach(Mood.allCases) { mood in
                    moodButton(mood)
                }
            }
        }
        .appCardStyle(
            backgroundColor: AppColors.surface,
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
    }
    
    private func moodButton(
        _ mood: Mood
    ) -> some View {
        let isSelected = viewModel.mood == mood
        
        return Button {
            viewModel.mood = mood
        } label: {
            HStack(
                spacing: AppSpacing.small
            ) {
                Image(systemName: mood.iconName)
                    .font(.headline)
                    .foregroundStyle(
                        isSelected
                        ? .black
                        : mood.iconColor
                    )
                
                Text(mood.title)
                    .font(.subheadline)
                    .fontWeight(
                        isSelected
                        ? .semibold
                        : .regular
                    )
                    .foregroundStyle(
                        AppColors.textPrimary
                    )
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                isSelected
                ? accentColor.opacity(0.38)
                : AppColors.surfaceSecondary
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.small,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.small,
                    style: .continuous
                )
                .stroke(
                    isSelected
                    ? accentColor.opacity(0.8)
                    : Color.clear,
                    lineWidth: 1
                )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            "\(mood.title), mood"
        )
        .accessibilityValue(
            isSelected
            ? "Selected"
            : "Not selected"
        )
        .accessibilityHint(
            "Double tap to select this mood."
        )
    }
    
    private var energySection: some View {
        ratingCard(
            title: "How is your energy?",
            systemImage: "bolt.fill",
            value: $viewModel.energyLevel,
            tint: AppColors.accentYellow
        )
    }
    
    private var stressSection: some View {
        ratingCard(
            title: "How is your stress level?",
            systemImage: "waveform.path.ecg",
            value: $viewModel.stressLevel,
            tint: AppColors.accentPink
        )
    }
    
    private func ratingCard(
        title: String,
        systemImage: String,
        value: Binding<Int>,
        tint: Color
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            HStack {
                sectionTitle(
                    title,
                    systemImage: systemImage
                )
                
                Spacer()
                
                Text("\(value.wrappedValue)/5")
                    .font(.headline)
                    .foregroundStyle(
                        AppColors.textSecondary
                    )
            }
            
            HStack(
                spacing: AppSpacing.small
            ) {
                ForEach(1...5, id: \.self) { level in
                    Button {
                        value.wrappedValue = level
                    } label: {
                        Text("\(level)")
                            .font(.headline)
                            .foregroundStyle(
                                value.wrappedValue >= level
                                ? .black
                                : AppColors.textSecondary
                            )
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 42
                            )
                            .background(
                                value.wrappedValue >= level
                                ? tint
                                : AppColors.surfaceSecondary
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius:
                                        AppCornerRadius.small,
                                    style: .continuous
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .appCardStyle(
            backgroundColor: AppColors.surface,
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
    }
    
    private var reflectionSection: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            sectionTitle(
                "Reflection Prompt",
                systemImage: "sparkles"
            )
            
            Text(viewModel.space.reflectionPrompt)
                .font(.body)
                .foregroundStyle(
                    AppColors.textPrimary
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .appCardStyle(
            backgroundColor: accentColor.opacity(0.16),
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
    }
    
    private var thoughtsSection: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            sectionTitle(
                "Your Thoughts",
                systemImage: "note.text"
            )
            
            TextField(
                "Write a short note...",
                text: $viewModel.note,
                axis: .vertical
            )
            .font(.body)
            .textFieldStyle(.plain)
            .lineLimit(4...8)
            .padding(12)
            .background(
                AppColors.surfaceSecondary
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.small,
                    style: .continuous
                )
            )
            .accessibilityIdentifier(
                "checkInNoteTextField"
            )
        }
        .appCardStyle(
            backgroundColor: AppColors.surface,
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
    }
    
    private var tagsSection: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            sectionTitle(
                "Tags",
                systemImage: "tag.fill"
            )
            
            TextField(
                "Focus, Learning, Exercise",
                text: $viewModel.tagsText
            )
            .font(.body)
            .textFieldStyle(.plain)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .padding(12)
            .background(
                AppColors.surfaceSecondary
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.small,
                    style: .continuous
                )
            )
        }
        .appCardStyle(
            backgroundColor: AppColors.surface,
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
    }
    
    private func sectionTitle(
        _ title: String,
        systemImage: String
    ) -> some View {
        Label(
            title,
            systemImage: systemImage
        )
        .font(.headline)
        .foregroundStyle(
            AppColors.textPrimary
        )
    }
    
    private func saveCheckIn() {
        let checkIn = viewModel.makeCheckIn()
        onSave(checkIn)
        dismiss()
    }
}

#Preview("New Check-In") {
    CheckInView(
        space: .personal
    ) { checkIn in
        print(checkIn)
    }
}

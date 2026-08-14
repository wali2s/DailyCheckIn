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
    
    @State private var currentStep = 0
    
    let isEditing: Bool
    let onSave: (CheckIn) -> Void
    
    private let totalSteps = 3
    
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
    
    private var isLastStep: Bool {
        currentStep == totalSteps - 1
    }
    
    var body: some View {
        NavigationStack {
            VStack(
                spacing: 0
            ) {
                progressIndicator
                
                ScrollView {
                    stepContent
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.section)
                        .padding(.bottom, AppSpacing.standard)
                }
                .scrollIndicators(.hidden)
                
                navigationControls
            }
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
            }
        }
    }
    
    private var progressIndicator: some View {
        HStack(
            spacing: 6
        ) {
            ForEach(
                0..<totalSteps,
                id: \.self
            ) { step in
                Capsule()
                    .fill(
                        step <= currentStep
                        ? accentColor
                        : AppColors.surfaceSecondary
                    )
                    .frame(
                        height: 6
                    )
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.small)
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            "Check-In progress"
        )
        .accessibilityValue(
            "Step \(currentStep + 1) of \(totalSteps)"
        )
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            moodStep
            
        case 1:
            metricsStep
            
        case 2:
            reflectionStep
            
        default:
            EmptyView()
        }
    }
    
    private var moodStep: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.section
        ) {
            stepHeader(
                title: "How do you feel today?",
                subtitle: "Choose the mood that fits you best.",
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
    }
    
    private var metricsStep: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.section
        ) {
            stepHeader(
                title: "How are you doing?",
                subtitle: "Rate your energy and stress level.",
                systemImage: "chart.bar.fill"
            )
            
            ratingCard(
                title: "Energy",
                systemImage: "bolt.fill",
                value: $viewModel.energyLevel,
                tint: AppColors.accentYellow
            )
            
            ratingCard(
                title: "Stress",
                systemImage: "waveform.path.ecg",
                value: $viewModel.stressLevel,
                tint: AppColors.accentPink
            )
        }
    }
    
    private var reflectionStep: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.section
        ) {
            stepHeader(
                title: "Take a moment to reflect",
                subtitle: "Add a note or a few tags if you like.",
                systemImage: "text.quote"
            )
            
            reflectionPromptCard
            
            thoughtsCard
            
            tagsCard
        }
    }
    
    private var reflectionPromptCard: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            Label(
                "Reflection Prompt",
                systemImage: "sparkles"
            )
            .font(.headline)
            .foregroundStyle(
                AppColors.textPrimary
            )
            
            Text(
                viewModel.space.reflectionPrompt
            )
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
    
    private var thoughtsCard: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            Label(
                "Your Thoughts",
                systemImage: "note.text"
            )
            .font(.headline)
            .foregroundStyle(
                AppColors.textPrimary
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
    
    private var tagsCard: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            Label(
                "Tags",
                systemImage: "tag.fill"
            )
            .font(.headline)
            .foregroundStyle(
                AppColors.textPrimary
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
    
    private func stepHeader(
        title: String,
        subtitle: String,
        systemImage: String
    ) -> some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.small
        ) {
            Label(
                title,
                systemImage: systemImage
            )
            .font(.system(
                size: 28,
                weight: .bold,
                design: .rounded
            ))
            .foregroundStyle(
                AppColors.textPrimary
            )
            
            Text(subtitle)
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
            .padding(.vertical, 14)
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
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            mood.title
        )
        .accessibilityValue(
            isSelected
            ? "Selected"
            : "Not selected"
        )
        .accessibilityHint(
            "Selects this mood for your check-in."
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
                Label(
                    title,
                    systemImage: systemImage
                )
                .font(.headline)
                .foregroundStyle(
                    AppColors.textPrimary
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
                ForEach(
                    1...5,
                    id: \.self
                ) { level in
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
                                minHeight: 46
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
    
    private var navigationControls: some View {
        HStack(
            spacing: AppSpacing.standard
        ) {
            if currentStep > 0 {
                Button("Back") {
                    withAnimation(.easeInOut) {
                        currentStep -= 1
                    }
                }
                .buttonStyle(.bordered)
                .tint(AppColors.textPrimary)
            }
            
            Button {
                if isLastStep {
                    saveCheckIn()
                } else {
                    withAnimation(.easeInOut) {
                        currentStep += 1
                    }
                }
            } label: {
                Text(
                    isLastStep
                    ? "Save Check-In"
                    : "Continue"
                )
            }
            .buttonStyle(
                PrimaryButtonStyle(
                    backgroundColor: accentColor
                )
            )
            .disabled(!canContinue)
            .opacity(canContinue ? 1.0 : 0.5)
            .accessibilityIdentifier(
                isLastStep
                ? "saveCheckInButton"
                : "continueCheckInButton.step\(currentStep + 1)"
            )
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.vertical, AppSpacing.standard)
        .background(
            AppColors.canvas
                .shadow(
                    color: Color.black.opacity(0.06),
                    radius: 8,
                    x: 0,
                    y: -3
                )
        )
    }
    
    private func saveCheckIn() {
        let checkIn = viewModel.makeCheckIn()
        onSave(checkIn)
        dismiss()
    }
    
    private var canContinue: Bool {
        switch currentStep {
        case 0:
            return true
            
        case 1:
            return viewModel.energyLevel >= 1 &&
                viewModel.energyLevel <= 5 &&
                viewModel.stressLevel >= 1 &&
                viewModel.stressLevel <= 5
            
        case 2:
            return true
            
        default:
            return false
        }
    }
}

#Preview("New Check-In - Step 1") {
    CheckInView(
        space: .personal
    ) { checkIn in
        print(checkIn)
    }
}

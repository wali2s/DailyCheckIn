//
//  CreateMomentView.swift
//  DailyCheckIn
//

import SwiftUI

struct MomentPreset: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let iconName: String
}
enum CreationMode: String, CaseIterable, Identifiable {
    case presets = "Presets"
    case custom = "Custom"
    
    var id: String { rawValue }
}

enum IconCategory: String, CaseIterable, Identifiable {
    case health = "Health"
    case fitness = "Fitness"
    case leisure = "Leisure"
    case work = "Work"
    case life = "Life"
    
    var id: String { rawValue }
    
    var icons: [String] {
        switch self {
        case .health:
            return ["star.fill", "heart.fill", "flame.fill", "leaf.fill", "drop.fill", "moon.fill", "sun.max.fill", "brain.head.profile"]
        case .fitness:
            return ["figure.run", "figure.walk", "bicycle", "figure.mind.and.body", "figure.strengthtraining.functional", "figure.pool.swim"]
        case .leisure:
            return ["guitars.fill", "paintpalette.fill", "book.fill", "music.note", "camera.fill", "gamecontroller.fill", "cup.and.saucer.fill", "fork.knife"]
        case .work:
            return ["laptopcomputer", "pencil.line", "timer", "briefcase.fill", "checkmark.circle.fill", "lightbulb.fill", "calendar", "envelope.fill"]
        case .life:
            return ["house.fill", "cart.fill", "pawprint.fill", "cross.case.fill", "person.2.fill", "bubbles.and.sparkles.fill", "airplane", "gift.fill"]
        }
    }
}

struct CreateMomentView: View {
    @Environment(\.dismiss) private var dismiss

    var momentToEdit: Moment?
    var onSave: (Moment) -> Void

    // MARK: - Navigation / Step State
    @State private var currentStep: Int = 1
    
    // MARK: - Form States
    @State private var creationMode: CreationMode = .presets
    @State private var selectedRecurrenceType: RecurrenceType = .daily
    @State private var selectedPeriod: MomentPeriod = .morning
    @State private var selectedPreset: MomentPreset?
    @State private var customTitle: String = ""
    @State private var selectedIconCategory: IconCategory = .health
    @State private var selectedCustomIcon: String = "star.fill"
    
    @State private var targetMinutes: Int = 15
    @State private var selectedWeekdays: Set<Int> = [2, 4, 6]
    @State private var daysPerMonth: Int = 4
    @State private var enableNotification: Bool = false
    @State private var notificationTime: Date = Date()
    
    private let weekdays = [
        (id: 2, label: "Monday"), (id: 3, label: "Tuesday"), (id: 4, label: "Wednesday"),
        (id: 5, label: "Thursday"), (id: 6, label: "Friday"), (id: 7, label: "Saturday"), (id: 1, label: "Sunday")
    ]

    // MARK: - Presets
    private let presets: [MomentPreset] = [
        MomentPreset(title: "Meditation", iconName: "brain.head.profile"),
        MomentPreset(title: "Workout", iconName: "figure.run"),
        MomentPreset(title: "Drink Water", iconName: "drop.fill"),
        MomentPreset(title: "Reading", iconName: "book.fill"),
        MomentPreset(title: "Walk", iconName: "figure.walk"),
        MomentPreset(title: "Journaling", iconName: "pencil.line"),
        MomentPreset(title: "Focus Time", iconName: "timer"),
        MomentPreset(title: "Sleep", iconName: "bed.double.fill")
    ]

    private let presetColumns = [
        GridItem(.flexible(), spacing: AppSpacing.compact),
        GridItem(.flexible(), spacing: AppSpacing.compact)
    ]

    private let iconColumns = Array(repeating: GridItem(.flexible(), spacing: AppSpacing.compact), count: 4)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepProgressHeader
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.standard)
                    .padding(.bottom, AppSpacing.compact)

                ScrollView {
                    VStack(spacing: AppSpacing.section) {
                        switch currentStep {
                        case 1:
                            stepOneSelectActivity
                        case 2:
                            stepTwoSelectPeriod
                        case 3:
                            stepThreeReviewAndSave
                        default:
                            EmptyView()
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.vertical, AppSpacing.standard)
                }
                .scrollIndicators(.hidden)

                bottomActionBar
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.vertical, AppSpacing.standard)
                    .background(AppColors.warmSurface)
            }
            .background(AppColors.warmSurface.ignoresSafeArea())
            .navigationTitle(momentToEdit == nil ? "New Moment" : "Edit Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .onAppear {
                setupEditStateIfNeeded()
            }
        }
    }

    // MARK: - Step 1
    private var stepOneSelectActivity: some View {
        VStack(alignment: .leading, spacing: AppSpacing.standard) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Step 1: Choose Activity")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                
                Text("Select a preset or create your own custom activity.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Picker("Mode", selection: $creationMode) {
                ForEach(CreationMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if creationMode == .presets {
                presetSelectionGrid
            } else {
                customActivityForm
            }
        }
    }

    // MARK: - Step 2
    private var stepTwoSelectPeriod: some View {
        VStack(alignment: .leading, spacing: AppSpacing.standard) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Step 2: Frequency & Time")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                
                Text("Set how often and when you want to do this activity.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }

            // Day Period Selection
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text("Time of Day")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textSecondary)

                Picker("Period", selection: $selectedPeriod) {
                    ForEach(MomentPeriod.allCases) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Recurrence Selection
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text("Recurrence")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textSecondary)

                Picker("Recurrence", selection: $selectedRecurrenceType) {
                    ForEach(RecurrenceType.allCases) { recurrence in
                        Text(recurrence.rawValue).tag(recurrence)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Duration
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text("Duration per Session")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textSecondary)

                HStack {
                    Image(systemName: "timer")
                        .foregroundStyle(AppColors.primaryAction)
                    
                    Stepper("\(targetMinutes) Minutes", value: $targetMinutes, in: 5...180, step: 5)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .padding(.horizontal, AppSpacing.standard)
                .padding(.vertical, 12)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
            }

            switch selectedRecurrenceType {
            case .daily:
                Text("This activity will repeat daily.")
                    .font(.footnote)
                    .foregroundStyle(AppColors.textSecondary)

            case .weekly:
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("Select Days of the Week")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppColors.textSecondary)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: AppSpacing.compact),
                            GridItem(.flexible(), spacing: AppSpacing.compact)
                        ],
                        spacing: AppSpacing.compact
                    ) {
                        ForEach(weekdays, id: \.id) { day in
                            let isSelected = selectedWeekdays.contains(day.id)

                            Button {
                                if isSelected {
                                    selectedWeekdays.remove(day.id)
                                } else {
                                    selectedWeekdays.insert(day.id)
                                }
                            } label: {
                                HStack {
                                    Text(day.label)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(isSelected ? .white : AppColors.textPrimary)

                                    Spacer()

                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .padding(.horizontal, AppSpacing.standard)
                                .padding(.vertical, 12)
                                .background(isSelected ? AppColors.primaryAction : AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

            case .monthly:
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("Target Days per Month")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(AppColors.textSecondary)

                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(AppColors.primaryAction)
                        
                        Stepper("\(daysPerMonth) Days / Month", value: $daysPerMonth, in: 1...31)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .padding(.horizontal, AppSpacing.standard)
                    .padding(.vertical, 12)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
                }
            }

            if selectedRecurrenceType == .daily || selectedRecurrenceType == .weekly {
                notificationCard
            }
        }
    }

    @ViewBuilder
    private var notificationCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Toggle(isOn: $enableNotification) {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundStyle(AppColors.primaryAction)
                    Text("Remind Me")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .onChange(of: enableNotification) { _, newValue in
                if newValue {
                    NotificationManager.shared.requestAuthorization()
                }
            }

            if enableNotification {
                DatePicker(
                    "Notification Time",
                    selection: $notificationTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.compact)
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, AppSpacing.standard)
        .padding(.vertical, 12)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
    }

    // MARK: - Step 3
    private var stepThreeReviewAndSave: some View {
        VStack(spacing: AppSpacing.standard) {
            VStack(spacing: 4) {
                Text("Step 3: Confirm Details")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                
                Text("Review your new moment before adding it.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }

            VStack(spacing: AppSpacing.standard) {
                Image(systemName: selectedIconName)
                    .font(.system(size: 44))
                    .foregroundStyle(AppColors.accentMint)
                
                Text(selectedTitle)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                
                HStack(spacing: 8) {
                    Text(selectedPeriod.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, AppSpacing.standard)
                        .padding(.vertical, AppSpacing.extraSmall)
                        .background(AppColors.surfaceSecondary.opacity(0.5))
                        .clipShape(Capsule())

                    Text(selectedRecurrenceType.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, AppSpacing.standard)
                        .padding(.vertical, AppSpacing.extraSmall)
                        .background(AppColors.surfaceSecondary.opacity(0.5))
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.cardPadding)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large))
        }
    }

    private var stepProgressHeader: some View {
        HStack(spacing: 8) {
            ForEach(1...3, id: \.self) { step in
                HStack {
                    Circle()
                        .fill(step <= currentStep ? AppColors.primaryAction : AppColors.surfaceSecondary)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text("\(step)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(step <= currentStep ? .white : AppColors.textSecondary)
                        )
                    
                    if step < 3 {
                        Rectangle()
                            .fill(step < currentStep ? AppColors.primaryAction : AppColors.surfaceSecondary)
                            .frame(height: 2)
                    }
                }
            }
        }
    }

    private var bottomActionBar: some View {
        HStack(spacing: AppSpacing.standard) {
            if currentStep > 1 {
                Button("Back") {
                    withAnimation { currentStep -= 1 }
                }
                .frame(maxWidth: 100)
                .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.surfaceSecondary))
            }

            Button(currentStep == 3 ? (momentToEdit == nil ? "Create Moment" : "Save Changes") : "Next") {
                if currentStep < 3 {
                    withAnimation { currentStep += 1 }
                } else {
                    saveMoment()
                }
            }
            .buttonStyle(PrimaryButtonStyle(backgroundColor: AppColors.primaryAction))
            .disabled(isNextDisabled)
            .opacity(isNextDisabled ? 0.5 : 1.0)
        }
    }

    private var presetSelectionGrid: some View {
        LazyVGrid(columns: presetColumns, spacing: AppSpacing.compact) {
            ForEach(presets) { preset in
                let isSelected = selectedPreset?.id == preset.id
                
                Button {
                    selectedPreset = preset
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        Image(systemName: preset.iconName)
                            .font(.title3)
                            .foregroundStyle(isSelected ? .white : AppColors.primaryAction)

                        Text(preset.title)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(isSelected ? .white : AppColors.textPrimary)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, AppSpacing.standard)
                    .padding(.vertical, 14)
                    .background(isSelected ? AppColors.primaryAction : AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var customActivityForm: some View {
        VStack(alignment: .leading, spacing: AppSpacing.standard) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text("Activity Name")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textSecondary)

                TextField("e.g. Practice Piano", text: $customTitle)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .padding(.horizontal, AppSpacing.standard)
                    .padding(.vertical, 14)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
            }

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text("Icon Category")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textSecondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.small) {
                        ForEach(IconCategory.allCases) { category in
                            let isSelected = selectedIconCategory == category
                            
                            Button {
                                selectedIconCategory = category
                            } label: {
                                Text(category.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
                                    .padding(.horizontal, AppSpacing.standard)
                                    .padding(.vertical, AppSpacing.small)
                                    .background(isSelected ? AppColors.primaryAction : AppColors.surface)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text("Choose Icon")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(AppColors.textSecondary)

                LazyVGrid(columns: iconColumns, spacing: AppSpacing.compact) {
                    ForEach(selectedIconCategory.icons, id: \.self) { icon in
                        let isSelected = selectedCustomIcon == icon

                        Button {
                            selectedCustomIcon = icon
                        } label: {
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundStyle(isSelected ? .white : AppColors.primaryAction)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(isSelected ? AppColors.primaryAction : AppColors.surface)
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var selectedTitle: String {
        creationMode == .presets ? (selectedPreset?.title ?? "") : customTitle.trimmingCharacters(in: .whitespaces)
    }

    private var selectedIconName: String {
        creationMode == .presets ? (selectedPreset?.iconName ?? "star.fill") : selectedCustomIcon
    }

    private var isNextDisabled: Bool {
        if currentStep == 1 {
            return selectedTitle.isEmpty
        }
        return false
    }

    private func setupEditStateIfNeeded() {
        guard let moment = momentToEdit else { return }
        selectedRecurrenceType = moment.recurrence
        selectedPeriod = moment.period
        
        if let matchingPreset = presets.first(where: { $0.title == moment.title }) {
            creationMode = .presets
            selectedPreset = matchingPreset
        } else {
            creationMode = .custom
            customTitle = moment.title
            selectedCustomIcon = moment.iconName.isEmpty ? "star.fill" : moment.iconName
        }
    }

    private func saveMoment() {
        let updatedMoment = Moment(
            id: momentToEdit?.id ?? UUID(),
            title: selectedTitle,
            subtitle: momentToEdit?.subtitle ?? "",
            iconName: selectedIconName,
            period: selectedPeriod,
            isCompleted: momentToEdit?.isCompleted ?? false,
            recurrence: selectedRecurrenceType,
            dailyTimes: [notificationTime],
            selectedWeekdays: selectedRecurrenceType == .weekly ? selectedWeekdays : nil,
            monthlyIntervalDays: selectedRecurrenceType == .monthly ? daysPerMonth : nil
        )

        NotificationManager.shared.cancelNotification(for: updatedMoment.id)

        if enableNotification && (selectedRecurrenceType == .daily || selectedRecurrenceType == .weekly) {
            NotificationManager.shared.scheduleNotification(
                for: updatedMoment,
                time: notificationTime,
                weekdays: selectedRecurrenceType == .weekly ? selectedWeekdays : nil
            )
        }

        onSave(updatedMoment)
        dismiss()
    }
}

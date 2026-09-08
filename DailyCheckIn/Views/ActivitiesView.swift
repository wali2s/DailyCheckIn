//
//  ActivitiesView.swift
//  DailyCheckIn
//  Created by Wahid on 10.08.26.

//

import SwiftUI

struct ActivitiesView: View {
    
    @StateObject private var viewModel: ActivityViewModel
    
    @State private var showingCreateSheet = false
    @State private var activityToEdit: Activity?
    
    @State private var activityPendingDeletion: Activity?
    @State private var isShowingActivityDeleteConfirmation = false
    
    init(viewModel: ActivityViewModel = ActivityViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.activities.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppSpacing.section) {
                            headerView
                            emptyStateView
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.vertical, AppSpacing.standard)
                    }
                } else {
                    List {
                        // Header
                        Section {
                            headerView
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: AppSpacing.standard, leading: AppSpacing.screenHorizontal, bottom: 0, trailing: AppSpacing.screenHorizontal))
                        .listRowBackground(Color.clear)
                        
                        // Progress Card
                        Section {
                            thisWeekSection
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: AppSpacing.extraSmall, leading: AppSpacing.screenHorizontal, bottom: AppSpacing.standard, trailing: AppSpacing.screenHorizontal))
                        .listRowBackground(Color.clear)
                        
                        // MARK: - Today Section
                        if !viewModel.todayDueActivities.isEmpty || !viewModel.todayCompletedActivities.isEmpty {
                            Section(header: sectionHeader("Today")) {
                                ForEach(viewModel.todayDueActivities) { activity in
                                    activityRow(activity: activity, isCompleted: false)
                                }
                                
                                ForEach(viewModel.todayCompletedActivities) { activity in
                                    activityRow(activity: activity, isCompleted: true)
                                }
                            }
                        }
                        
                        // MARK: - This Week Section
                        if !viewModel.thisWeekPlannedActivities.isEmpty {
                            Section(header: sectionHeader("This Week")) {
                                ForEach(viewModel.thisWeekPlannedActivities) { activity in
                                    activityRow(activity: activity, isCompleted: false)
                                }
                            }
                        }
                        
                        // MARK: - Paused Section
                        if !viewModel.pausedActivities.isEmpty {
                            Section(header: sectionHeader("Paused")) {
                                ForEach(viewModel.pausedActivities) { activity in
                                    activityRow(activity: activity, isCompleted: false)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(AppColors.warmCanvas)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(AppColors.primaryAction)
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateActivityView { newActivity in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.addActivity(newActivity)
                    }
                }
            }
            .sheet(item: $activityToEdit) { activity in
                CreateActivityView(activityToEdit: activity) { updatedActivity in
                    withAnimation {
                        viewModel.updateActivity(updatedActivity)
                    }
                }
            }
            .confirmationDialog(
                "Delete Activity?",
                isPresented: $isShowingActivityDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Activity", role: .destructive) {
                    guard let activityPendingDeletion else {
                        return
                    }

                    withAnimation {
                        viewModel.deleteActivity(
                            activityPendingDeletion
                        )
                    }

                    self.activityPendingDeletion = nil
                }

                Button("Cancel", role: .cancel) {
                    activityPendingDeletion = nil
                }
            } message: {
                Text(
                    "This also permanently deletes all saved "
                    + "completions for this activity."
                )
            }
        }
    }
    
    // MARK: - Headers & Row Helpers
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(AppColors.textPrimary)
            .textCase(nil)
            .padding(.top, AppSpacing.standard)
            .padding(.bottom, AppSpacing.extraSmall)
    }
    
    private func activityRow(activity: Activity, isCompleted: Bool) -> some View {
        activityCard(activity: activity, isCompleted: isCompleted)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    withAnimation {
                        activityPendingDeletion = activity
                        isShowingActivityDeleteConfirmation = true                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: AppSpacing.extraSmall, leading: AppSpacing.screenHorizontal, bottom: AppSpacing.extraSmall, trailing: AppSpacing.screenHorizontal))
            .listRowBackground(Color.clear)
    }
    
    // MARK: - Header Subview
    private var headerView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text("Activity")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            Text("What would you like to make time for today?")
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
    
    // MARK: - Activity Card View
    private func activityCard(activity: Activity, isCompleted: Bool) -> some View {
        let isFullyCompletedThisWeek = viewModel.isFullyCompletedForWeek(activity: activity)
        
        return VStack(spacing: AppSpacing.standard) {
            HStack(spacing: AppSpacing.standard) {
                
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    HStack {
                        Image(systemName: activity.iconName.isEmpty ? "sparkles" : activity.iconName)
                            .font(.title3)
                            .foregroundStyle(activity.isActive ? AppColors.accentMint : AppColors.textSecondary.opacity(0.6))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(activity.title)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    !activity.isActive
                                    ? AppColors.textSecondary.opacity(0.7)
                                    : (isFullyCompletedThisWeek ? AppColors.textSecondary : AppColors.textPrimary)
                                )
                            
                            if !activity.subtitle.isEmpty {
                                Text(activity.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "timer")
                            .font(.caption)
                            .foregroundStyle(activity.isActive ? AppColors.primaryAction : AppColors.textSecondary.opacity(0.5))
                        
                        Text("\(activity.targetMinutes) Min")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(AppColors.textSecondary.opacity(0.7))
                        
                        Text(activity.period.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.textSecondary.opacity(0.7))
                            .padding(.horizontal, AppSpacing.small)
                            .padding(.vertical, AppSpacing.extraSmall)
                            .background(AppColors.surfaceSecondary.opacity(activity.isActive ? 0.5 : 0.25))
                            .clipShape(Capsule())
                    }
                    if activity.recurrence == .monthly,
                       let nextDueDate = viewModel.nextMonthlyDueDate(
                            for: activity
                       ) {
                        HStack(spacing: 5) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.caption)
                                .foregroundStyle(AppColors.primaryAction)

                            Text(
                                Calendar.current.isDateInToday(nextDueDate)
                                    ? "Due today"
                                    : "Next: "
                                        + nextDueDate.formatted(
                                            date: .abbreviated,
                                            time: .omitted
                                        )
                            )
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(AppColors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: AppSpacing.small) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.toggleActive(activity)
                        }
                    } label: {
                        Image(systemName: activity.isActive ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(activity.isActive ? AppColors.pauseButton.opacity(0.8) : Color.white)
                            .frame(width: 44, height: 44)
                            .background {
                                Circle()
                                    .fill(activity.isActive ? AppColors.pauseButton.opacity(0.12) : AppColors.accentMint)
                            }
                            .shadow(
                                color: activity.isActive ? Color.clear : AppColors.accentMint,
                                radius: 6,
                                x: 0,
                                y: 3
                            )
                            .overlay(
                                Circle()
                                    .stroke(activity.isActive ? Color.clear : Color.white.opacity(0.6), lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.borderless)
                    
                    if activity.isActive {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.textSecondary.opacity(0.3))
                    }
                }
            }
            
            if activity.isActive {
                Divider()
                    .padding(.vertical, 2)
                
                weekDaysTrackerView(for: activity)
                    .onTapGesture { }
                    .allowsHitTesting(true)
                
                doneButtonSection(for: activity)
            }
        }
        .padding(AppSpacing.cardPadding)
        .background(AppColors.warmSurface)
        .opacity(activity.isActive ? (isFullyCompletedThisWeek ? 0.75 : 1.0) : 0.55)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .shadow(color: Color.black.opacity(activity.isActive ? 0.04 : 0.01), radius: 8, x: 0, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .onTapGesture {
            if activity.isActive {
                activityToEdit = activity
            }
        }
    }
    
    // MARK: - Week Days Tracker Subview
        @ViewBuilder
        private func weekDaysTrackerView(for activity: Activity) -> some View {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) {
                let weekDates: [Date] = (0..<7).compactMap { dayOffset in
                    calendar.date(byAdding: .day, value: dayOffset, to: weekInterval.start)
                }
                
                let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]
                
                HStack {
                    Spacer()
                    HStack(spacing: 16) {
                        ForEach(0..<weekDates.count, id: \.self) { index in
                            let date = weekDates[index]
                            let isToday = calendar.isDate(date, inSameDayAs: today)
                            let isCompleted = viewModel.isCompleted(activity, on: date)
                            
                            let weekday = calendar.component(.weekday, from: date)
                            
                            let isScheduled = viewModel.isDue(
                                activity,
                                on: date
                            )
                            
                            VStack(spacing: 6) {
                                Text(dayLabels[index])
                                    .font(.system(size: 13, weight: isToday ? .bold : .medium))
                                    .foregroundStyle(isToday ? AppColors.textPrimary : AppColors.textSecondary)
                                
                                ZStack {
                                    Circle()
                                        .fill(
                                            !isScheduled
                                            ? Color(.systemGray6)
                                            : (isCompleted ? AppColors.accentMint : AppColors.surfaceSecondary.opacity(0.6)) // Eingeplant: Grün wenn Done, sonst Sekundärfarbe
                                        )
                                        .frame(width: 32, height: 32)
                                    
                                    if !isScheduled {
                                        Image(systemName: "minus")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(AppColors.textSecondary.opacity(0.6))
                                    } else if isCompleted {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)
                                    } else {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(AppColors.textSecondary.opacity(0.5))
                                    }
                                }
                                .overlay(
                                    Circle()
                                        .stroke(isToday && isScheduled && !isCompleted ? AppColors.accentMint : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }
                    Spacer()
                }
            } else {
                EmptyView()
            }
        }
    
    // MARK: - Dynamic Done / Undone / Completed Button Subview
    private func doneButtonSection(for activity: Activity) -> some View {
        let calendar = Calendar.current
        let today = Date()
                
        let isScheduledForToday = viewModel.isDue(
            activity,
            on: today
        )
        
        let isTodayDone = viewModel.isCompleted(activity, on: today)
        let isFullyCompletedThisWeek = viewModel.isFullyCompletedForWeek(activity: activity)
        
        let buttonTitle: String
        let iconName: String
        
        if isFullyCompletedThisWeek {
            buttonTitle = "Completed"
            iconName = "checkmark.circle.fill"
        } else if !isScheduledForToday {
            buttonTitle = "Not Scheduled Today"
            iconName = "calendar.badge.clock"
        } else if isTodayDone {
            buttonTitle = "Mark as Undone"
            iconName = "arrow.uturn.backward.circle"
        } else {
            buttonTitle = "Done"
            iconName = "circle"
        }

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.toggleCompletion(for: activity, on: today)
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .bold))
                
                Text(buttonTitle)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                isFullyCompletedThisWeek
                ? AppColors.accentMint.opacity(0.18)
                : (!isScheduledForToday
                   ? AppColors.pauseButton
                   : (isTodayDone ? AppColors.primaryAction : AppColors.accentMint))
            )
            .foregroundStyle(
                isFullyCompletedThisWeek
                ? AppColors.accentMint
                : Color.white
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.borderless)
        .disabled(!isScheduledForToday)
    }
    
    private var thisWeekSection: some View {
        
        let completed = viewModel.weeklyCompletedCount()
        let total = viewModel.weeklyTargetCount()
        
        let progress: Double = total > 0
            ? Double(completed) / Double(total)
            : 0
        
        return VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            
            Text("This Week")
                .font(
                    .system(
                        size: 24,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    AppColors.textPrimary
                )
            
            VStack(
                spacing: AppSpacing.standard
            ) {
                
                // MARK: Progress Circle
                
                ZStack {
                    
                    Circle()
                        .stroke(
                            AppColors.surfaceSecondary,
                            lineWidth: 10
                        )
                    
                    Circle()
                        .trim(
                            from: 0,
                            to: progress
                        )
                        .stroke(
                            AppColors.primaryAction,
                            style: StrokeStyle(
                                lineWidth: 10,
                                lineCap: .round
                            )
                        )
                        .rotationEffect(
                            .degrees(-90)
                        )
                        .animation(
                            .easeInOut(duration: 0.5),
                            value: progress
                        )
                    
                    VStack(
                        spacing: 2
                    ) {
                        Text("\(completed)")
                            .font(
                                .system(
                                    size: 28,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(
                                AppColors.textPrimary
                            )
                        
                        Text("of \(total)")
                            .font(
                                .caption
                            )
                            .foregroundStyle(
                                AppColors.textSecondary
                            )
                    }
                }
                .frame(
                    width: 110,
                    height: 110
                )
                
                // MARK: Percentage
                
                Text("\(Int(progress * 100))%")
                    .font(
                        .system(
                            size: 20,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        AppColors.primaryAction
                    )
                
                // MARK: Progress Dots
                
                if total > 0 {
                    HStack(
                        spacing: AppSpacing.standard
                    ) {
                        
                        HStack(
                            spacing: 6
                        ) {
                            Image(
                                systemName: "checkmark.circle.fill"
                            )
                            .font(.caption)
                            .foregroundStyle(
                                AppColors.accentMint
                            )
                            
                            Text("\(completed) completed")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(
                                    AppColors.textSecondary
                                )
                        }
                        
                        Text("•")
                            .foregroundStyle(
                                AppColors.textSecondary.opacity(0.4)
                            )
                        
                        HStack(
                            spacing: 6
                        ) {
                            Image(
                                systemName: "circle"
                            )
                            .font(.caption)
                            .foregroundStyle(
                                AppColors.textSecondary.opacity(0.55)
                            )
                            
                            Text("\(max(total - completed, 0)) remaining")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(
                                    AppColors.textSecondary
                                )
                        }
                    }
                }
                
                // MARK: Description
                
                Text(
                    total == 0
                    ? "Add an activity for this week."
                    : weeklyProgressMessage(
                        progress: progress
                    )
                )
                .font(
                    .subheadline
                )
                .foregroundStyle(
                    AppColors.textSecondary
                )
                .multilineTextAlignment(
                    .center
                )
            }
            .frame(
                maxWidth: .infinity
            )
            .padding(
                AppSpacing.cardPadding
            )
            .background(
                AppColors.warmSurface
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: AppCornerRadius.large,
                    style: .continuous
                )
            )
        }
    }
    
    private func weeklyProgressMessage(
        progress: Double
    ) -> String {
        
        switch progress {
        case 0:
            return "A new week is a fresh start."
            
        case 0..<0.5:
            return "You're getting started."
            
        case 0.5..<1:
            return "You're building a good rhythm."
            
        default:
            return "Great job this week."
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: AppSpacing.standard) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.textSecondary)
            
            Text("No activities planned yet")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            
            Text("Tap the plus icon in the top right corner to pick from preset activities or create your own.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.standard)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.extraLarge)
        .appCardStyle(backgroundColor: AppColors.warmSurface)
    }
}
// MARK: - Previews
#Preview("Default State") {
    ActivitiesView()
}

#Preview("Dark Mode") {
    ActivitiesView()
        .preferredColorScheme(.dark)
}

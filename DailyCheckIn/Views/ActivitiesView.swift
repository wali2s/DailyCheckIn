//
//  ActivitiesView.swift
//  DailyCheckIn
//

import SwiftUI

struct ActivitiesView: View {
    
    @StateObject private var viewModel: ActivityViewModel
    
    @State private var showingCreateSheet = false
    @State private var activityToEdit: Activity?
    @State private var selectedActivity: Activity?
    
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
            .sheet(item: $selectedActivity) { activity in
                ActivityDetailView(
                    activity: activity,
                    viewModel: viewModel,
                    onCompletionToggle: {
                        viewModel.toggleCompletion(for: activity, on: Date())
                    }
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
                        viewModel.deleteActivity(activity)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }

                Button {
                    activityToEdit = activity
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(.blue)
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
            HStack(spacing: AppSpacing.standard) {
                
                // Linker Bereich: Icon & Text (ohne Durchstreichen)
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    HStack {
                        Image(systemName: activity.iconName.isEmpty ? "sparkles" : activity.iconName)
                            .font(.title3)
                            .foregroundStyle(activity.isActive ? AppColors.accentMint : AppColors.textSecondary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(activity.title)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                            
                            if !activity.subtitle.isEmpty {
                                Text(activity.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "timer")
                            .font(.caption)
                            .foregroundStyle(AppColors.primaryAction)
                        
                        Text("\(activity.targetMinutes) Min")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(AppColors.textSecondary)
                        
                        Text(activity.period.rawValue.capitalized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.textSecondary)
                            .padding(.horizontal, AppSpacing.small)
                            .padding(.vertical, AppSpacing.extraSmall)
                            .background(AppColors.surfaceSecondary.opacity(0.5))
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                // Rechter Aktionsbereich: Play/Pause + Checkmark Indicator
                HStack(spacing: AppSpacing.small) {
                    
                    // 1. Play/Pause Button für Aktivitäts-Status
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.toggleActive(activity)
                        }
                    } label: {
                        Image(systemName: activity.isActive ? "pause.fill" : "play.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(activity.isActive ? AppColors.pauseButton.opacity(0.8) : AppColors.accentMint)
                            .frame(width: 40, height: 40)
                            .background {
                                Circle()
                                    .fill(activity.isActive ? AppColors.pauseButton.opacity(0.12) : AppColors.accentMint.opacity(0.18))
                            }
                    }
                    .buttonStyle(.plain)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppColors.accentMint)
                            .frame(width: 39, height: 39)
                            .background(
                                Circle()
                                    .fill(AppColors.accentMint.opacity(0.15))
                            )
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.textSecondary.opacity(0.3))
                }
            }
            .padding(AppSpacing.cardPadding)
            .background(AppColors.warmSurface)
            .opacity(activity.isActive ? (isCompleted ? 0.65 : 1.0) : 0.5)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
            .contentShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
            .onTapGesture {
                selectedActivity = activity
            }
        }
    // MARK: - This Week Section
    private var thisWeekSection: some View {
        let completed = viewModel.weeklyCompletedCount()
        let total = viewModel.weeklyTargetCount()
        let progress: Double = total > 0 ? Double(completed) / Double(total) : 0
        
        return VStack(alignment: .leading, spacing: AppSpacing.standard) {
            Text("This Week")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
            
            VStack(alignment: .leading, spacing: AppSpacing.standard) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(completed) of \(total) activities")
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        
                        Text(total == 0 ? "Add an activity for this week." : "Keep making time for yourself.")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.primaryAction)
                }
                
                ProgressView(value: progress, total: 1)
                    .tint(AppColors.primaryAction)
            }
            .padding(AppSpacing.cardPadding)
            .background(AppColors.warmSurface)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
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

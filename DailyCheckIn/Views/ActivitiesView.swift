//
//  ActivityView.swift
//  DailyCheckIn
//
//  Created by Wahid on 20.08.26.
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
                        Section {
                            headerView
                                .padding(.bottom, AppSpacing.small)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: AppSpacing.standard, leading: AppSpacing.screenHorizontal, bottom: 0, trailing: AppSpacing.screenHorizontal))
                        .listRowBackground(Color.clear)
                        
                        Section {
                            thisWeekSection
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: AppSpacing.extraSmall, leading: AppSpacing.screenHorizontal, bottom: AppSpacing.standard, trailing: AppSpacing.screenHorizontal))
                        .listRowBackground(Color.clear)
                        
                        ForEach(viewModel.activities) { activity in
                            activityCard(activity: activity)
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
                CreateActivityView(activityToEdit: activity) { updateActivity in
                    withAnimation {
                        viewModel.updateactivity(updateActivity)
                    }
                }
            }
            .sheet(item: $selectedActivity) { activity in
               ActivityDetailView(
                activity: activity,
                    viewModel: viewModel,
                    onCompletionToggle: {
                        viewModel.toggleCompletion(
                            for: activity
                        )
                    }
                )
            }
        }
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
    private func activityCard(activity: Activity) -> some View {
        HStack(spacing: AppSpacing.standard) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                
                HStack {
                    Image(systemName: activity.iconName.isEmpty ? "sparkles" : activity.iconName)
                        .font(.title3)
                        .foregroundStyle(AppColors.accentMint)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(activity.title)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.textPrimary)
                        
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
            
            Button {
                withAnimation(
                    .spring(
                        response: 0.3,
                        dampingFraction: 0.7
                    )
                ) {
                    viewModel.toggleActive(activity)
                }
            } label: {
                
                Image(
                    systemName: activity.isActive
                    ? "pause.fill"
                    : "play.fill"
                )
                .font(
                    .system(
                        size: 17,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    activity.isActive
                    ? AppColors.primaryAction
                    : AppColors.accentMint
                )
                .frame(
                    width: 44,
                    height: 44
                )
                .background {
                    Circle()
                        .fill(
                            activity.isActive
                            ? AppColors.primaryAction.opacity(0.12)
                            : AppColors.accentMint.opacity(0.18)
                        )
                }
            }
            .buttonStyle(.plain)
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.textSecondary.opacity(0.3))
        }
        .padding(AppSpacing.cardPadding)
        .background(AppColors.warmSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
        .contentShape(
            RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
        )
        .onTapGesture {
            selectedActivity = activity
        }
    }
    
    // MARK: - This Week

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
                alignment: .leading,
                spacing: AppSpacing.standard
            ) {
                
                HStack {
                    
                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {
                        Text(
                            "\(completed) of \(total) activities"
                        )
                        .font(.headline)
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                        
                        Text(
                            total == 0
                            ? "Add a activity for this week."
                            : "Keep making time for yourself."
                        )
                        .font(.subheadline)
                        .foregroundStyle(
                            AppColors.textSecondary
                        )
                    }
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(
                            .system(
                                size: 26,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            AppColors.primaryAction
                        )
                }
                
                ProgressView(
                    value: progress,
                    total: 1
                )
                .tint(
                    AppColors.primaryAction
                )
            }
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

// MARK: - Preview
#Preview("Default State") {
    ActivitiesView()
}

#Preview("Dark Mode") {
    ActivitiesView()
        .preferredColorScheme(.dark)
}

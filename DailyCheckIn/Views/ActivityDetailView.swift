//
//  ActivityDetailView.swift
//  DailyCheckIn
//
//  Created by Wahid on 26.08.26.
//

import SwiftUI

struct ActivityDetailView: View {
    
    let activity: Activity
    @ObservedObject var viewModel: ActivityViewModel
    let onCompletionToggle: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var todayIsCompleted = false
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        
        guard let weekStart = calendar.date(
            from: calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: Date()
            )
        ) else {
            return []
        }
        
        return (0..<7).compactMap { offset in
            calendar.date(
                byAdding: .day,
                value: offset,
                to: weekStart
            )
        }
    }
        
    init(
        activity: Activity,
        viewModel: ActivityViewModel,
        onCompletionToggle: @escaping () -> Void
    ) {
        self.activity = activity
        self.viewModel = viewModel
        self.onCompletionToggle = onCompletionToggle
        
        _todayIsCompleted = State(
            initialValue: viewModel.isCompleted(
                activity,
                on: Date()
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: AppSpacing.section
                ) {
                    
                    // MARK: - Header
                    
                    VStack(
                        alignment: .leading,
                        spacing: AppSpacing.standard
                    ) {
                        Image(systemName: activity.iconName)
                            .font(.system(size: 34))
                            .foregroundStyle(
                                AppColors.accentMint
                            )
                        
                        Text(activity.title)
                            .font(
                                .system(
                                    size: 30,
                                    weight: .bold,
                                    design: .rounded
                                )
                            )
                            .foregroundStyle(
                                AppColors.textPrimary
                            )
                        
                        if !activity.subtitle.isEmpty {
                            Text(activity.subtitle)
                                .font(.body)
                                .foregroundStyle(
                                    AppColors.textSecondary
                                )
                        }
                    }
                    
                    // MARK: - Today
                    
                    todaySection
                    
                    // MARK: - This Week
                    
                    weeklyHistorySection
                    
                    // MARK: - Action
                    
                    Button {
                        withAnimation(
                            .spring(
                                response: 0.35,
                                dampingFraction: 0.7
                            )
                        ) {
                            todayIsCompleted.toggle()
                            onCompletionToggle()
                        }
                    } label: {
                        HStack {
                            Image(
                                systemName:
                                    todayIsCompleted
                                    ? "arrow.uturn.backward"
                                    : "checkmark"
                            )
                            
                            Text(
                                todayIsCompleted
                                ? "Mark as not done"
                                : "Done today"
                            )
                        }
                        .frame(
                            maxWidth: .infinity
                        )
                    }
                    .buttonStyle(
                        PrimaryButtonStyle(
                            backgroundColor:
                                todayIsCompleted
                                ? AppColors.textSecondary
                                : AppColors.primaryAction
                        )
                    )
                }
                .padding(
                    .horizontal,
                    AppSpacing.screenHorizontal
                )
                .padding(
                    .vertical,
                    AppSpacing.standard
                )
            }
            .background(
                AppColors.warmCanvas
            )
            .navigationTitle("Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Today Section
    
    private var todaySection: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            Text("Today")
                .font(
                    .system(
                        size: 22,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    AppColors.textPrimary
                )
            
            HStack(
                spacing: AppSpacing.standard
            ) {
                Image(
                    systemName:
                        todayIsCompleted
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .font(.system(size: 28))
                .foregroundStyle(
                    todayIsCompleted
                    ? AppColors.accentMint
                    : AppColors.textSecondary
                )
                .scaleEffect(
                    todayIsCompleted ? 1.0 : 0.9
                )
                .animation(
                    .spring(
                        response: 0.35,
                        dampingFraction: 0.7
                    ),
                    value: todayIsCompleted
                )
                
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text(
                        todayIsCompleted
                        ? "Completed today"
                        : "Not completed yet"
                    )
                    .font(.headline)
                    
                    Text(
                        todayIsCompleted
                        ? "You made time for this today."
                        : "Did you make time for this today?"
                    )
                    .font(.subheadline)
                    .foregroundStyle(
                        AppColors.textSecondary
                    )
                }
                
                Spacer()
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
    
    // MARK: - Weekly History
    
    private var weeklyHistorySection: some View {
        let calendar = Calendar.current
        
        return VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            Text("This Week")
                .font(
                    .system(
                        size: 22,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    AppColors.textPrimary
                )
            
            HStack(spacing: 8) {
                ForEach(
                    weekDates,
                    id: \.self
                ) { date in
                    
                    let isToday =
                        calendar.isDateInToday(date)
                    
                    let isFuture =
                        date >
                        calendar.startOfDay(
                            for: Date()
                        )
                    
                    let completed = Calendar.current.isDate(
                        date,
                        inSameDayAs: Date()
                    )
                    ? todayIsCompleted
                    : viewModel.isCompleted(
                        activity,
                        on: date
                    )
                    
                    VStack(spacing: 8) {
                        
                        Text(
                            date,
                            format: .dateTime.weekday(
                                .narrow
                            )
                        )
                        .font(.caption)
                        .fontWeight(
                            isToday
                            ? .bold
                            : .medium
                        )
                        .foregroundStyle(
                            isToday
                            ? AppColors.primaryAction
                            : AppColors.textSecondary
                        )
                        
                        ZStack {
                            Circle()
                                .fill(
                                    completed
                                    ? AppColors.accentMint
                                    : AppColors.surfaceSecondary
                                )
                            
                            if completed {
                                Image(
                                    systemName: "checkmark"
                                )
                                .font(
                                    .system(
                                        size: 13,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(
                                    AppColors.warmSurface
                                )
                            } else if !isFuture {
                                Image(
                                    systemName: "minus"
                                )
                                .font(
                                    .system(
                                        size: 12,
                                        weight: .medium
                                    )
                                )
                                .foregroundStyle(
                                    AppColors.textSecondary
                                )
                            }
                        }
                        .frame(
                            width: 30,
                            height: 30
                        )
                        .overlay {
                            if isToday {
                                Circle()
                                    .stroke(
                                        AppColors.primaryAction
                                            .opacity(0.35),
                                        lineWidth: 2
                                    )
                            }
                        }
                    }
                    .frame(
                        maxWidth: .infinity
                    )
                }
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
}

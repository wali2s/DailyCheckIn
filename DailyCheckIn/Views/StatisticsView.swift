//
//  StatisticsView.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    
    @StateObject private var viewModel: StatisticsViewModel
    
    init(
        homeViewModel: HomeViewModel
    ) {
        _viewModel = StateObject(
            wrappedValue: StatisticsViewModel(
                homeViewModel: homeViewModel
            )
        )
    }
    
    var body: some View {
        List {
            filterSection
            
            if viewModel.filteredCheckIns.isEmpty {
                emptyStatisticsSection
            } else {
                moodTrendSection
                metricsSection
                summarySection
                insightsSection
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppColors.canvas)
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var filterSection: some View {
        Section {
            Picker(
                "Space",
                selection: $viewModel.selectedSpace
            ) {
                ForEach(JournalSpace.allCases) { space in
                    Text(space.title)
                        .tag(space)
                }
            }
            .pickerStyle(.segmented)
            .listRowInsets(
                EdgeInsets(
                    top: 12,
                    leading: 16,
                    bottom: 12,
                    trailing: 16
                )
            )
            
            Picker(
                "Period",
                selection: $viewModel.selectedPeriod
            ) {
                ForEach(
                    StatisticsPeriod.allCases
                ) { period in
                    Text(period.title)
                        .tag(period)
                }
            }.pickerStyle(.menu)
            .listRowInsets(
                EdgeInsets(
                    top: 8,
                    leading: 16,
                    bottom: 8,
                    trailing: 16
                )
            )
        }
        .listRowBackground(AppColors.surface)
    }
    
    private var emptyStatisticsSection: some View {
        Section {
            ContentUnavailableView(
                "No Statistics Yet",
                systemImage: "chart.bar.xaxis",
                description: Text(
                    "Create a check-in to see your statistics."
                )
            )
            .frame(
                maxWidth: .infinity,
                minHeight: 240
            )
            .listRowInsets(
                EdgeInsets(
                    top: 24,
                    leading: 0,
                    bottom: 24,
                    trailing: 0
                )
            )
        }
        .listRowBackground(Color.clear)
    }
    
    private var moodTrendSection: some View {
        Section("Mood Trend") {
            moodTrendChart
                .frame(
                    minHeight: 220
                )
                .listRowInsets(
                    EdgeInsets(
                        top: 16,
                        leading: 8,
                        bottom: 16,
                        trailing: 8
                    )
                )
        }
        .listRowBackground(AppColors.surface)
    }
    
    private var moodTrendChart: some View {
        Chart {
            ForEach(
                viewModel.filteredCheckIns.sorted {
                    $0.date < $1.date
                }
            ) { checkIn in
                BarMark(
                    x: .value(
                        "Date",
                        checkIn.date,
                        unit: .day
                    ),
                    y: .value(
                        "Mood",
                        checkIn.mood.score
                    )
                )
                .foregroundStyle(
                    checkIn.mood.iconColor
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 10,
                        style: .continuous
                    )
                )
                .annotation(
                    position: .top,
                    alignment: .center
                ) {
                    Image(
                        systemName: checkIn.mood.iconName
                    )
                    .font(.caption)
                    .foregroundStyle(
                        checkIn.mood.iconColor
                    )
                    .accessibilityHidden(true)
                }
            }
        }
        .frame(
            height: 240
        )
        .chartYScale(
            domain: 0...5
        )
        .chartYAxis {
            AxisMarks(
                values: [1, 2, 3, 4, 5]
            ) { value in
                AxisGridLine()
                    .foregroundStyle(
                        AppColors.textSecondary.opacity(0.12)
                    )
                
                AxisValueLabel()
                    .foregroundStyle(
                        AppColors.textSecondary
                    )
            }
        }
        .chartXAxis {
            AxisMarks(
                values: .stride(
                    by: .day
                )
            ) { value in
                AxisValueLabel(
                    format: .dateTime.weekday(
                        .abbreviated
                    )
                )
                .foregroundStyle(
                    AppColors.textSecondary
                )
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(
                    AppColors.surface.opacity(0.1)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppCornerRadius.standard,
                        style: .continuous
                    )
                )
        }
        .accessibilityElement(
            children: .ignore
        )
        .accessibilityLabel(
            "Mood trend"
        )
        .accessibilityValue(
            moodChartAccessibilityValue
        )
    }
    
    private var metricsSection: some View {
        Section("Daily Averages") {
            MetricSummaryRow(
                title: "Average Mood",
                value: viewModel.formattedAverage(
                    viewModel.averageMood
                ),
                progress: viewModel.averageMood,
                tint: AppColors.accentMint,
                systemImage: "chart.line.uptrend.xyaxis"
            )
            
            MetricSummaryRow(
                title: "Average Energy",
                value: viewModel.formattedAverage(
                    viewModel.averageEnergy
                ),
                progress: viewModel.averageEnergy,
                tint: AppColors.accentYellow,
                systemImage: "bolt.fill"
            )
            
            MetricSummaryRow(
                title: "Average Stress",
                value: viewModel.formattedAverage(
                    viewModel.averageStress
                ),
                progress: viewModel.averageStress,
                tint: AppColors.accentPink,
                systemImage: "waveform.path.ecg"
            )
        }
        .listRowBackground(AppColors.surface)
    }
    
    private struct MetricSummaryRow: View {
        
        let title: String
        let value: String
        let progress: Double
        let tint: Color
        let systemImage: String
        
        var body: some View {
            VStack(
                alignment: .leading,
                spacing: 8
            ) {
                HStack(
                    spacing: AppSpacing.small
                ) {
                    Image(systemName: systemImage)
                        .foregroundStyle(tint)
                        .frame(width: 22)
                    
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                    
                    Spacer()
                    
                    Text(value)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                }
                
                ProgressView(
                    value: progress,
                    total: 5
                )
                .tint(tint)
                .accessibilityLabel(title)
                .accessibilityValue(value)
            }
            .padding(.vertical, 6)
        }
    }
    
    private var summarySection: some View {
        Section("Check-Ins") {
            HStack(
                spacing: AppSpacing.standard
            ) {
                ZStack {
                    RoundedRectangle(
                        cornerRadius: AppCornerRadius.small,
                        style: .continuous
                    )
                    .fill(
                        AppColors.accentMint.opacity(0.22)
                    )
                    .frame(
                        width: 48,
                        height: 48
                    )
                    
                    Image(
                        systemName: "checkmark.circle.fill"
                    )
                    .font(.title3)
                    .foregroundStyle(
                        AppColors.accentMint
                    )
                }
                
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {
                    Text("Total Check-Ins")
                        .font(.headline)
                        .foregroundStyle(
                            AppColors.textPrimary
                        )
                    
                    Text("In selected period")
                        .font(.subheadline)
                        .foregroundStyle(
                            AppColors.textSecondary
                        )
                }
                
                Spacer()
                
                Text(
                    "\(viewModel.totalCheckIns)"
                )
                .font(.system(
                    size: 30,
                    weight: .bold,
                    design: .rounded
                ))
                .foregroundStyle(
                    AppColors.textPrimary
                )
            }
            .padding(.vertical, 6)
            .accessibilityElement(
                children: .combine
            )
            .accessibilityLabel("Total Check-Ins")
            .accessibilityValue(
                "\(viewModel.totalCheckIns)"
            )
        }
        .listRowBackground(AppColors.surface)
    }
    
    private var insightsSection: some View {
        Section("Insights") {
            if viewModel.insights.isEmpty {
                Text(
                    "More check-ins are needed to generate insights."
                )
                .font(.subheadline)
                .foregroundStyle(
                    AppColors.textSecondary
                )
            } else {
                ForEach(
                    viewModel.insights,
                    id: \.self
                ) { insight in
                    Label(
                        insight,
                        systemImage: "lightbulb.fill"
                    )
                    .foregroundStyle(
                        AppColors.textPrimary
                    )
                }
            }
        }
        .listRowBackground(AppColors.surface)
    }
    
    private var moodChartAccessibilityValue: String {
        guard let firstCheckIn =
            viewModel.filteredCheckIns.first
        else {
            return "No mood data available"
        }
        
        let firstMood = firstCheckIn.mood.title
        
        guard let lastCheckIn =
            viewModel.filteredCheckIns.last
        else {
            return "Mood was \(firstMood)"
        }
        
        let lastMood = lastCheckIn.mood.title
        
        if firstMood == lastMood {
            return "Mood remained \(lastMood)"
        }
        
        return "Mood changed from \(firstMood) to \(lastMood)"
    }
}


#Preview("Statistics - Light Mode") {
    NavigationStack {
        StatisticsView(
            homeViewModel: HomeViewModel(
                storageService:
                    StatisticsPreviewStorageService()
            )
        )
    }
    .preferredColorScheme(.light)
}

#Preview("Statistics - Dark Mode") {
    NavigationStack {
        StatisticsView(
            homeViewModel: HomeViewModel(
                storageService:
                    StatisticsPreviewStorageService()
            )
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Statistics - Sample Data") {
    NavigationStack {
        StatisticsView(
            homeViewModel: HomeViewModel(
                storageService:
                    StatisticsPreviewStorageService()
            )
        )
    }
}

final class StatisticsPreviewStorageService:
    CheckInStorageService {
    
    
    
    private var previewCheckIns: [CheckIn] = [
        CheckIn(
            date: Date(),
            space: .personal,
            mood: .good,
            energyLevel: 4,
            stressLevel: 2,
            note: "Had a calm and productive day.",
            tags: [
                "Calm",
                "Productive"
            ]
        ),
        
        CheckIn(
            date: Date().addingTimeInterval(-86_400),
            space: .personal,
            mood: .calm,
            energyLevel: 5,
            stressLevel: 1,
            note: "Spent time with my family.",
            tags: [
                "Family"
            ]
        ),
        
        CheckIn(
            date: Date(),
            space: .professional,
            mood: .neutral,
            energyLevel: 3,
            stressLevel: 4,
            note: "Worked on the Daily Check-In app.",
            tags: [
                "Development"
            ]
        ),
        
        CheckIn(
            date: Date().addingTimeInterval(-2 * 86_400),
            space: .professional,
            mood: .happy,
            energyLevel: 5,
            stressLevel: 1,
            note: "A very productive day.",
            tags: ["Focus"]
        ),

        CheckIn(
            date: Date().addingTimeInterval(-4 * 86_400),
            space: .personal,
            mood: .sad,
            energyLevel: 2,
            stressLevel: 4,
            note: "Needed more time to rest.",
            tags: ["Rest"]
        ),

        CheckIn(
            date: Date().addingTimeInterval(-6 * 86_400),
            space: .professional,
            mood: .calm,
            energyLevel: 4,
            stressLevel: 2,
            note: "A balanced workday.",
            tags: ["Balance"]
        )
    ]
    
    func loadCheckIns() -> [CheckIn] {
        previewCheckIns
    }
    
    func saveCheckIns(
        _ checkIns: [CheckIn]
    ) {
        previewCheckIns = checkIns
    }
}

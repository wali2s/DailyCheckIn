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
        .background(AppColors.warmCanvas)
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Filters

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
                ForEach(StatisticsPeriod.allCases) { period in
                    Text(period.title)
                        .tag(period)
                }
            }
            .pickerStyle(.automatic)
            .listRowInsets(
                EdgeInsets(
                    top: 8,
                    leading: 16,
                    bottom: 8,
                    trailing: 16
                )
            )
        }
        .listRowBackground(AppColors.warmSurface)
    }

    // MARK: - Empty State

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

    // MARK: - Mood Trend

    private var moodTrendSection: some View {
        Section("Mood Trend") {
            moodTrendContent
                .frame(
                    minHeight: 240
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
        .listRowBackground(AppColors.warmSurface)
    }

    @ViewBuilder
    private var moodTrendContent: some View {
        switch viewModel.selectedPeriod {
        case .last7Days:
            weeklyMoodChart

        case .last30Days:
            monthlyMoodChart

        case .allTime:
            allTimeMoodChart
        }
    }

    // MARK: - Last 7 Days

    private struct MoodChartDay: Identifiable {
        let date: Date
        let checkIn: CheckIn?

        var id: Date {
            date
        }
    }

    private var weeklyMoodChartDays: [MoodChartDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(
                byAdding: .day,
                value: offset - 6,
                to: today
            ) else {
                return nil
            }

            let checkIn = viewModel.filteredCheckIns.first { item in
                calendar.isDate(
                    item.date,
                    inSameDayAs: date
                )
            }

            return MoodChartDay(
                date: date,
                checkIn: checkIn
            )
        }
    }

    private var weeklyMoodChart: some View {
        Chart {
            ForEach(weeklyMoodChartDays) { day in
                if let checkIn = day.checkIn {
                    BarMark(
                        x: .value(
                            "Day",
                            checkIn.date,
                            unit: .day
                        ),
                        y: .value(
                            "Mood",
                            checkIn.mood.score
                        )
                    )
                    .foregroundStyle(
                        checkIn.mood.chartColor.opacity(0.5)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 80,
                            style: .continuous
                        )
                    )
                    .annotation(
                        position: .overlay,
                        alignment: .top,
                        spacing: 0
                    ) {
                        ZStack {
                            
                            // Etwas dunklerer Mood-Kopf
                            Circle()
                                .fill(
                                    checkIn.mood.chartColor
                                        .opacity(0.5)
                                )
                                .frame(
                                    width: 33,
                                    height: 33
                                )
                            
                            // PNG ohne Hintergrund
                            Image(checkIn.mood.chartImageName)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(1.8)
                                .opacity(0.7)
                                .fontWeight(.semibold)
                                
                        }.shadow(
                            color: .black.opacity(0.059),
                            radius: 4,
                            x: 0,
                            y: 0
                        )
                      
                    }
                } else {
                    BarMark(
                        x: .value(
                            "Date",
                            day.date,
                            unit: .day
                        ),
                        y: .value(
                            "Mood",
                            0
                        ),
                        width: .fixed(30)
                    )
                    .foregroundStyle(
                        Color.black.opacity(0.035)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        )
                    )
                }
            }
        }
        .frame(height: 240)
        .chartYScale(domain: 0...5.25)
        .chartYAxis {
            AxisMarks(
                values: [1, 2, 3, 4, 5]
            ) { _ in
                AxisGridLine()
                    .foregroundStyle(
                        AppColors.textSecondary.opacity(0.10)
                    )

                AxisValueLabel()
                    .foregroundStyle(
                        AppColors.textSecondary.opacity(0.72)
                    )
            }
        }
        .chartXAxis {
            AxisMarks(
                values: .stride(by: .day)
            ) { _ in
                AxisValueLabel(
                    format: .dateTime.weekday(.abbreviated)
                )
                .foregroundStyle(
                    AppColors.textSecondary
                )
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(
                    AppColors.warmSurface.opacity(0.65)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppCornerRadius.standard,
                        style: .continuous
                    )
                )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "Mood trend for the last seven days"
        )
        .accessibilityValue(
            moodChartAccessibilityValue
        )
    }

    // MARK: - Last 30 Days

    private struct WeeklyMoodAverage: Identifiable {
        let weekStart: Date
        let averageMood: Double

        var id: Date {
            weekStart
        }
    }

    private var monthlyMoodAverages: [WeeklyMoodAverage] {
        let calendar = Calendar.current
        let checkIns = viewModel.filteredCheckIns

        let groupedCheckIns = Dictionary(
            grouping: checkIns
        ) { checkIn in
            calendar.date(
                from: calendar.dateComponents(
                    [.yearForWeekOfYear, .weekOfYear],
                    from: checkIn.date
                )
            ) ?? checkIn.date
        }

        return groupedCheckIns
            .map { weekStart, checkIns in
                let average = checkIns
                    .map { $0.mood.score }
                    .reduce(0, +)
                    / Double(checkIns.count)

                return WeeklyMoodAverage(
                    weekStart: weekStart,
                    averageMood: average
                )
            }
            .sorted { first, second in
                first.weekStart < second.weekStart
            }
    }

    private var monthlyMoodChart: some View {
        moodLineChart(
            checkIns: viewModel.filteredCheckIns,
            accessibilityLabel: "Mood trend for the last thirty days"
        )
    }
    // MARK: - All Time

    private var allTimeMoodChart: some View {
        moodLineChart(
            checkIns: viewModel.filteredCheckIns,
            accessibilityLabel: "All-time mood trend"
        )
    }
    
    private func moodLineChart(
        checkIns: [CheckIn],
        accessibilityLabel: String
    ) -> some View {
        Chart {
            ForEach(
                checkIns.sorted { first, second in
                    first.date < second.date
                }
            ) { checkIn in
                AreaMark(
                    x: .value(
                        "Date",
                        checkIn.date
                    ),
                    y: .value(
                        "Mood",
                        checkIn.mood.score
                    )
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            AppColors.warmSurface.opacity(0.9),
                            AppColors.warmSurface.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value(
                        "Date",
                        checkIn.date
                    ),
                    y: .value(
                        "Mood",
                        checkIn.mood.score
                    )
                )
                .foregroundStyle(
                    Color.brown.opacity(0.4)
                )
                .lineStyle(
                    StrokeStyle(
                        lineWidth: 2,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value(
                        "Date",
                        checkIn.date
                    ),
                    y: .value(
                        "Mood",
                        checkIn.mood.score
                    )
                )
                .foregroundStyle(
                    checkIn.mood.chartColor.opacity(0.5)
                )
                .symbolSize(55)
                .annotation(

                    position: .top,
                    alignment: .center,
                    spacing: 6
                ) {
                    Text(checkIn.mood.title)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            checkIn.mood.titleColor.opacity(0.7)
                        )
                }
            }
        }
        .frame(height: 240)
        .chartYScale(domain: 0...5.25)
        .chartYAxis {
            AxisMarks(
                values: [1, 2, 3, 4, 5, 6]
            ) { _ in
                AxisGridLine()
                    .foregroundStyle(
                        AppColors.textSecondary.opacity(0.10)
                    )

                AxisValueLabel()
                    .foregroundStyle(
                        AppColors.textSecondary.opacity(0.72)
                    )
            }
        }
        .chartXAxis {
            AxisMarks(
                values: .automatic(desiredCount: 5)
            ) { _ in
                AxisValueLabel(
                    format: .dateTime.day().month(.abbreviated)
                )
                .foregroundStyle(
                    AppColors.textSecondary
                )
            }
        }
        .chartPlotStyle { plotArea in
            plotArea
                .background(
                    AppColors.warmSurface.opacity(0.65)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppCornerRadius.standard,
                        style: .continuous
                    )
                )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }
    
    private struct MonthlyMoodAverage: Identifiable {
        let monthStart: Date
        let averageMood: Double

        var id: Date {
            monthStart
        }
    }

    private var allTimeMoodAverages: [MonthlyMoodAverage] {
        let calendar = Calendar.current
        let checkIns = viewModel.filteredCheckIns

        let groupedCheckIns = Dictionary(
            grouping: checkIns
        ) { checkIn in
            calendar.date(
                from: calendar.dateComponents(
                    [.year, .month],
                    from: checkIn.date
                )
            ) ?? checkIn.date
        }

        return groupedCheckIns
            .map { monthStart, checkIns in
                let average = checkIns
                    .map { $0.mood.score }
                    .reduce(0, +)
                    / Double(checkIns.count)

                return MonthlyMoodAverage(
                    monthStart: monthStart,
                    averageMood: average
                )
            }
            .sorted { first, second in
                first.monthStart < second.monthStart
            }
    }

   

    // MARK: - Daily Averages

    private var metricsSection: some View {
        Section("Daily Averages") {
            
            MetricSummaryRow(
                title: "Daily Score",
                value: viewModel.formattedAverageDailyScore,
                progress: viewModel.averageDailyScore,
                tint: AppColors.accentMint,
                systemImage: "star.circle.fill"
            )
            
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
        .listRowBackground(AppColors.warmSurface)
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

    // MARK: - Check-In Count

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
        .listRowBackground(AppColors.warmSurface)
    }

    // MARK: - Insights

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
        .listRowBackground(AppColors.warmSurface)
    }

    // MARK: - Accessibility

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

// MARK: - Previews

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

// MARK: - Preview Storage

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
            energyLevel: 4,
            stressLevel: 3,
            note: "A very productive day.",
            tags: [
                "Focus"
            ]
        ),

        CheckIn(
            date: Date().addingTimeInterval(-4 * 86_400),
            space: .personal,
            mood: .sad,
            energyLevel: 4,
            stressLevel: 4,
            note: "Needed more time to rest.",
            tags: [
                "Rest"
            ]
        ),

        CheckIn(
            date: Date().addingTimeInterval(-6 * 86_400),
            space: .professional,
            mood: .calm,
            energyLevel: 4,
            stressLevel: 2,
            note: "A balanced workday.",
            tags: [
                "Balance"
            ]
        ),

        CheckIn(
            date: Date().addingTimeInterval(-5 * 86_400),
            space: .professional,
            mood: .angry,
            energyLevel: 4,
            stressLevel: 4,
            note: "A balanced workday.",
            tags: [
                "Balance"
            ]
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

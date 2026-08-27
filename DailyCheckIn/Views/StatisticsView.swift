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

    init(homeViewModel: HomeViewModel) {
        _viewModel = StateObject(
            wrappedValue: StatisticsViewModel(homeViewModel: homeViewModel)
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                filterSection
                
                if viewModel.filteredCheckIns.isEmpty {
                    emptyStatisticsSection
                } else {
                    moodTrendCard
                    metricsSection
                    summaryCard
                    insightsCard
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(AppColors.warmCanvas.ignoresSafeArea())
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Filters

    private var filterSection: some View {
        VStack(spacing: 12) {
            Picker("Space", selection: $viewModel.selectedSpace) {
                ForEach(JournalSpace.allCases) { space in
                    Text(space.title).tag(space)
                }
            }
            .pickerStyle(.segmented)

            Picker("Period", selection: $viewModel.selectedPeriod) {
                ForEach(StatisticsPeriod.allCases) { period in
                    Text(period.title).tag(period)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(12)
        .background(AppColors.warmSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
        .onChange(of: viewModel.selectedSpace) {
            withAnimation(.easeInOut(duration: 0.25)) {}
        }
        .onChange(of: viewModel.selectedPeriod) {
            withAnimation(.easeInOut(duration: 0.25)) {}
        }    }

    // MARK: - Empty State

    private var emptyStatisticsSection: some View {
        ContentUnavailableView(
            "No Statistics Yet",
            systemImage: "chart.bar.xaxis",
            description: Text("Create a check-in to see your statistics.")
        )
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(AppColors.warmSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }

    // MARK: - Mood Trend Card

    private var moodTrendCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Mood Trend", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
            }

            moodTrendContent
                .frame(height: 220)
        }
        .padding(16)
        .background(AppColors.warmSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
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

    // MARK: - Last 7 Days Chart

    private struct MoodChartDay: Identifiable {
        let date: Date
        let checkIn: CheckIn?

        var id: Date { date }
    }

    private var weeklyMoodChartDays: [MoodChartDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset - 6, to: today) else {
                return nil
            }
            let checkIn = viewModel.filteredCheckIns.first { calendar.isDate($0.date, inSameDayAs: date) }
            return MoodChartDay(date: date, checkIn: checkIn)
        }
    }

    // MARK: - Last 7 Days Chart (mit Mood-Icon IM Balken)


        private var weeklyMoodChart: some View {
            Chart {
                ForEach(weeklyMoodChartDays) { day in
                    if let checkIn = day.checkIn {
                        let moodScore = checkIn.mood.score
                        let moodColor = checkIn.mood.chartColor
                        
                        BarMark(
                            x: .value("Day", day.date, unit: .day),
                            y: .value("Mood", moodScore)
                        )
                        .foregroundStyle(moodColor.opacity(0.20))
                        .clipShape(Capsule())
                        .annotation(position: .top, alignment: .center, spacing: -28) {
                            // 2. Kräftiger runder Kopf mit Emoji an der Spitze
                            ZStack {
                                Circle()
                                    .fill(moodColor.opacity(0.85))
                                    .frame(width: 28, height: 28)
                                    .scaleEffect(1.2)
                                
                                Image(checkIn.mood.chartImageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 22, height: 22)
                                    .scaleEffect(2.2)
                            }.opacity(0.6)
                        }
                    } else {
                        BarMark(
                            x: .value("Day", day.date, unit: .day),
                            y: .value("Mood", 0.5)
                        )
                        .foregroundStyle(AppColors.textSecondary.opacity(0.08))
                        .clipShape(Capsule())
                    }
                }
            }
            .chartYScale(domain: 0...5.5)
            .chartYAxis {
                AxisMarks(values: [1, 2, 3, 4, 5]) { _ in
                    AxisGridLine().foregroundStyle(AppColors.textSecondary.opacity(0.08))
                    AxisValueLabel().foregroundStyle(AppColors.textSecondary.opacity(0.6))
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Mood trend for the last seven days")
            .accessibilityValue(moodChartAccessibilityValue)
        }
    
    
    // MARK: - Line Chart (30 Days & All-Time)

    private var monthlyMoodChart: some View {
        moodLineChart(
            checkIns: viewModel.filteredCheckIns,
            accessibilityLabel: "Mood trend for the last thirty days"
        )
    }

    private var allTimeMoodChart: some View {
        moodLineChart(
            checkIns: viewModel.filteredCheckIns,
            accessibilityLabel: "All-time mood trend"
        )
    }

    private func moodLineChart(checkIns: [CheckIn], accessibilityLabel: String) -> some View {
        Chart {
            ForEach(checkIns.sorted(by: { $0.date < $1.date })) { checkIn in
                AreaMark(
                    x: .value("Date", checkIn.date),
                    y: .value("Mood", checkIn.mood.score)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            AppColors.accentMint.opacity(0.3),
                            AppColors.accentMint.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", checkIn.date),
                    y: .value("Mood", checkIn.mood.score)
                )
                .foregroundStyle(AppColors.accentMint)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", checkIn.date),
                    y: .value("Mood", checkIn.mood.score)
                )
                .foregroundStyle(checkIn.mood.chartColor)
                .symbolSize(40)
            }
        }
        .chartYScale(domain: 0...5.5)
        .chartYAxis {
            AxisMarks(values: [1, 2, 3, 4, 5]) { _ in
                AxisGridLine().foregroundStyle(AppColors.textSecondary.opacity(0.08))
                AxisValueLabel().foregroundStyle(AppColors.textSecondary.opacity(0.6))
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    // MARK: - Daily Averages

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Daily Averages", systemImage: "gauge.with.dots.needle.bottom.0percent")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
            }

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
        .padding(16)
        .background(AppColors.warmSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
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
    // MARK: - Check-In Summary Card

    private var summaryCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous)
                    .fill(AppColors.accentMint.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: "checkmark.seal.fill")
                    .font(.title3)
                    .foregroundStyle(AppColors.accentMint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Total Check-Ins")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textPrimary)

                Text("In selected period")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Spacer()

            Text("\(viewModel.totalCheckIns)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(14)
        .background(AppColors.warmSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Total Check-Ins")
        .accessibilityValue("\(viewModel.totalCheckIns)")
    }

    // MARK: - Insights Card

    private var insightsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Insights", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            if viewModel.insights.isEmpty {
                Text("More check-ins are needed to generate insights.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .padding(.vertical, 4)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.insights, id: \.self) { insight in
                        HStack(alignment: .top, spacing: 10) {
                            Circle()
                                .fill(AppColors.accentYellow)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)

                            Text(insight)
                                .font(.subheadline)
                                .foregroundStyle(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppColors.warmSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }

    // MARK: - Accessibility Helper

    private var moodChartAccessibilityValue: String {
        guard let firstCheckIn = viewModel.filteredCheckIns.first else {
            return "No mood data available"
        }
        let firstMood = firstCheckIn.mood.title

        guard let lastCheckIn = viewModel.filteredCheckIns.last else {
            return "Mood was \(firstMood)"
        }
        let lastMood = lastCheckIn.mood.title

        if firstMood == lastMood {
            return "Mood remained \(lastMood)"
        }
        return "Mood changed from \(firstMood) to \(lastMood)"
    }
}


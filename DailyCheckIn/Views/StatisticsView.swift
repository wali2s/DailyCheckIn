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
        homeViewModel: HomeViewModel,
        activityViewModel: ActivityViewModel
    ) {
        _viewModel = StateObject(
            wrappedValue: StatisticsViewModel(
                homeViewModel: homeViewModel,
                activityViewModel: activityViewModel
            )
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

                    if !viewModel.mostFrequentFactors.isEmpty {
                        frequentFactorsCard
                    }
                    
                    if !viewModel.factorMoodComparisons.isEmpty {
                        factorMoodComparisonCard
                    }

                    if !viewModel.activityMoodComparisons.isEmpty {
                        activityMoodComparisonCard
                    }
                    
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
        VStack(spacing: 0) {
            TabView(selection: $viewModel.selectedMetric) {
                ForEach(StatisticsMetric.allCases) { metric in
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Label(
                                "\(metric.title) Trend",
                                systemImage: metricIcon(for: metric)
                            )
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)

                            Spacer()

                            Text("Swipe for more")
                                .font(.caption)
                                .foregroundStyle(AppColors.textSecondary)
                        }

                        trendContent(for: metric)
                            .frame(height: 210)
                    }
                    .tag(metric)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 245)

            metricPagination
                .padding(.top, 8)
        }
        .padding(16)
        .background(AppColors.warmSurface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.standard,
                style: .continuous
            )
        )
        .shadow(
            color: Color.black.opacity(0.03),
            radius: 8,
            x: 0,
            y: 2
        )
    }
    
    private var metricPagination: some View {
        let metrics = StatisticsMetric.allCases

        return HStack(spacing: 12) {
            Image(systemName: "chevron.left")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.textSecondary)
                .opacity(isFirstMetric ? 0.25 : 0.75)

            HStack(spacing: 6) {
                ForEach(metrics) { metric in
                    Capsule()
                        .fill(
                            metric == viewModel.selectedMetric
                            ? metricTint(for: metric)
                            : AppColors.textSecondary.opacity(0.22)
                        )
                        .frame(
                            width: metric == viewModel.selectedMetric ? 18 : 6,
                            height: 6
                        )
                        .animation(
                            .easeInOut(duration: 0.2),
                            value: viewModel.selectedMetric
                        )
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.textSecondary)
                .opacity(isLastMetric ? 0.25 : 0.75)

            Spacer()

            Text(
                "\(selectedMetricIndex + 1) / \(metrics.count)"
            )
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(AppColors.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Metric page")
        .accessibilityValue(
            "\(selectedMetricIndex + 1) of \(metrics.count)"
        )
    }

    
    private var selectedMetricIndex: Int {
        StatisticsMetric.allCases.firstIndex(
            of: viewModel.selectedMetric
        ) ?? 0
    }

    private var isFirstMetric: Bool {
        selectedMetricIndex == 0
    }

    private var isLastMetric: Bool {
        selectedMetricIndex
            == StatisticsMetric.allCases.count - 1
    }
    
    
    @ViewBuilder
    private func trendContent(
        for metric: StatisticsMetric
    ) -> some View {
        if metric == .mood {
            switch viewModel.selectedPeriod {
            case .last7Days:
                weeklyMoodChart

            case .last30Days:
                monthlyMoodChart

            case .allTime:
                allTimeMoodChart
            }
        } else {
            metricLineChart(
                checkIns: viewModel.filteredCheckIns,
                metric: metric,
                tint: metricTint(for: metric),
                accessibilityLabel: "\(metric.title) trend"
            )
        }
    }
    
    private func metricIcon(
        for metric: StatisticsMetric
    ) -> String {
        switch metric {
        case .mood:
            return "face.smiling"
        case .energy:
            return "bolt.fill"
        case .stress:
            return "waveform.path.ecg"
        case .focus:
            return "brain.head.profile"
        case .socialBattery:
            return "battery.100.bolt"
        case .physicalComfort:
            return "figure.walk"
        }
    }

    private func metricTint(
        for metric: StatisticsMetric
    ) -> Color {
        switch metric {
        case .mood, .physicalComfort:
            return AppColors.accentMint
        case .energy, .socialBattery:
            return AppColors.accentYellow
        case .stress:
            return AppColors.accentPink
        case .focus:
            return AppColors.accentBlue
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
    
    private func metricLineChart(
        checkIns: [CheckIn],
        metric: StatisticsMetric,
        tint: Color,
        accessibilityLabel: String
    ) -> some View {
        Chart {
            ForEach(
                checkIns.sorted(by: { $0.date < $1.date })
            ) { checkIn in
                let metricValue = metric.value(for: checkIn)

                AreaMark(
                    x: .value("Date", checkIn.date),
                    y: .value("Value", metricValue)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            tint.opacity(0.28),
                            tint.opacity(0.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", checkIn.date),
                    y: .value("Value", metricValue)
                )
                .foregroundStyle(tint)
                .lineStyle(
                    StrokeStyle(
                        lineWidth: 2.5,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", checkIn.date),
                    y: .value("Value", metricValue)
                )
                .foregroundStyle(tint)
                .symbolSize(40)
            }
        }
        .chartYScale(domain: 0...5.5)
        .chartYAxis {
            AxisMarks(values: [1, 2, 3, 4, 5]) { _ in
                AxisGridLine()
                    .foregroundStyle(
                        AppColors.textSecondary.opacity(0.08)
                    )

                AxisValueLabel()
                    .foregroundStyle(
                        AppColors.textSecondary.opacity(0.6)
                    )
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                AxisValueLabel(
                    format: .dateTime.day().month(.abbreviated)
                )
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
            MetricSummaryRow(
                title: "Average Focus",
                value: viewModel.formattedAverage(
                    viewModel.averageFocus
                ),
                progress: viewModel.averageFocus,
                tint: AppColors.accentBlue,
                systemImage: "brain.head.profile"
            )

            MetricSummaryRow(
                title: "Average Social Battery",
                value: viewModel.formattedAverage(
                    viewModel.averageSocialBattery
                ),
                progress: viewModel.averageSocialBattery,
                tint: AppColors.accentYellow,
                systemImage: "battery.100.bolt"
            )

            MetricSummaryRow(
                title: "Average Physical Tension",
                value: viewModel.formattedAverage(
                    viewModel.averagePhysicalTension
                ),
                progress: viewModel.averagePhysicalTension,
                tint: AppColors.accentPink,
                systemImage: "figure.walk"
            )
        }
        .padding(16)
        .background(AppColors.warmSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
    }
    
    //MARK: - FREQUENTFACTORSCARD
    
    private var frequentFactorsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(
                    "Most Frequent Factors",
                    systemImage: "tag.fill"
                )
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text("Top 3")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.primaryAction)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.warmCanvas)
                    .clipShape(Capsule())
            }

            Text(
                "Based on \(viewModel.totalCheckIns) check-ins in this period."
            )
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)

            VStack(spacing: 10) {
                ForEach(
                    Array(
                        viewModel.mostFrequentFactors.enumerated()
                    ),
                    id: \.element.id
                ) { index, factor in
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(width: 18)

                        ZStack {
                            Circle()
                                .fill(AppColors.accentMint.opacity(0.16))
                                .frame(width: 36, height: 36)

                            Image(systemName: factor.systemImage)
                                .font(.subheadline)
                                .foregroundStyle(AppColors.accentMint)
                        }

                        Text(factor.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColors.textPrimary)

                        Spacer()

                        Text("\(factor.count)x")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(AppColors.primaryAction)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 6)
                            .background(AppColors.warmCanvas)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(AppColors.warmSurface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.standard,
                style: .continuous
            )
        )
        .shadow(
            color: Color.black.opacity(0.03),
            radius: 8,
            x: 0,
            y: 2
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Most frequent factors")
    }
    
    //MARK: - FactorMoodComparisonCard
    
    private var factorMoodComparisonCard: some View {
        let comparison = viewModel.factorMoodComparisons[0]
        let isPositive = comparison.moodDifference >= 0
        let tint = isPositive
            ? AppColors.accentMint
            : AppColors.accentPink

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(
                    "Mood Pattern",
                    systemImage: "chart.bar.xaxis"
                )
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text("\(comparison.occurrenceCount) days")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textSecondary)
            }

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.16))
                        .frame(width: 42, height: 42)

                    Image(systemName: comparison.systemImage)
                        .foregroundStyle(tint)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(comparison.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(
                        isPositive
                        ? "appeared alongside a higher mood"
                        : "appeared alongside a lower mood"
                    )
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Text(
                    formattedMoodDifference(comparison.moodDifference)
                )
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(tint)
            }

            Text(
                "With this factor, your average mood was "
                + "\(formattedScore(comparison.averageMoodWithFactor))/5 "
                + "compared with "
                + "\(formattedScore(comparison.averageMoodWithoutFactor))/5 "
                + "on other days."
            )
            .font(.subheadline)
            .foregroundStyle(AppColors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)

            Text(
                "This is a data pattern, not proof of a cause."
            )
            .font(.caption2)
            .foregroundStyle(AppColors.textSecondary.opacity(0.8))
        }
        .padding(16)
        .background(AppColors.warmSurface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.standard,
                style: .continuous
            )
        )
        .shadow(
            color: Color.black.opacity(0.03),
            radius: 8,
            x: 0,
            y: 2
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Mood pattern")
    }

    private var activityMoodComparisonCard: some View {
        let comparison = viewModel.activityMoodComparisons[0]
        let isPositive = comparison.moodDifference >= 0
        let tint = isPositive
            ? AppColors.accentMint
            : AppColors.accentPink

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(
                    "Activity Pattern",
                    systemImage: "figure.walk"
                )
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text("\(comparison.completedCheckInCount) days")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.textSecondary)
            }

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.16))
                        .frame(width: 42, height: 42)

                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(tint)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(comparison.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(
                        isPositive
                        ? "was completed on days with higher mood"
                        : "was completed on days with lower mood"
                    )
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
                }

                Spacer()

                Text(
                    formattedMoodDifference(
                        comparison.moodDifference
                    )
                )
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(tint)
            }

            Text(
                "On days you completed this activity, your average "
                + "mood was "
                + "\(formattedScore(comparison.averageMoodOnCompletedDays))/5 "
                + "compared with "
                + "\(formattedScore(comparison.averageMoodOnOtherDays))/5 "
                + "on other days."
            )
            .font(.subheadline)
            .foregroundStyle(AppColors.textSecondary)

            Text(
                "This is a data pattern, not proof of a cause."
            )
            .font(.caption2)
            .foregroundStyle(AppColors.textSecondary.opacity(0.8))
        }
        .padding(16)
        .background(AppColors.warmSurface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.standard,
                style: .continuous
            )
        )
        .shadow(
            color: Color.black.opacity(0.03),
            radius: 8,
            x: 0,
            y: 2
        )
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
    
    private func formattedScore(_ score: Double) -> String {
        String(format: "%.1f", score)
    }

    private func formattedMoodDifference(
        _ difference: Double
    ) -> String {
        let sign = difference > 0 ? "+" : ""
        return "\(sign)\(formattedScore(difference))"
    }
}


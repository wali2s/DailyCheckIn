//
//  StatisticsViewModel.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import Foundation
import Combine


enum StatisticsMetric: String, CaseIterable, Identifiable {
    case mood
    case energy
    case stress
    case focus
    case socialBattery
    case physicalComfort

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .mood:
            return "Mood"
        case .energy:
            return "Energy"
        case .stress:
            return "Stress"
        case .focus:
            return "Focus"
        case .socialBattery:
            return "Social Battery"
        case .physicalComfort:
            return "Physical Comfort"
        }
    }

    func value(for checkIn: CheckIn) -> Double {
        switch self {
        case .mood:
            return checkIn.mood.score

        case .energy:
            return Double(checkIn.energyLevel)

        case .stress:
            return Double(checkIn.stressLevel)

        case .focus:
            return checkIn.focusLevel

        case .socialBattery:
            return checkIn.socialBattery

        case .physicalComfort:
            return checkIn.physicalTension
        }
    }
}

struct FactorStatistic: Identifiable, Equatable {
    let id: String
    let title: String
    let systemImage: String
    let count: Int
}

struct FactorMoodComparison: Identifiable, Equatable {
    let id: String
    let title: String
    let systemImage: String
    let occurrenceCount: Int
    let averageMoodWithFactor: Double
    let averageMoodWithoutFactor: Double

    var moodDifference: Double {
        averageMoodWithFactor - averageMoodWithoutFactor
    }
}

struct ActivityMoodComparison: Identifiable, Equatable {
    let id: UUID
    let title: String
    let completedCheckInCount: Int
    let averageMoodOnCompletedDays: Double
    let averageMoodOnOtherDays: Double

    var moodDifference: Double {
        averageMoodOnCompletedDays
            - averageMoodOnOtherDays
    }
}

enum StatisticsPeriod: String, CaseIterable, Identifiable {
    
    case last7Days
    case last30Days
    case allTime
   
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .last7Days:
            return "Last 7 Days"
        case .last30Days:
            return "Last 30 Days"
        case .allTime:
            return "All Time"
      
        }
    }
    
    var numberOfDays: Int? {
        switch self {
        case .last7Days:
            return 7
        case .last30Days:
            return 30
        case .allTime:
            return nil
       
        }
    }
}

final class StatisticsViewModel: ObservableObject {
    
    @Published private(set) var checkIns: [CheckIn] = []
    @Published var selectedSpace: JournalSpace = .personal
    @Published var selectedPeriod: StatisticsPeriod = .last7Days
    @Published private(set) var totalCheckIns: Int = 0
    @Published var selectedMetric: StatisticsMetric = .mood
    
    @Published private(set) var activities: [Activity] = []
    @Published private(set) var activityCompletions: [ActivityCompletion] = []
    
    private let evaluator = CheckInEvaluator()
    
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    
    init(
        homeViewModel: HomeViewModel,
        activityViewModel: ActivityViewModel? = nil
    ) {
        self.checkIns = homeViewModel.checkIns
        self.totalCheckIns = filteredCheckIns.count
        
        if let activityViewModel {
            self.activities = activityViewModel.activities
            self.activityCompletions = activityViewModel.completions

            activityViewModel.$activities
                .receive(on: RunLoop.main)
                .assign(to: &$activities)

            activityViewModel.$completions
                .receive(on: RunLoop.main)
                .assign(to: &$activityCompletions)
        }

        homeViewModel.$checkIns
            .receive(on: RunLoop.main)
            .sink { [weak self] checkIns in
                self?.checkIns = checkIns
                self?.totalCheckIns = self?.filteredCheckIns.count ?? 0
            }
            .store(
                in: &cancellables
            )

        $selectedSpace
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.totalCheckIns = self?.filteredCheckIns.count ?? 0
            }
            .store(
                in: &cancellables
            )

        $selectedPeriod
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.totalCheckIns = self?.filteredCheckIns.count ?? 0
            }
            .store(
                in: &cancellables
            )
    }
    
    var filteredCheckIns: [CheckIn] {
        let periodFilteredCheckIns: [CheckIn]
        
        if let numberOfDays = selectedPeriod.numberOfDays {
            let today = calendar.startOfDay(
                for: Date()
            )
            
            guard let startDate = calendar.date(
                byAdding: .day,
                value: -(numberOfDays - 1),
                to: today
            ) else {
                return []
            }
            
            periodFilteredCheckIns = checkIns.filter {
                $0.date >= startDate &&
                $0.date <= Date()
            }
        } else {
            periodFilteredCheckIns = checkIns
        }
        
        return filterBySpace(
            periodFilteredCheckIns
        )
        .sorted {
            $0.date < $1.date
        }
    }
    
    var averageMood: Double {
        average(
            filteredCheckIns.map {
                $0.mood.score
            }
        )
    }
    
    var averageEnergy: Double {
        average(
            filteredCheckIns.map {
                Double($0.energyLevel)
            }
        )
    }
    
    var averageStress: Double {
        average(
            filteredCheckIns.map {
                Double($0.stressLevel)
            }
        )
    }
    
    var averageFocus: Double {
        average(
            filteredCheckIns.map {
                $0.focusLevel
            }
        )
    }

    var averageSocialBattery: Double {
        average(
            filteredCheckIns.map {
                $0.socialBattery
            }
        )
    }

    var averagePhysicalTension: Double {
        average(
            filteredCheckIns.map {
                $0.physicalTension
            }
        )
    }
    
    var factorMoodComparisons: [FactorMoodComparison] {
        switch selectedSpace {
        case .personal:
            return personalFactorMoodComparisons()

        case .professional:
            return professionalFactorMoodComparisons()
        }
    }
    
    
    
    var activityMoodComparisons: [ActivityMoodComparison] {
        activities.compactMap { activity in
            let completedDays = Set(
                activityCompletions
                    .filter { completion in
                        completion.ActivityID == activity.id
                    }
                    .map { completion in
                        calendar.startOfDay(for: completion.date)
                    }
            )

            let completedDayCheckIns = filteredCheckIns.filter {
                completedDays.contains(
                    calendar.startOfDay(for: $0.date)
                )
            }

            let otherDayCheckIns = filteredCheckIns.filter {
                !completedDays.contains(
                    calendar.startOfDay(for: $0.date)
                )
            }

            guard
                completedDayCheckIns.count >= 2,
                otherDayCheckIns.count >= 2
            else {
                return nil
            }

            let completedMood = completedDayCheckIns
                .map { $0.mood.score }
                .reduce(0, +)
                / Double(completedDayCheckIns.count)

            let otherMood = otherDayCheckIns
                .map { $0.mood.score }
                .reduce(0, +)
                / Double(otherDayCheckIns.count)

            return ActivityMoodComparison(
                id: activity.id,
                title: activity.title,
                completedCheckInCount: completedDayCheckIns.count,
                averageMoodOnCompletedDays: completedMood,
                averageMoodOnOtherDays: otherMood
            )
        }
        .sorted {
            abs($0.moodDifference) > abs($1.moodDifference)
        }
    }
    
    private func personalFactorMoodComparisons() -> [FactorMoodComparison] {
        let factors = Set(
            filteredCheckIns.flatMap(\.personalFactors)
        )

        return factors.compactMap { factor in
            let entriesWithFactor = filteredCheckIns.filter {
                $0.personalFactors.contains(factor)
            }

            let entriesWithoutFactor = filteredCheckIns.filter {
                !$0.personalFactors.contains(factor)
            }

            guard entriesWithFactor.count >= 3,
                  entriesWithoutFactor.count >= 3 else {
                return nil
            }

            return FactorMoodComparison(
                id: factor.rawValue,
                title: factor.title,
                systemImage: factor.systemImage,
                occurrenceCount: entriesWithFactor.count,
                averageMoodWithFactor: average(
                    entriesWithFactor.map(\.mood.score)
                ),
                averageMoodWithoutFactor: average(
                    entriesWithoutFactor.map(\.mood.score)
                )
            )
        }
        .sorted {
            abs($0.moodDifference) > abs($1.moodDifference)
        }
    }

    private func professionalFactorMoodComparisons() -> [FactorMoodComparison] {
        let factors = Set(
            filteredCheckIns.flatMap(\.professionalFactors)
        )

        return factors.compactMap { factor in
            let entriesWithFactor = filteredCheckIns.filter {
                $0.professionalFactors.contains(factor)
            }

            let entriesWithoutFactor = filteredCheckIns.filter {
                !$0.professionalFactors.contains(factor)
            }

            guard entriesWithFactor.count >= 3,
                  entriesWithoutFactor.count >= 3 else {
                return nil
            }

            return FactorMoodComparison(
                id: factor.rawValue,
                title: factor.title,
                systemImage: factor.systemImage,
                occurrenceCount: entriesWithFactor.count,
                averageMoodWithFactor: average(
                    entriesWithFactor.map(\.mood.score)
                ),
                averageMoodWithoutFactor: average(
                    entriesWithoutFactor.map(\.mood.score)
                )
            )
        }
        .sorted {
            abs($0.moodDifference) > abs($1.moodDifference)
        }
    }
    
    var averageMoodText: String {
        guard !filteredCheckIns.isEmpty else {
            return "No mood data yet"
        }
        
        return formattedAverage(
            averageMood
        )
    }
    
    var hasEnoughDataForInsights: Bool {
        filteredCheckIns.count >= 3
    }
    
    var insights: [String] {
        guard hasEnoughDataForInsights else {
            return []
        }
        
        var generatedInsights: [String] = []
        
        if averageMood >= 4 {
            generatedInsights.append(
                "Your average mood is positive."
            )
        } else if averageMood <= 2 {
            generatedInsights.append(
                "Your average mood has been low."
            )
        } else {
            generatedInsights.append(
                "Your average mood has been balanced."
            )
        }
        
        if averageStress >= 4 {
            generatedInsights.append(
                "Your stress level has been relatively high."
            )
        } else if averageStress <= 2 {
            generatedInsights.append(
                "Your stress level has been relatively low."
            )
        } else {
            generatedInsights.append(
                "Your stress level has been moderate."
            )
        }
        
        if averageEnergy >= 4 {
            generatedInsights.append(
                "Your energy level has been strong."
            )
        } else if averageEnergy <= 2 {
            generatedInsights.append(
                "Your energy level has been low."
            )
        } else {
            generatedInsights.append(
                "Your energy level has been stable."
            )
        }
        
        return generatedInsights
    }
    
    func formattedAverage(
        _ value: Double
    ) -> String {
        guard !filteredCheckIns.isEmpty else {
            return "-"
        }
        
        return String(
            format: "%.1f / 5",
            value
        )
    }
    
    private func average(
        _ values: [Double]
    ) -> Double {
        guard !values.isEmpty else {
            return 0
        }
        
        return values.reduce(0, +)
            / Double(values.count)
    }
    
    private func filterBySpace(
        _ checkIns: [CheckIn]
    ) -> [CheckIn] {
        checkIns.filter {
            $0.space == selectedSpace
        }
    }
    var mostFrequentFactors: [FactorStatistic] {
        switch selectedSpace {
        case .personal:
            return personalFactorStatistics()

        case .professional:
            return professionalFactorStatistics()
        }
    }

    private func personalFactorStatistics() -> [FactorStatistic] {
        let counts = Dictionary(
            grouping: filteredCheckIns.flatMap(\.personalFactors),
            by: \.self
        )

        return counts
            .map { factor, entries in
                FactorStatistic(
                    id: factor.rawValue,
                    title: factor.title,
                    systemImage: factor.systemImage,
                    count: entries.count
                )
            }
            .sorted {
                if $0.count == $1.count {
                    return $0.title < $1.title
                }

                return $0.count > $1.count
            }
            .prefix(3)
            .map { $0 }
    }

    private func professionalFactorStatistics() -> [FactorStatistic] {
        let counts = Dictionary(
            grouping: filteredCheckIns.flatMap(\.professionalFactors),
            by: \.self
        )

        return counts
            .map { factor, entries in
                FactorStatistic(
                    id: factor.rawValue,
                    title: factor.title,
                    systemImage: factor.systemImage,
                    count: entries.count
                )
            }
            .sorted {
                if $0.count == $1.count {
                    return $0.title < $1.title
                }

                return $0.count > $1.count
            }
            .prefix(3)
            .map { $0 }
    }
    
    var averageDailyScore: Double {
        guard !filteredCheckIns.isEmpty else {
            return 0
        }
        
        let total = filteredCheckIns
            .map {
                evaluator.evaluate($0).overallScore
            }
            .reduce(0, +)
        
        return total / Double(filteredCheckIns.count)
    }
    
    var formattedAverageDailyScore: String {
        "\(Int((averageDailyScore * 20).rounded()))%"
    }
}

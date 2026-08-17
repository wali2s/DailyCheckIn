//
//  StatisticsViewModel.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import Foundation
import Combine

enum StatisticsPeriod: String, CaseIterable, Identifiable {
    
    case allTime
    case last7Days
    case last30Days
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .allTime:
            return "All Time"
        case .last7Days:
            return "Last 7 Days"
        case .last30Days:
            return "Last 30 Days"
        }
    }
    
    var numberOfDays: Int? {
        switch self {
        case .allTime:
            return nil
        case .last7Days:
            return 7
        case .last30Days:
            return 30
        }
    }
}

final class StatisticsViewModel: ObservableObject {
    
    @Published private(set) var checkIns: [CheckIn] = []
    @Published var selectedSpace: JournalSpace = .personal
    @Published var selectedPeriod: StatisticsPeriod = .allTime
    @Published private(set) var totalCheckIns: Int = 0
    
    private let evaluator = CheckInEvaluator()
    
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    
    init(
        homeViewModel: HomeViewModel
    ) {
        self.checkIns = homeViewModel.checkIns
        self.totalCheckIns = filteredCheckIns.count

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
    
    var averageMoodText: String {
        guard !filteredCheckIns.isEmpty else {
            return "No mood data yet"
        }
        
        return formattedAverage(
            averageMood
        )
    }
    
    var insights: [String] {
        guard !filteredCheckIns.isEmpty else {
            return [
                "Create some check-ins to see personal insights."
            ]
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

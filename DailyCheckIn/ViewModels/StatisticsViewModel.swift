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
    @Published var selectedSpace: JournalSpace?
    @Published var selectedPeriod: StatisticsPeriod = .allTime
    
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    
    init(homeViewModel: HomeViewModel) {
        self.checkIns = homeViewModel.checkIns
        
        homeViewModel.$checkIns
            .receive(on: RunLoop.main)
            .sink { [weak self] checkIns in
                self?.checkIns = checkIns
            }
            .store(in: &cancellables)
    }
    
    var filteredCheckIns: [CheckIn] {
        let periodFilteredCheckIns: [CheckIn]
        
        guard let numberOfDays = selectedPeriod.numberOfDays else {
            periodFilteredCheckIns = checkIns
            return filterBySpace(
                periodFilteredCheckIns
            )
        }
        
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
        
        return filterBySpace(
            periodFilteredCheckIns
        )
    }
    
    var totalCheckIns: Int { checkIns.count }
    
    var averageMood: Double {
        average(filteredCheckIns.map {Double($0.mood.rawValue)})
    }
    
    var averageEnergy: Double {
        average(filteredCheckIns
            .map {Double($0.energyLevel)}
        )
    }
    
    var averageStress: Double {
        average(filteredCheckIns
            .map {Double($0.stressLevel)}
        )
    }
    
    private func average(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        
        return values.reduce(0, +) / Double(values.count)
    }
    
     func formattedAverage(_ value: Double) -> String {
        guard totalCheckIns > 0 else { return "-" }
        
        return String(format: "%.1f/5", value)
    }
    
    private func filterBySpace(
        _ checkIns: [CheckIn]
    ) -> [CheckIn] {
        guard let selectedSpace else {
            return checkIns
        }
        
        return checkIns.filter {
            $0.space == selectedSpace
        }
    }
}

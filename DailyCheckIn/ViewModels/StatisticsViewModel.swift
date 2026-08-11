//
//  StatisticsViewModel.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import Foundation
import Combine

final class StatisticsViewModel: ObservableObject {
    
    @Published private(set) var checkIns: [CheckIn] = []
    @Published var selectedSpace: JournalSpace?
    
    private var cancellables = Set<AnyCancellable>()
    
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
        guard let selectedSpace else { return checkIns }
        
        return checkIns.filter { $0.space == selectedSpace }
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
}

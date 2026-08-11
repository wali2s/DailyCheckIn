//
//  ContentView.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel: HomeViewModel
    @State private var selectedTab = 0
    
    init(
        storageService: CheckInStorageService = UserDefaultsCheckInStorageService()
    ) {
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(
                storageService: storageService
            )
        )
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(viewModel: viewModel)
            }
            .tabItem {
                Label(
                    "Home",
                    systemImage: "house.fill"
                )
            }
            .tag(0)
            
            NavigationStack {
                HistoryView(viewModel: viewModel)
            }
            .tabItem {
                Label(
                    "History",
                    systemImage: "clock.arrow.circlepath"
                )
            }
            .tag(1)
            
            NavigationStack {
                StatisticsView(
                    homeViewModel: viewModel
                )
            }
            .tabItem {
                Label(
                    "Statistics",
                    systemImage: "chart.bar.fill"
                )
            }
            .tag(2)
        }
    }
}

#Preview("App - Sample Data") {
    ContentView(
        storageService: PreviewCheckInStorageService()
    )
}

final class PreviewCheckInStorageService: CheckInStorageService {
    
    private var previewCheckIns: [CheckIn] = [
        CheckIn(
            date: Date(),
            space: .personal,
            mood: .good,
            energyLevel: 4,
            stressLevel: 2,
            note: "Had a calm and productive day.",
            tags: ["Calm", "Productive"]
        ),
        CheckIn(
            date: Date(),
            space: .professional,
            mood: .neutral,
            energyLevel: 3,
            stressLevel: 4,
            note: "Worked on the Daily Check-In app.",
            tags: ["Development"]
        ),
        CheckIn(
            date: Date().addingTimeInterval(-86_400),
            space: .personal,
            mood: .veryGood,
            energyLevel: 5,
            stressLevel: 1,
            note: "Spent time with my family.",
            tags: ["Family"]
        )
    ]
    
    func loadCheckIns() -> [CheckIn] {
        previewCheckIns
    }
    
    func saveCheckIns(_ checkIns: [CheckIn]) {
        previewCheckIns = checkIns
    }
}

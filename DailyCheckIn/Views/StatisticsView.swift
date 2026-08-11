//
//  StatisticsView.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import SwiftUI

struct StatisticsView: View {
    
    @StateObject private var viewModel: StatisticsViewModel
    
    init (homeViewModel: HomeViewModel) {
        _viewModel = StateObject( wrappedValue: StatisticsViewModel(homeViewModel: homeViewModel))
    }
    var body: some View {
        List {
            Section {
                Picker(
                    "Space",
                    selection: $viewModel.selectedSpace
                ) {
                    Text("All")
                        .tag(nil as JournalSpace?)
                    
                    ForEach(JournalSpace.allCases) { space in
                        Text(space.title).tag(Optional(space))
                    }
                }.pickerStyle(.segmented)
            }
            
            Section("Overview") {
                StatisticsRow(title: "Total Check-Ins", value: "\(viewModel.totalCheckIns)", systemImage: "checkmark.circle.fill")
                
                StatisticsRow(
                    title: "Average Mood",
                    value: viewModel.formattedAverage(viewModel      .averageMood),
                    
                    systemImage: "face.smiling")
                
                StatisticsRow(
                    title: "Average Energy",
                    value: viewModel.formattedAverage(viewModel.averageEnergy),
                    systemImage: "bolt.fill")
                
                StatisticsRow(
                    title: "Average Stress",
                    value: viewModel.formattedAverage(viewModel.averageStress),
                    systemImage: "waveform.path.ecg")
                
                if viewModel.totalCheckIns == 0 {
                    Section {
                        Text("No check-ins to see your statistics.")
                            .foregroundStyle(.secondary)
                            
                    }
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

private struct StatisticsRow: View {
    let title: String
    let value: String
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.blue)
                .frame(width:24)
            
            Text(title)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview("Statistics - Sample Data") {
    NavigationStack {
        StatisticsView(
            homeViewModel: HomeViewModel(
                storageService: StatisticsPreviewStorageService()
            )
        )
    }
}

final class StatisticsPreviewStorageService: CheckInStorageService {
    
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
            date: Date().addingTimeInterval(-86_400),
            space: .personal,
            mood: .veryGood,
            energyLevel: 5,
            stressLevel: 1,
            note: "Spent time with my family.",
            tags: ["Family"]
        ),
        CheckIn(
            date: Date(),
            space: .professional,
            mood: .neutral,
            energyLevel: 3,
            stressLevel: 4,
            note: "Worked on the Daily Check-In app.",
            tags: ["Development"]
        )
    ]
    
    func loadCheckIns() -> [CheckIn] {
        previewCheckIns
    }
    
    func saveCheckIns(_ checkIns: [CheckIn]) {
        previewCheckIns = checkIns
    }
}

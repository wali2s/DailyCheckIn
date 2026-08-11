//
//  ContentView.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import SwiftUI

struct ContentView: View {
    
    
        @StateObject private var viewModel: HomeViewModel
        @State private var selectedSpace: JournalSpace?
        
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
       NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    
                    ForEach(JournalSpace.allCases) { space in
                        SpaceCheckInCard(
                            space: space,
                            checkIn: viewModel.checkIn(for: space),
                            onCheckIn: {
                                selectedSpace = space
                            }
                        )
                    }
                }
                .padding()
           }
            .navigationTitle("Daily Check-In")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        HistoryView(viewModel: viewModel)
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                    .accessibilityLabel("Open history")
                }
            }
            .sheet(item: $selectedSpace) { space in
                CheckInView(
                    space: space,
                    existingCheckIn: viewModel.checkIn(for: space)
                ) { newCheckIn in
                    viewModel.addCheckIn(newCheckIn)
                }
            }
            
        }
    }
    
    private var headerSection: some View {
        VStack (alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(Date.now, style: .date)
                .foregroundStyle(.secondary)
            
            Text("Take a moment to check in with yourself.")
                .foregroundStyle(.secondary)
        }
    }
    
    private struct SpaceCheckInCard: View {
        let space: JournalSpace
        let checkIn: CheckIn?
        var onCheckIn: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: space.iconName)
                        .font(.title2)
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(space.title)
                            .font(.headline)
                        
                        Text(space.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    
                }
                Divider()
                
                if let checkIn {
                    HStack {
                        Text(checkIn.mood.emoji)
                            .font(.largeTitle)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(checkIn.mood.title)
                                .font(.headline)
                            
                            Text(checkIn.note)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                    HStack {
                        Label("Energy \(checkIn.energyLevel)/ 5", systemImage: "bolt.fill")
                        Spacer()
                        Label("Stress \(checkIn.stressLevel)/ 5", systemImage: "waveform.path.ecg")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    Button("Edit Check-In") {
                        onCheckIn()
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("createCheckInButton.\(space.rawValue)")
                } else {
                    Text("No check-in yet")
                        .foregroundStyle(.secondary)
                    
                    Text("Take a moment to reflect on your day.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Button("Create Check-In") {
                        onCheckIn()
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("createCheckInButton.\(space.rawValue)")
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

final class PreviewCheckInStorageService: CheckInStorageService {
    
    private var previewCheckIns: [CheckIn] = [
        CheckIn(
            space: .personal,
            mood: .good,
            energyLevel: 4,
            stressLevel: 2,
            note: "Had a calm and productive day.",
            tags: ["Calm", "Productive"]
        ),
        CheckIn(
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

#Preview("Home Screen") {
    ContentView(
        storageService: PreviewCheckInStorageService()
    )
}

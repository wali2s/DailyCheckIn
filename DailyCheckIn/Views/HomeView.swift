//
//  HomeView.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var selectedSpace: JournalSpace?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                StreakCard(
                       streak: viewModel.currentStreak
                   )
                
                DailyProgressCard(
                    completedSpaces: viewModel.completedSpacesToday,
                    totalSpaces: viewModel.totalSpaces,
                    progress: viewModel.dailyCompletionProgress,
                    message: viewModel.dailyCompletionMessage
                )
                
                ForEach(JournalSpace.allCases) { space in
                    SpaceCheckInCard(
                        space: space,
                        checkIn: viewModel.checkIn(
                            for: space
                        ),
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
            ToolbarItem(
                placement: .navigationBarTrailing
            ) {
                Text(Date.now, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(item: $selectedSpace) { space in
            CheckInView(
                space: space,
                existingCheckIn: viewModel.checkIn(
                    for: space
                )
            ) { newCheckIn in
                viewModel.addCheckIn(newCheckIn)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(
                "Take a moment to check in with yourself."
            )
            .foregroundStyle(.secondary)
        }
    }
    
}

private struct DailyProgressCard: View {
    
    let completedSpaces: Int
    let totalSpaces: Int
    let progress: Double
    let message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                
                Text("Today's Progress")
                    .font(.headline)
                
                Spacer()
                
                Text("\(completedSpaces)/\(totalSpaces)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                ProgressView(value: progress, total: 1.0)
                    .tint(.green)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(
                Color.green.opacity(0.10)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20
                )
            )
        }
    }
}

private struct StreakCard: View {
    
    let streak: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Streak")
                    .font(.headline)
                
                if streak == 0 {
                    Text("Start your streak today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if streak == 1 {
                    Text("1 day")
                        .font(.title3)
                        .fontWeight(.semibold)
                } else {
                    Text("\(streak) days")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    .orange.opacity(0.2),
                    .yellow.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
    }
}

private struct SpaceCheckInCard: View {
    
    let space: JournalSpace
    let checkIn: CheckIn?
    let onCheckIn: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            
            Divider()
            
            if let checkIn {
                existingCheckInContent(checkIn)
            } else {
                emptyCheckInContent
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
    }
    
    private var header: some View {
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
    }
    
    private func existingCheckInContent(
        _ checkIn: CheckIn
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(checkIn.mood.emoji)
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(checkIn.mood.title)
                        .font(.headline)
                    
                    if checkIn.note.isEmpty {
                        Text("No note added.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(checkIn.note)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            
            HStack {
                Label(
                    "Energy \(checkIn.energyLevel)/5",
                    systemImage: "bolt.fill"
                )
                
                Spacer()
                
                Label(
                    "Stress \(checkIn.stressLevel)/5",
                    systemImage: "waveform.path.ecg"
                )
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            
            Button("Edit Check-In") {
                onCheckIn()
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var emptyCheckInContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("No check-in yet")
                .foregroundStyle(.secondary)
            
            Text(
                "Take a moment to reflect on your day."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            Button("Create Check-In") {
                onCheckIn()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier(
                "createCheckInButton.\(space.rawValue)"
            )
        }
    }
}



#Preview("Home - Sample Data") {
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(
                storageService: PreviewCheckInStorageService()
            )
        )
    }
}

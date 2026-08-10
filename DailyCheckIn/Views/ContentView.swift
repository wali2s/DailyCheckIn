//
//  ContentView.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
       NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    
                    ForEach(JournalSpace.allCases) { space in
                        SpaceCheckInCard(space: space, checkIn: viewModel.checkIn(for: space))
                    }
                }
                .padding()
           }
            .navigationTitle("Daily Check-In")
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
                            
                            Text(checkIn.notes)
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
                } else {
                    Text("No check-in yet")
                        .foregroundStyle(.secondary)
                    
                    Text("Take a moment to reflect on your day.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

#Preview {
    ContentView()
}

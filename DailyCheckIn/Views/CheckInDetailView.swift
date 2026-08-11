//
//  CheckInDetailView.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import SwiftUI

struct CheckInDetailView: View {
    
    let checkIn: CheckIn
    let onEdit: () -> Void
    
    init(
        checkIn: CheckIn,
        onEdit: @escaping () -> Void = {}
    ) {
        self.checkIn = checkIn
        self.onEdit = onEdit
    }
    
    var body: some View {
        List {
            Section("Overview") {
                DetailRow(
                    title: "Space",
                    value: checkIn.space.title,
                    systemImage: checkIn.space.iconName
                )
                
                DetailRow(
                    title: "Date",
                    value: checkIn.date.formatted(
                        date: .long,
                        time: .shortened
                    ),
                    systemImage: "calendar"
                )
                
                DetailRow(
                    title: "Mood",
                    value: "\(checkIn.mood.emoji) \(checkIn.mood.title)",
                    systemImage: "face.smiling"
                )
            }
            
            Section("Daily Metrics") {
                DetailRow(
                    title: "Energy",
                    value: "\(checkIn.energyLevel)/5",
                    systemImage: "bolt.fill"
                )
                
                DetailRow(
                    title: "Stress",
                    value: "\(checkIn.stressLevel)/5",
                    systemImage: "waveform.path.ecg"
                )
            }
            
            Section("Note") {
                if checkIn.note.isEmpty {
                    Text("No note added.")
                        .foregroundStyle(.secondary)
                } else {
                    Text(checkIn.note)
                }
            }
            
            if !checkIn.tags.isEmpty {
                Section("Tags") {
                    ForEach(
                        checkIn.tags,
                        id: \.self
                    ) { tag in
                        Label(
                            tag,
                            systemImage: "tag.fill"
                        )
                    }
                }
            }
        }
        .navigationTitle("Check-In Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(
                placement: .navigationBarTrailing
            ) {
                Button("Edit") {
                    onEdit()
                }
            }
        }
    }
}

private struct DetailRow: View {
    
    let title: String
    let value: String
    let systemImage: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            Text(title)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview("Check-In Details") {
    NavigationStack {
        CheckInDetailView(
            checkIn: CheckIn(
                space: .professional,
                mood: .good,
                energyLevel: 4,
                stressLevel: 2,
                note: "Worked on the Daily Check-In app.",
                tags: [
                    "Development",
                    "Focus"
                ]
            )
        )
    }
}

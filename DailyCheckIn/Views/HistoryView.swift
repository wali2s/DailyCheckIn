//
//  HistoryView.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import SwiftUI

struct HistoryView: View {
    
    @ObservedObject var viewModel: HomeViewModel
    @State private var selectedSpace: JournalSpace?
    @State private var searchText = ""
    @State private var selectedCheckIn: CheckIn?
    
    private var filteredCheckIns: [CheckIn] {
        let spaceFilteredCheckIns: [CheckIn]
        
        if let selectedSpace {
            spaceFilteredCheckIns = viewModel.checkIns.filter {
                $0.space == selectedSpace
            }
        } else {
            spaceFilteredCheckIns = viewModel.checkIns
        }
        
        let trimmedSearchText = searchText
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        
        guard !trimmedSearchText.isEmpty else {
            return spaceFilteredCheckIns.sorted {
                $0.date > $1.date
            }
        }
        
        return spaceFilteredCheckIns
            .filter { checkIn in
                let noteMatches = checkIn.note
                    .localizedCaseInsensitiveContains(
                        trimmedSearchText
                    )
                
                let tagMatches = checkIn.tags.contains {
                    $0.localizedCaseInsensitiveContains(
                        trimmedSearchText
                    )
                }
                
                let spaceMatches = checkIn.space.title
                    .localizedCaseInsensitiveContains(
                        trimmedSearchText
                    )
                
                let moodMatches = checkIn.mood.title
                    .localizedCaseInsensitiveContains(
                        trimmedSearchText
                    )
                
                return noteMatches ||
                    tagMatches ||
                    spaceMatches ||
                    moodMatches
            }
            .sorted {
                $0.date > $1.date
            }
    }
    
    var body: some View {
        List {
            Section {
                Picker(
                    "Space",
                    selection: $selectedSpace
                ) {
                    Text("All")
                        .tag(nil as JournalSpace?)
                    
                    ForEach(JournalSpace.allCases) { space in
                        Text(space.title)
                            .tag(Optional(space))
                    }
                }
                .pickerStyle(.segmented)
            }
            
            if filteredCheckIns.isEmpty {
                ContentUnavailableView(
                    "No Check-Ins Found",
                    systemImage: "magnifyingglass",
                    description: Text(
                        "Try a different search or filter."
                    )
                )
                .listRowBackground(
                    Color.clear
                )
            } else {
                Section {
                    ForEach(filteredCheckIns) { checkIn in
                        NavigationLink {
                            CheckInDetailView(
                                checkIn: checkIn
                            ) {
                                selectedCheckIn = checkIn
                            }
                        } label: {
                            HistoryRow(
                                checkIn: checkIn
                            )
                        }                    }
                    .onDelete(
                        perform: deleteCheckIns
                    )
                }
            }
        }
        .navigationTitle("History")
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(
                displayMode: .always
            ),
            prompt: "Search notes and tags"
        )
        .sheet(item: $selectedCheckIn) { checkIn in
            CheckInView(
                space: checkIn.space,
                existingCheckIn: checkIn
            ) { updatedCheckIn in
                viewModel.addCheckIn(updatedCheckIn)
            }
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Check-Ins Yet",
            systemImage: "calendar",
            description: Text(
                "Your saved check-ins will appear here."
            )
        )
    }
    
    private var historyList: some View {
         List {
             Section {
                 Picker("Space", selection: $selectedSpace) {
                     Text("All")
                         .tag(nil as JournalSpace?)
                     
                     ForEach(JournalSpace.allCases) { space in
                         Text(space.title)
                             .tag(Optional(space))
                     }
                 }
                 .pickerStyle(.segmented)
             }
             
             Section {
                 ForEach(filteredCheckIns) { checkIn in
                     NavigationLink {
                         CheckInDetailView(checkIn: checkIn)
                     } label: {
                         
                         
                         HistoryRow(checkIn: checkIn)
                     }
                 }
                 .onDelete(perform: deleteCheckIns)
             }
         }
     }
    
    private func deleteCheckIns(at offsets: IndexSet) {
            let checkInsToDelete = offsets.map {
                filteredCheckIns[$0]
            }
            
            checkInsToDelete.forEach { checkIn in
                viewModel.deleteCheckIn(checkIn)
            }
        }
    }
    
private struct HistoryRow: View {
    
    let checkIn: CheckIn
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: checkIn.space.iconName)
                    .foregroundStyle(.blue)
                
                Text(checkIn.space.title)
                    .font(.headline)
                
                Spacer()
                
                Text(checkIn.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Text(checkIn.mood.emoji)
                    .font(.title)
                
                Text(checkIn.mood.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            if !checkIn.note.isEmpty {
                Text(checkIn.note)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
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
        }
        .padding(.vertical, 8)
    }
}


#Preview("History - Sample Data") {
    NavigationStack {
        HistoryView(viewModel: HomeViewModel(storageService: PreviewCheckInStorageService()))
    }
}

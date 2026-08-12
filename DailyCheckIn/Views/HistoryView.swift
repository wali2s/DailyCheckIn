//
//  HistoryView.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

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
            filterSection
            
            if filteredCheckIns.isEmpty {
                emptySection
            } else {
                historySection
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppColors.canvas)
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
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
    
    private var filterSection: some View {
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
            .listRowInsets(
                EdgeInsets(
                    top: 12,
                    leading: 16,
                    bottom: 12,
                    trailing: 16
                )
            )
        }
        .listRowBackground(AppColors.surface)
    }
    
    private var emptySection: some View {
        Section {
            ContentUnavailableView(
                "No Check-Ins Found",
                systemImage: "magnifyingglass",
                description: Text(
                    "Try a different search or filter."
                )
            )
            .frame(
                maxWidth: .infinity,
                minHeight: 220
            )
            .listRowInsets(
                EdgeInsets(
                    top: 24,
                    leading: 0,
                    bottom: 24,
                    trailing: 0
                )
            )
        }
        .listRowBackground(Color.clear)
    }
    
    private var historySection: some View {
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
                }
                .buttonStyle(.plain)
                .listRowInsets(
                    EdgeInsets(
                        top: 6,
                        leading: 0,
                        bottom: 6,
                        trailing: 0
                    )
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onDelete(
                perform: deleteCheckIns
            )
        } header: {
            Text(
                filteredCheckIns.count == 1
                ? "1 Check-In"
                : "\(filteredCheckIns.count) Check-Ins"
            )
            .foregroundStyle(AppColors.textSecondary)
        }
    }
    
    private func deleteCheckIns(
        at offsets: IndexSet
    ) {
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
    
    private var accentColor: Color {
        switch checkIn.space {
        case .personal:
            return AppColors.accentMint
        case .professional:
            return AppColors.accentBlue
        }
    }
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.standard
        ) {
            header
            
            moodSection
            
            if !checkIn.note.isEmpty {
                Text(checkIn.note)
                    .font(.subheadline)
                    .foregroundStyle(
                        AppColors.textSecondary
                    )
                    .lineLimit(3)
            }
            
            metricsSection
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .appCardStyle(
            backgroundColor: AppColors.surface,
            cornerRadius: AppCornerRadius.large,
            padding: AppSpacing.cardPadding
        )
    }
    
    private var header: some View {
        HStack(
            spacing: AppSpacing.small
        ) {
            ZStack {
                Circle()
                    .fill(
                        accentColor.opacity(0.25)
                    )
                    .frame(
                        width: 36,
                        height: 36
                    )
                
                Image(
                    systemName: checkIn.space.iconName
                )
                .font(.subheadline)
                .foregroundStyle(
                    AppColors.textPrimary
                )
            }
            
            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                Text(checkIn.space.title)
                    .font(.headline)
                    .foregroundStyle(
                        AppColors.textPrimary
                    )
                
                Text(checkIn.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(
                        AppColors.textSecondary
                    )
            }
            
            Spacer()
        }
    }
    
    private var moodSection: some View {
        HStack(
            spacing: AppSpacing.small
        ) {
            Image(systemName: checkIn.mood.iconName)
                .font(.title2)
                .foregroundStyle(checkIn.mood.iconColor)
            
            Text(checkIn.mood.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(
                    AppColors.textPrimary
                )
        }
    }
    
    private var metricsSection: some View {
        HStack(
            spacing: AppSpacing.standard
        ) {
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
        .foregroundStyle(
            AppColors.textSecondary
        )
    }
}

#Preview("History - Sample Data") {
    NavigationStack {
        HistoryView(
            viewModel: HomeViewModel(
                storageService:
                    PreviewCheckInStorageService()
            )
        )
    }
}

//
//  SettingsView.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var homeViewModel: HomeViewModel
    
    @State private var isShowingDeleteConfirmation = false
    
    @StateObject private var viewModel = SettingsViewModel()
    
    private let exportService = CheckInExportService()
    
    private var exportJSON: String? {
        try? exportService.makeJSON(
            from: homeViewModel.checkIns
        )
    }
    
    var body: some View {
        Form {
            reminderSection(
                title: "Personal Reminder",
                isEnabled: Binding(
                    get: {
                        viewModel.personalReminderEnabled
                    },
                    set: { newValue in
                        viewModel
                            .updatePersonalReminderEnabled(
                                newValue
                            )
                    }
                ),
                reminderTime: Binding(
                    get: {
                        viewModel.personalReminderTime
                    },
                    set: { newValue in
                        viewModel
                            .updatePersonalReminderTime(
                                newValue
                            )
                    }
                )
            )
            
            reminderSection(
                title: "Professional Reminder",
                isEnabled: Binding(
                    get: {
                        viewModel.professionalReminderEnabled
                    },
                    set: { newValue in
                        viewModel
                            .updateProfessionalReminderEnabled(
                                newValue
                            )
                    }
                ),
                reminderTime: Binding(
                    get: {
                        viewModel.professionalReminderTime
                    },
                    set: { newValue in
                        viewModel
                            .updateProfessionalReminderTime(
                                newValue
                            )
                    }
                )
            )
            
            dataSection
            
            if !viewModel.statusMessage.isEmpty {
                statusSection
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .scrollContentBackground(.hidden)
        .background(AppColors.canvas)
        .confirmationDialog(
            "Delete All Check-Ins",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                "Delete All Check-Ins",
                role: .destructive
            ) {
                homeViewModel.deleteAllCheckIns()
                viewModel.setStatusMessage(
                    "All check-ins were deleted."
                )
            }
            
            Button(
                "Cancel",
                role: .cancel
            ) {
                isShowingDeleteConfirmation = false
            }
        } message: {
            Text(
                "This action cannot be undone. All personal and professional check-ins will be permanently deleted."
            )
        }
    }
    
    private func reminderSection(
        title: String,
        isEnabled: Binding<Bool>,
        reminderTime: Binding<Date>
    ) -> some View {
        Section {
            Toggle(
                "Enable Reminder",
                isOn: isEnabled
            )
            
            if isEnabled.wrappedValue {
                DatePicker(
                    "Reminder Time",
                    selection: reminderTime,
                    displayedComponents: .hourAndMinute
                )
            }
        } header: {
            Label(
                title,
                systemImage: "bell.fill"
            )
        } footer: {
            Text(
                "Choose whether you want to receive a daily reminder."
            )
        }
    }
    
    private var dataSection: some View {
        Section {
            if let exportJSON {
                ShareLink(
                    item: exportJSON,
                    subject: Text("Daily Check-Ins"),
                    message: Text(
                        "Export of your Daily Check-In entries."
                    )
                ) {
                    Label(
                        "Export Check-Ins",
                        systemImage: "square.and.arrow.up"
                    )
                }
            } else {
                Label(
                    "Export unavailable",
                    systemImage: "exclamationmark.triangle"
                )
                .foregroundStyle(
                    AppColors.textSecondary
                )
            }
            
            Button(
                "Delete All Check-Ins",
                role: .destructive
            ) {
                isShowingDeleteConfirmation = true
            }
            .disabled(
                homeViewModel.checkIns.isEmpty
            )
        } header: {
            Label(
                "Data",
                systemImage: "externaldrive.fill"
            )
        } footer: {
            Text(
                "\(homeViewModel.checkIns.count) saved check-ins"
            )
        }
    }
    
    private var statusSection: some View {
        Section {
            Label(
                viewModel.statusMessage,
                systemImage: "checkmark.circle.fill"
            )
            .foregroundStyle(
                AppColors.textSecondary
            )
        } header: {
            Text("Status")
        }
    }
}

#Preview("Settings") {
    NavigationStack {
        SettingsView(
            homeViewModel: HomeViewModel(
                storageService:
                    PreviewCheckInStorageService()
            )
        )
    }
}

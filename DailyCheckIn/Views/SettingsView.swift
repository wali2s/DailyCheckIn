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
            Section("Personal Reminder") {
                Toggle(
                    "Enable Personal Reminder",
                    isOn: Binding(
                        get: {
                            viewModel.personalReminderEnabled
                        },
                        set: { newValue in
                            viewModel
                                .updatePersonalReminderEnabled(
                                    newValue
                                )
                        }
                    )
                )
                
                if viewModel.personalReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: Binding(
                            get: {
                                viewModel.personalReminderTime
                            },
                            set: { newValue in
                                viewModel
                                    .updatePersonalReminderTime(
                                        newValue
                                    )
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            
            Section("Professional Reminder") {
                Toggle(
                    "Enable Professional Reminder",
                    isOn: Binding(
                        get: {
                            viewModel
                                .professionalReminderEnabled
                        },
                        set: { newValue in
                            viewModel
                                .updateProfessionalReminderEnabled(
                                    newValue
                                )
                        }
                    )
                )
                
                if viewModel.professionalReminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: Binding(
                            get: {
                                viewModel
                                    .professionalReminderTime
                            },
                            set: { newValue in
                                viewModel
                                    .updateProfessionalReminderTime(
                                        newValue
                                    )
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            
            Section("Data") {
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
                    .foregroundStyle(.secondary)
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
            }
            
            if !viewModel.statusMessage.isEmpty {
                Section("Status") {
                    Text(viewModel.statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
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
            }
            
            Button("Cancel", role: .cancel) {
                isShowingDeleteConfirmation = false
            }
        } message: {
            Text("This action connat be undone. All personal and professional check-ins will be permanently deleted.")
        }
    }
}


#Preview("Settings") {
    NavigationStack {
        SettingsView(
            homeViewModel: HomeViewModel(
                storageService: PreviewCheckInStorageService()
            )
        )
    }
}

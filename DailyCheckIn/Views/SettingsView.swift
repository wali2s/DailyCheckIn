//
//  SettingsView.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
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
            
            if !viewModel.statusMessage.isEmpty {
                Section("Status") {
                    Text(viewModel.statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview("Settings") {
    NavigationStack {
        SettingsView()
    }
}

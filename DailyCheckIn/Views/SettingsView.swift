//  SettingsView.swift
//  DailyCheckIn

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("app_language")
    private var appLanguage = "en"
    
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var viewModel: SettingsViewModel
    @State private var isShowingDeleteConfirmation = false
    
    private let exportService = CheckInExportService()
    
    private var exportJSON: String? {
        try? exportService.makeJSON(from: homeViewModel.checkIns)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.standard) {
                profileCard
                languageCard
                
                reminderCard(
                    title: "Personal Reminder",
                    isEnabled: Binding(
                        get: { viewModel.personalReminderEnabled },
                        set: { viewModel.updatePersonalReminderEnabled($0) }
                    ),
                    reminderTime: Binding(
                        get: { viewModel.personalReminderTime },
                        set: { viewModel.updatePersonalReminderTime($0) }
                    )
                )
                
                reminderCard(
                    title: "Professional Reminder",
                    isEnabled: Binding(
                        get: { viewModel.professionalReminderEnabled },
                        set: { viewModel.updateProfessionalReminderEnabled($0) }
                    ),
                    reminderTime: Binding(
                        get: { viewModel.professionalReminderTime },
                        set: { viewModel.updateProfessionalReminderTime($0) }
                    )
                )
                
                dataCard
                
                if !viewModel.statusMessage.isEmpty {
                    statusCard
                }
            }
            .padding(AppSpacing.standard)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .background(AppColors.warmCanvas.ignoresSafeArea())
        .confirmationDialog(
            "Delete All Check-Ins",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete All Check-Ins", role: .destructive) {
                homeViewModel.deleteAllCheckIns()
                viewModel.setStatusMessage("All check-ins were deleted.")
            }
            
            Button("Cancel", role: .cancel) {
                isShowingDeleteConfirmation = false
            }
        } message: {
            Text("This action cannot be undone. All personal and professional check-ins will be permanently deleted.")
        }
    }
    
    // MARK: - Cards
    
    private var profileCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            cardHeader(title: "Profile", systemImage: "person.fill")
            
            TextField("Your name", text: Binding(
                get: { viewModel.displayName },
                set: { viewModel.updateDisplayName($0) }
            ))
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .padding(.horizontal, AppSpacing.standard)
            .padding(.vertical, 12)
            .background(AppColors.warmCanvas)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
        }
        .padding(AppSpacing.standard)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
    }
    
    private var languageCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            cardHeader(title: "Language", systemImage: "globe")
            
            Picker("Language", selection: $appLanguage) {
                Text("English").tag("en")
                Text("Deutsch").tag("de")
            }
            .pickerStyle(.segmented)
        }
        .padding(AppSpacing.standard)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
    }
    
    private func reminderCard(
        title: String,
        isEnabled: Binding<Bool>,
        reminderTime: Binding<Date>
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            cardHeader(title: title, systemImage: "bell.fill")
            
            Toggle("Enable Reminder", isOn: isEnabled)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
            
            if isEnabled.wrappedValue {
                Divider()
                    .padding(.vertical, 4)
                
                DatePicker(
                    "Reminder Time",
                    selection: reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
            }
            
            Text("Choose whether you want to receive a daily reminder.")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .padding(.top, 4)
        }
        .padding(AppSpacing.standard)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
    }
    
    private var dataCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            cardHeader(title: "Data", systemImage: "externaldrive.fill")
            
            if let exportJSON {
                ShareLink(
                    item: exportJSON,
                    subject: Text("Daily Check-Ins"),
                    message: Text("Export of your Daily Check-In entries.")
                ) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export Check-Ins")
                        Spacer()
                    }
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppColors.primaryAction)
                    .padding(.horizontal, AppSpacing.standard)
                    .padding(.vertical, 12)
                    .background(AppColors.warmCanvas)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
                }
            } else {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Export unavailable")
                }
                .foregroundStyle(AppColors.textSecondary)
                .padding(.vertical, 4)
            }
            
            Button(role: .destructive) {
                isShowingDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Delete All Check-Ins")
                    Spacer()
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .padding(.horizontal, AppSpacing.standard)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
            }
            .disabled(homeViewModel.checkIns.isEmpty)
            .opacity(homeViewModel.checkIns.isEmpty ? 0.5 : 1.0)
            
            Text("\(homeViewModel.checkIns.count) saved check-ins")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.standard)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
    }
    
    private var statusCard: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text(viewModel.statusMessage)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
        }
        .padding(AppSpacing.standard)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
    }
    
    // MARK: - Helper Header
    
    private func cardHeader(title: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(AppColors.primaryAction)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}

#Preview("Settings") {
    NavigationStack {
        SettingsView(
            homeViewModel: HomeViewModel(
                storageService: PreviewCheckInStorageService()
            ),
            viewModel: SettingsViewModel()
        )
    }
}

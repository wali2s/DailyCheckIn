//  SettingsView.swift
//  DailyCheckIn

import SwiftUI
import UniformTypeIdentifiers

private struct BackupShareFile: Identifiable {
    let url: URL

    var id: URL {
        url
    }
}

struct SettingsView: View {
    
    @AppStorage("app_language")
    private var appLanguage = "en"
    
    @ObservedObject var homeViewModel: HomeViewModel
    @ObservedObject var activityViewModel: ActivityViewModel
    @ObservedObject var viewModel: SettingsViewModel
    
    @State private var backupShareFile: BackupShareFile?
    @State private var isShowingBackupExportError = false
    
    @State private var isShowingBackupImporter = false
    @State private var pendingImportBackup: DailyCheckInBackup?
    @State private var isShowingImportPreview = false
    @State private var isShowingImportError = false
    
    @State private var isShowingSafetyBackupError = false
    @State private var isShowingNoSafetyBackup = false
    @State private var isShowingDeleteSafetyBackupError = false
    @State private var isShowingDataResetConfirmation = false

    @State private var importErrorMessage = ""
    @ObservedObject var appLockViewModel: AppLockViewModel
    
    private let exportService = CheckInExportService()
    private let importService = BackupImportService()
    
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
                
                privacyCard
            }
            .padding(AppSpacing.standard)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .background(AppColors.warmCanvas.ignoresSafeArea())
        .sheet(item: $backupShareFile) { backupFile in
            ShareSheet(items: [backupFile.url])
        }
        .alert(
            "Export unavailable",
            isPresented: $isShowingBackupExportError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your backup file could not be created.")
        }
        .fileImporter(
            isPresented: $isShowingBackupImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleBackupFileSelection(result)
        }

        .alert(
            "Import Backup",
            isPresented: $isShowingImportPreview
        ) {
            Button("Import and Merge") {
                mergePendingBackup()
            }

            Button(
                "Import and Replace Data",
                role: .destructive
            ) {
                importPendingBackup()
            }

            Button("Cancel", role: .cancel) {
                pendingImportBackup = nil
            }
        } message: {
            Text(importPreviewMessage)
        }
        .alert(
            "No Safety Backup Found",
            isPresented: $isShowingNoSafetyBackup
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                "No automatic safety backup is currently available."
            )
        }
        .alert(
            "Delete cancelled",
            isPresented: $isShowingDeleteSafetyBackupError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                "A local safety backup could not be created. "
                + "Your check-ins have not been deleted."
            )
        }
        .alert(
            "Import Failed",
            isPresented: $isShowingImportError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importErrorMessage)
        }
        .confirmationDialog(
            "Reset Check-In & Activity Data",
            isPresented: $isShowingDataResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(
                "Reset Check-In & Activity Data",
                role: .destructive
            ) {
                resetJournalDataSafely()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "All check-ins, activities and activity completions "
                + "will be deleted. A local safety backup is created first."
            )
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
            
            Button {
                exportBackup()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Backup")
                    Spacer()
                }
                .font(.system(
                    size: 16,
                    weight: .semibold,
                    design: .rounded
                ))
                .foregroundStyle(AppColors.primaryAction)
                .padding(.horizontal, AppSpacing.standard)
                .padding(.vertical, 12)
                .background(AppColors.warmCanvas)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppCornerRadius.standard
                    )
                )
            }
            
            Button {
                isShowingBackupImporter = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Import Backup")
                    Spacer()
                }
                .font(.system(
                    size: 16,
                    weight: .semibold,
                    design: .rounded
                ))
                .foregroundStyle(AppColors.primaryAction)
                .padding(.horizontal, AppSpacing.standard)
                .padding(.vertical, 12)
                .background(AppColors.warmCanvas)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppCornerRadius.standard
                    )
                )
            }
            
            Button {
                restoreLatestSafetyBackup()
            } label: {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Restore Latest Safety Backup")
                    Spacer()
                }
                .font(.system(
                    size: 16,
                    weight: .semibold,
                    design: .rounded
                ))
                .foregroundStyle(AppColors.primaryAction)
                .padding(.horizontal, AppSpacing.standard)
                .padding(.vertical, 12)
                .background(AppColors.warmCanvas)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppCornerRadius.standard
                    )
                )
            }
            
            Text(safetyBackupStatusText)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
            
            Button(role: .destructive) {
                isShowingDataResetConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash.slash.fill")
                    Text("Delete All Check-Ins & Activities")
                    Spacer()
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .padding(.horizontal, AppSpacing.standard)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.1))
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: AppCornerRadius.standard
                    )
                )
            }
            .disabled(
                homeViewModel.checkIns.isEmpty
                    && activityViewModel.activities.isEmpty
                    && activityViewModel.completions.isEmpty
            )
            
            Text("\(homeViewModel.checkIns.count) saved check-ins")
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.standard)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.standard))
    }
    
    private func exportBackup() {
        let backup = DailyCheckInBackup(
            checkIns: homeViewModel.checkIns,
            activities: activityViewModel.activities,
            activityCompletions: activityViewModel.completions
        )

        do {
            let fileURL = try exportService.makeBackupFile(
                from: backup
            )

            backupShareFile = BackupShareFile(url: fileURL)
        } catch {
            isShowingBackupExportError = true
        }
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
    
    //MARK: - PrivacyCard
    
    private var privacyCard: some View {
        VStack(
            alignment: .leading,
            spacing: AppSpacing.small
        ) {
            cardHeader(
                title: "Privacy",
                systemImage: "lock.fill"
            )

            Toggle(
                "Lock app with Face ID",
                isOn: Binding(
                    get: {
                        appLockViewModel.isEnabled
                    },
                    set: {
                        appLockViewModel.setEnabled($0)
                    }
                )
            )
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(AppColors.textPrimary)

            Text(
                "Face ID, Touch ID, or your device passcode "
                + "will be required after the app is sent to the background."
            )
            .font(.caption)
            .foregroundStyle(AppColors.textSecondary)
            
            if appLockViewModel.isEnabled {
                Button {
                    appLockViewModel.lock()
                } label: {
                    Label(
                        "Lock Now",
                        systemImage: "lock.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(
                    PrimaryButtonStyle(
                        backgroundColor: AppColors.primaryAction
                    )
                )
                .accessibilityIdentifier("lockAppNowButton")
            }
        }
        .padding(AppSpacing.standard)
        .background(AppColors.surface)
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppCornerRadius.standard
            )
        )
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
    
    private var safetyBackupStatusText: String {
        guard
            let fileURL = exportService.latestSafetyBackupFile(),
            let values = try? fileURL.resourceValues(
                forKeys: [.contentModificationDateKey]
            ),
            let date = values.contentModificationDate
        else {
            return "No local safety backup available yet."
        }

        return "Latest safety backup: "
            + date.formatted(
                date: .abbreviated,
                time: .shortened
            )
    }
    
    private var importPreviewMessage: String {
        guard let backup = pendingImportBackup else {
            return "No backup data was found."
        }

        return """
        This backup contains \(backup.checkIns.count) check-ins,
        \(backup.activities.count) activities and
        \(backup.activityCompletions.count) activity completions.

        Nothing has been changed yet.
        """
    }
    
    private func importPendingBackup() {
        guard let backup = pendingImportBackup else {
            return
        }

        let currentBackup = DailyCheckInBackup(
            checkIns: homeViewModel.checkIns,
            activities: activityViewModel.activities,
            activityCompletions: activityViewModel.completions
        )

        do {
            _ = try exportService.makeSafetyBackupFile(
                from: currentBackup
            )
        } catch {
            isShowingSafetyBackupError = true
            return
        }

        homeViewModel.replaceCheckIns(
            with: backup.checkIns
        )

        activityViewModel.replaceStoredData(
            activities: backup.activities,
            completions: backup.activityCompletions
        )

        pendingImportBackup = nil

        viewModel.setStatusMessage(
            "Backup imported successfully. "
            + "A safety backup was created."
        )
    }
    
    private func deleteAllCheckInsSafely() {
        let currentBackup = DailyCheckInBackup(
            checkIns: homeViewModel.checkIns,
            activities: activityViewModel.activities,
            activityCompletions: activityViewModel.completions
        )

        do {
            _ = try exportService.makeSafetyBackupFile(
                from: currentBackup
            )
        } catch {
            isShowingDeleteSafetyBackupError = true
            return
        }

        homeViewModel.deleteAllCheckIns()

        viewModel.setStatusMessage(
            "All check-ins were deleted. "
            + "A safety backup was created first."
        )
    }
    
    private func resetJournalDataSafely() {
        let currentBackup = DailyCheckInBackup(
            checkIns: homeViewModel.checkIns,
            activities: activityViewModel.activities,
            activityCompletions: activityViewModel.completions
        )

        do {
            _ = try exportService.makeSafetyBackupFile(
                from: currentBackup
            )
        } catch {
            isShowingDeleteSafetyBackupError = true
            return
        }

        homeViewModel.deleteAllCheckIns()
        activityViewModel.deleteAllStoredData()

        viewModel.setStatusMessage(
            "Check-ins and activities were reset. "
            + "A safety backup was created first."
        )
    }

    private func handleBackupFileSelection(
        _ result: Result<[URL], Error>
    ) {
        do {
            let fileURLs = try result.get()

            guard let fileURL = fileURLs.first else {
                throw BackupImportError.invalidFile
            }

            loadBackup(from: fileURL)
        } catch {
            showImportError(for: error)
        }
    }
    
    private func restoreLatestSafetyBackup() {
        guard let fileURL = exportService.latestSafetyBackupFile()
        else {
            isShowingNoSafetyBackup = true
            return
        }

        loadBackup(from: fileURL)
    }

    private func loadBackup(
        from fileURL: URL
    ) {
        do {
            let hasAccess = fileURL
                .startAccessingSecurityScopedResource()

            defer {
                if hasAccess {
                    fileURL.stopAccessingSecurityScopedResource()
                }
            }

            let data = try Data(contentsOf: fileURL)

            pendingImportBackup = try importService.decodeBackup(
                from: data
            )

            isShowingImportPreview = true
        } catch {
            showImportError(for: error)
        }
    }
    
    private func showImportError(for error: Error) {
        switch error {
        case BackupImportError.unsupportedVersion:
            importErrorMessage =
                "This backup was created with an unsupported "
                + "version of DailyCheckIn."

        default:
            importErrorMessage =
                "This file is not a valid DailyCheckIn backup."
        }

        isShowingImportError = true
    }
    
    private func mergePendingBackup() {
        guard let backup = pendingImportBackup else {
            return
        }

        homeViewModel.mergeCheckIns(
            from: backup.checkIns
        )

        activityViewModel.mergeStoredData(
            activities: backup.activities,
            completions: backup.activityCompletions
        )

        pendingImportBackup = nil
        viewModel.setStatusMessage(
            "Backup merged successfully."
        )
    }
}

#Preview {
    SettingsView(
        homeViewModel: HomeViewModel(
            storageService: UserDefaultsCheckInStorageService()
        ),
        activityViewModel: ActivityViewModel(),
        viewModel: SettingsViewModel(),
        appLockViewModel: AppLockViewModel()
    )
}

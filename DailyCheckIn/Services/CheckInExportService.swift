//
//  CheckInExportService.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import Foundation

final class CheckInExportService {
    private let maximumSafetyBackupCount = 10

    private let encoder: JSONEncoder
    private let fileManager: FileManager
    private let safetyBackupDirectoryURL: URL?

    init(
        fileManager: FileManager = .default,
        safetyBackupDirectoryURL: URL? = nil
    ) {
        self.fileManager = fileManager
        self.safetyBackupDirectoryURL =
            safetyBackupDirectoryURL

        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]
        encoder.dateEncodingStrategy = .iso8601

        self.encoder = encoder
    }

    func makeJSON(
        from checkIns: [CheckIn]
    ) throws -> String {
        let data = try encoder.encode(checkIns)

        guard let jsonString = String(
            data: data,
            encoding: .utf8
        ) else {
            throw CheckInExportError.encodingFailed
        }

        return jsonString
    }

    func makeBackupData(
        from backup: DailyCheckInBackup
    ) throws -> Data {
        do {
            return try encoder.encode(backup)
        } catch {
            throw CheckInExportError.encodingFailed
        }
    }

    func makeBackupFile(
        from backup: DailyCheckInBackup
    ) throws -> URL {
        let data = try makeBackupData(from: backup)

        let fileURL = fileManager.temporaryDirectory
            .appendingPathComponent(
                backupFileName(
                    prefix: "DailyCheckIn-Backup",
                    exportedAt: backup.exportedAt
                )
            )

        do {
            try data.write(
                to: fileURL,
                options: .atomic
            )

            return fileURL
        } catch {
            throw CheckInExportError.fileCreationFailed
        }
    }

    func makeSafetyBackupFile(
        from backup: DailyCheckInBackup
    ) throws -> URL {
        let data = try makeBackupData(from: backup)

        do {
            let backupDirectory = try safetyBackupDirectory(
                createIfNeeded: true
            )

            let fileURL = backupDirectory
                .appendingPathComponent(
                    backupFileName(
                        prefix: "DailyCheckIn-Backup",
                        exportedAt: backup.exportedAt
                    )
                )

            try data.write(
                to: fileURL,
                options: .atomic
            )

            removeOldSafetyBackups(
                in: backupDirectory,
                keeping: maximumSafetyBackupCount
            )

            return fileURL
        } catch {
            throw CheckInExportError.fileCreationFailed
        }
    }

    func latestSafetyBackupFile() -> URL? {
        do {
            let backupDirectory = try safetyBackupDirectory(
                createIfNeeded: false
            )

            return sortedSafetyBackupURLs(
                in: backupDirectory
            )
            .first
        } catch {
            return nil
        }
    }

    private func safetyBackupDirectory(
        createIfNeeded: Bool
    ) throws -> URL {
        let backupDirectory: URL

        if let safetyBackupDirectoryURL {
            backupDirectory = safetyBackupDirectoryURL
        } else {
            let applicationSupportURL = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: createIfNeeded
            )

            backupDirectory = applicationSupportURL
                .appendingPathComponent(
                    "DailyCheckIn/SafetyBackups",
                    isDirectory: true
                )
        }

        if createIfNeeded {
            try fileManager.createDirectory(
                at: backupDirectory,
                withIntermediateDirectories: true
            )
        }

        return backupDirectory
    }

    private func backupFileName(
        prefix: String,
        exportedAt: Date
    ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(
            identifier: "en_US_POSIX"
        )
        dateFormatter.dateFormat =
            "yyyy-MM-dd_HH-mm-ss"

        return prefix
            + "-"
            + dateFormatter.string(from: exportedAt)
            + "-"
            + UUID().uuidString
            + ".json"
    }

    private func sortedSafetyBackupURLs(
        in backupDirectory: URL
    ) -> [URL] {
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: backupDirectory,
            includingPropertiesForKeys: [
                .contentModificationDateKey
            ]
        ) else {
            return []
        }

        return fileURLs
            .filter {
                $0.pathExtension == "json"
                    && $0.lastPathComponent.hasPrefix(
                        "DailyCheckIn-Backup-"
                    )
            }
            .sorted { firstURL, secondURL in
                let firstDate = try? firstURL.resourceValues(
                    forKeys: [.contentModificationDateKey]
                )
                .contentModificationDate

                let secondDate = try? secondURL.resourceValues(
                    forKeys: [.contentModificationDateKey]
                )
                .contentModificationDate

                let resolvedFirstDate =
                    firstDate ?? .distantPast

                let resolvedSecondDate =
                    secondDate ?? .distantPast

                if resolvedFirstDate != resolvedSecondDate {
                    return resolvedFirstDate > resolvedSecondDate
                }

                return firstURL.lastPathComponent
                    > secondURL.lastPathComponent
            }
    }

    private func removeOldSafetyBackups(
        in backupDirectory: URL,
        keeping maximumCount: Int
    ) {
        let safetyBackupURLs = sortedSafetyBackupURLs(
            in: backupDirectory
        )

        for oldBackupURL in safetyBackupURLs.dropFirst(
            maximumCount
        ) {
            try? fileManager.removeItem(
                at: oldBackupURL
            )
        }
    }
}

enum CheckInExportError: Error {
    case encodingFailed
    case fileCreationFailed
}

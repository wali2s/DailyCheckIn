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
    
    init() {
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

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"

        let uniqueID = UUID().uuidString

        let fileName =
            "DailyCheckIn-Backup-"
            + dateFormatter.string(from: backup.exportedAt)
            + "-"
            + uniqueID
            + ".json"

        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)

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
            let applicationSupportURL = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )

            let backupDirectory = applicationSupportURL
                .appendingPathComponent(
                    "DailyCheckIn/SafetyBackups",
                    isDirectory: true
                )

            try FileManager.default.createDirectory(
                at: backupDirectory,
                withIntermediateDirectories: true
            )

            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(
                identifier: "en_US_POSIX"
            )
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"

            let uniqueID = UUID().uuidString

            let fileName =
                "DailyCheckIn-Backup-"
                + dateFormatter.string(from: backup.exportedAt)
                + "-"
                + uniqueID
                + ".json"

            let fileURL = backupDirectory
                .appendingPathComponent(fileName)

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
    
    private func removeOldSafetyBackups(
        in backupDirectory: URL,
        keeping maximumCount: Int
    ) {
        guard let fileURLs = try? FileManager.default.contentsOfDirectory(
            at: backupDirectory,
            includingPropertiesForKeys: [
                .contentModificationDateKey
            ]
        ) else {
            return
        }

        let safetyBackupURLs = fileURLs
            .filter {
                $0.pathExtension == "json"
                    && $0.lastPathComponent.hasPrefix(
                        "DailyCheckIn-Backup-"
                    )
            }
            .sorted { firstURL, secondURL in
                let firstDate = try? firstURL.resourceValues(
                    forKeys: [.contentModificationDateKey]
                ).contentModificationDate

                let secondDate = try? secondURL.resourceValues(
                    forKeys: [.contentModificationDateKey]
                ).contentModificationDate

                return (firstDate ?? .distantPast)
                    > (secondDate ?? .distantPast)
            }

        for oldBackupURL in safetyBackupURLs.dropFirst(maximumCount) {
            try? FileManager.default.removeItem(
                at: oldBackupURL
            )
        }
    }
    
    func latestSafetyBackupFile() -> URL? {
        do {
            let applicationSupportURL = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )

            let backupDirectory = applicationSupportURL
                .appendingPathComponent(
                    "DailyCheckIn/SafetyBackups",
                    isDirectory: true
                )

            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: backupDirectory,
                includingPropertiesForKeys: [
                    .contentModificationDateKey
                ]
            )

            return fileURLs
                .filter {
                    $0.pathExtension == "json"
                }
                .sorted { firstURL, secondURL in
                    let firstDate = try? firstURL
                        .resourceValues(
                            forKeys: [.contentModificationDateKey]
                        )
                        .contentModificationDate

                    let secondDate = try? secondURL
                        .resourceValues(
                            forKeys: [.contentModificationDateKey]
                        )
                        .contentModificationDate

                    return (firstDate ?? .distantPast)
                        > (secondDate ?? .distantPast)
                }
                .first
        } catch {
            return nil
        }
    }
}

enum CheckInExportError: Error {
    case encodingFailed
    case fileCreationFailed
}

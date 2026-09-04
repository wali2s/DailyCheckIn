//
//  BackupImportService.swift
//  DailyCheckIn
//
//  Created by Wahid on 04.09.26.
//

import Foundation

enum BackupImportError: Error {
    case invalidFile
    case unsupportedVersion
}

final class BackupImportService {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func decodeBackup(
        from data: Data
    ) throws -> DailyCheckInBackup {
        let backup: DailyCheckInBackup

        do {
            backup = try decoder.decode(
                DailyCheckInBackup.self,
                from: data
            )
        } catch {
            throw BackupImportError.invalidFile
        }

        guard backup.version
                == DailyCheckInBackup.currentVersion else {
            throw BackupImportError.unsupportedVersion
        }

        return backup
    }
}

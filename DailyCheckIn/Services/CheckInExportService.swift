//
//  CheckInExportService.swift
//  DailyCheckIn
//
//  Created by Wahid on 11.08.26.
//

import Foundation

final class CheckInExportService {
    
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
}

enum CheckInExportError: Error {
    case encodingFailed
}

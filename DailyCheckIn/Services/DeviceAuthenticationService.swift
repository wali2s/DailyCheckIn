//
//  DeviceAuthenticationService.swift
//  DailyCheckIn
//
//  Created by Wahid on 04.09.26.
//

import Foundation
import LocalAuthentication

protocol DeviceAuthenticating {
    func authenticate() async -> Bool
}

final class DeviceAuthenticationService: DeviceAuthenticating {
    func authenticate() async -> Bool {
        let context = LAContext()

        var error: NSError?

        guard context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        ) else {
            return false
        }

        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason:
                    "Unlock DailyCheckIn to view your private data."
            )
        } catch {
            return false
        }
    }
}

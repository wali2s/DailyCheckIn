//
//  AppLockViewModel.swift
//  DailyCheckIn
//
//  Created by Wahid on 04.09.26.
//

import Foundation
import Combine

@MainActor
final class AppLockViewModel: ObservableObject {
    @Published private(set) var isEnabled: Bool
    @Published private(set) var isUnlocked: Bool

    private let authenticationService: DeviceAuthenticating
    private let userDefaults: UserDefaults

    private let appLockEnabledKey = "app_lock_enabled"

    init(
        authenticationService: DeviceAuthenticating =
            DeviceAuthenticationService(),
        userDefaults: UserDefaults = .standard
    ) {
        self.authenticationService = authenticationService
        self.userDefaults = userDefaults

        let isEnabled = userDefaults.bool(
            forKey: appLockEnabledKey
        )

        self.isEnabled = isEnabled
        self.isUnlocked = !isEnabled
    }

    func setEnabled(
        _ isEnabled: Bool
    ) {
        self.isEnabled = isEnabled

        userDefaults.set(
            isEnabled,
            forKey: appLockEnabledKey
        )

        isUnlocked = !isEnabled
    }

    func lock() {
        guard isEnabled else {
            return
        }

        isUnlocked = false
    }

    func unlock() async {
        guard isEnabled else {
            isUnlocked = true
            return
        }

        isUnlocked = await authenticationService.authenticate()
    }
}

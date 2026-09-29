//
//  DailyCheckInApp.swift
//  DailyCheckIn
//
//  Created by Wahid on 10.08.26.
//

import SwiftUI
import Foundation


@main
struct DailyCheckInApp: App {
    
    init() {
        guard
            ProcessInfo.processInfo.arguments.contains(
                "UI_TESTING_RESET_DATA"
            ),
            let bundleIdentifier = Bundle.main.bundleIdentifier
        else {
            return
        }

        UserDefaults.standard.removePersistentDomain(
            forName: bundleIdentifier
        )
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                
        }
    }
}

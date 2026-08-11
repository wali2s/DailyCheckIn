//
//  DailyCheckInUITests.swift
//  DailyCheckInUITests
//
//  Created by Wahid on 10.08.26.
//


import XCTest

final class DailyCheckInUITests: XCTestCase {
    
    func testUserCanOpenProfessionalCheckInForm() {
        let app = XCUIApplication()
        app.launch()
        
        let createCheckInButton = app.buttons[
            "createCheckInButton.professional"
        ]
        
        XCTAssertTrue(
            createCheckInButton.waitForExistence(timeout: 3)
        )
        
        createCheckInButton.tap()
        
        XCTAssertTrue(
            app.navigationBars["New Check-In"]
                .waitForExistence(timeout: 3)
        )
        
        XCTAssertTrue(
            app.buttons["saveCheckInButton"].exists
        )
    }
    
}

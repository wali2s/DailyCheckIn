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
    
    func testUserCanCreateProfessionalCheckIn() {
        let app = XCUIApplication()
        app.launch()
        
        let createCheckInButton = app.buttons[
            "createCheckInButton.professional"
        ]
        
        XCTAssertTrue(
            createCheckInButton.waitForExistence(timeout: 3)
        )
        
        createCheckInButton.tap()
        
        let noteField = app.textFields[
            "checkInNoteTextField"
        ]
        
        XCTAssertTrue(
            noteField.waitForExistence(timeout: 3)
        )
        
        noteField.tap()
        noteField.typeText("Worked on the Daily Check-In app.")
        
        app.buttons["saveCheckInButton"].tap()
        
        XCTAssertTrue(
            app.navigationBars["Daily Check-In"]
                .waitForExistence(timeout: 3)
        )
    }
}

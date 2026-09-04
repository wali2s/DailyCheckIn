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

        let carousel = app.scrollViews["checkInSpaceCarousel"]

        XCTAssertTrue(
            carousel.waitForExistence(timeout: 3)
        )

        carousel.swipeLeft()

        let checkInButton = app.buttons["homeCheckInButton"]

        let workButtonExpectation = expectation(
            for: NSPredicate(
                format: "label == %@",
                "Start Work check-in"
            ),
            evaluatedWith: checkInButton
        )

        let result = XCTWaiter().wait(
            for: [workButtonExpectation],
            timeout: 3
        )

        XCTAssertEqual(result, .completed)

        checkInButton.tap()

        XCTAssertTrue(
            app.navigationBars["New Check-In"]
                .waitForExistence(timeout: 3)
        )

        XCTAssertTrue(
            app.buttons["continueCheckInButton.step1"]
                .waitForExistence(timeout: 3)
        )
    }
    
}

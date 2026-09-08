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
    
    func testUserCanSwipeBetweenHistoryCalendarSpaces() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["History"].tap()

        let selectedSpace = app.otherElements[
            "historyCalendarSelectedSpace"
        ]

        XCTAssertTrue(
            selectedSpace.waitForExistence(timeout: 3)
        )

        XCTAssertEqual(selectedSpace.label, "Private")

        let window = app.windows.firstMatch

        let start = window.coordinate(
            withNormalizedOffset: CGVector(
                dx: 0.85,
                dy: 0.45
            )
        )

        let end = window.coordinate(
            withNormalizedOffset: CGVector(
                dx: 0.15,
                dy: 0.45
            )
        )

        start.press(
            forDuration: 0.1,
            thenDragTo: end
        )

        let workExpectation = expectation(
            for: NSPredicate(
                format: "label == %@",
                "Work"
            ),
            evaluatedWith: selectedSpace
        )

        let result = XCTWaiter().wait(
            for: [workExpectation],
            timeout: 3
        )

        XCTAssertEqual(result, .completed)
    }
}

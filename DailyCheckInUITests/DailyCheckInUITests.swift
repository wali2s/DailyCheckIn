//
//  DailyCheckInUITests.swift
//  DailyCheckInUITests
//
//  Created by Wahid on 10.08.26.
//


import XCTest

final class DailyCheckInUITests: XCTestCase {
    
    private func launchCleanApp() -> XCUIApplication {
        let app = XCUIApplication()

        app.launchArguments.append(
            "UI_TESTING_RESET_DATA"
        )

        app.launch()

        return app
    }
    
    
    func testUserCanOpenProfessionalCheckInForm() {
        let app = launchCleanApp()

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
        let app = launchCleanApp()

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
    
    func testProfileButtonOpensSettings() {
        let app = launchCleanApp()


        let profileButton = app.buttons["Profile"]

        XCTAssertTrue(
            profileButton.waitForExistence(timeout: 3)
        )

        profileButton.tap()

        XCTAssertTrue(
            app.navigationBars["Settings"]
                .waitForExistence(timeout: 3)
        )
    }
    
    
    func testUserCanCreateFirstActivityFromEmptyState() {
        let app = launchCleanApp()

        app.tabBars.buttons["Activities"].tap()

        let createActivityButton = app.buttons[
            "createFirstActivityButton"
        ]

        XCTAssertTrue(
            createActivityButton.waitForExistence(timeout: 3)
        )

        createActivityButton.tap()

        XCTAssertTrue(
            app.navigationBars["New Activity"]
                .waitForExistence(timeout: 3)
        )
    }
    
    func testUserCanStartFirstPersonalCheckInFromWelcomeCard() {
        let app = launchCleanApp()

        let privateButton = app.buttons[
            "firstCheckInButton.personal"
        ]

        XCTAssertTrue(
            privateButton.waitForExistence(timeout: 3)
        )

        privateButton.tap()

        XCTAssertTrue(
            app.navigationBars["New Check-In"]
                .waitForExistence(timeout: 3)
        )

        XCTAssertTrue(
            app.buttons["continueCheckInButton.step1"]
                .waitForExistence(timeout: 3)
        )
    }
    
    func testUserCanOpenLoyaltyPrograms() {
        let app = launchCleanApp()

        app.tabBars.buttons["Settings"].tap()

        let rewardsButton = app.buttons[
            "openLoyaltyProgramsButton"
        ]

        XCTAssertTrue(
            rewardsButton.waitForExistence(timeout: 3)
        )

        rewardsButton.tap()

        let rewardsView = app.scrollViews[
            "loyaltyProgramsView"
        ]

        XCTAssertTrue(
            rewardsView.waitForExistence(timeout: 3)
        )

        XCTAssertTrue(
            app.staticTexts["Coffee Card"]
                .waitForExistence(timeout: 3)
        )

        XCTAssertTrue(
            app.staticTexts["Iced Drinks Card"]
                .waitForExistence(timeout: 3)
        )
    
    }
}

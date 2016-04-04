//
//  AllisonsCatPalaceSwiftUITests.swift
//  AllisonsCatPalaceSwiftUITests
//
//  Created by A658308 on 3/27/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import XCTest

class AllisonsCatPalaceSwiftUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSwipeToDelete() {
        // Failed to find matching element please file bug (bugreport.apple.com) and provide output from Console.app
        
        let app = XCUIApplication()
        app.navigationBars["AllisonsCatPalaceSwift.MasterView"].buttons["Edit"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.childrenMatchingType(.Cell).matchingIdentifier("kittenCell").elementBoundByIndex(0).buttons["Delete kittenCell"].tap()
        tablesQuery.buttons["Delete"].tap()
        
        let cancelButton = app.alerts["DANGER"].collectionViews.buttons["Cancel"]
        cancelButton.tap()
        
        let doneButton = app.buttons["Done"]
        doneButton.tap()
    }
}

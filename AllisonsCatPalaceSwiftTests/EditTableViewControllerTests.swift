//
//  EditTableViewControllerTests.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 4/2/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import XCTest
@testable import AllisonsCatPalaceSwift

class EditTableViewControllerTests: XCTestCase {
    private var editTableVC = testEditTableVC
    private class var testEditTableVC: EditTableViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        if let editTableVC = storyboard.instantiateViewControllerWithIdentifier("EditTableViewController") as? EditTableViewController {
            editTableVC.kitten = getFakeKittens()[0]
            
            UIApplication.sharedApplication().keyWindow!.rootViewController = editTableVC
            XCTAssertNotNil(editTableVC.view)
            return editTableVC
        }
        return EditTableViewController()
    }
    
    func loadViewController() {
        editTableVC.viewDidLoad()
        editTableVC.viewWillAppear(true)
        editTableVC.viewDidAppear(true)
    }

    override func setUp() {
        super.setUp()
        loadViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDownloadImagesForImageViewWithGoodURL() {
        let expectation = expectationWithDescription("Image download completed")
        let goodKitten = Kitten(name: "with good url", pictureUrl: "http://placekitten.com/300/300")
        editTableVC.kitten = goodKitten
        XCTAssertNil(self.editTableVC.imageView.image)
        editTableVC.downloadImagesForImageView(editTableVC.imageView, link: editTableVC.kitten!.pictureUrl!, contentMode: .ScaleAspectFill) {
            print(self.editTableVC.imageView)
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNotNil(self.editTableVC.imageView.image)
        }
    }

    func testDownloadImagesForImageViewWithNonUrl() {
        let badKitten = Kitten(name: "with bad url", pictureUrl: "Not a Url")
        editTableVC.kitten = badKitten
        editTableVC.downloadImagesForImageView(editTableVC.imageView, link: editTableVC.kitten!.pictureUrl!, contentMode: .ScaleAspectFill) {
            // Ensures the completion block was not invoked with bad url
            XCTFail()
        }
    }
    
    func testDownloadImagesForImageViewWithInvalidUrl() {
        let badKitten = Kitten(name: "with no image at url", pictureUrl: "google.com")
        editTableVC.kitten = badKitten
        editTableVC.downloadImagesForImageView(editTableVC.imageView, link: editTableVC.kitten!.pictureUrl!, contentMode: .ScaleAspectFill) {
            // Ensures the completion block was not invoked with invalid url
            XCTFail()
        }
    }
    
    func testTextFieldShouldReturnNameField() {
        UIWindow().addSubview(editTableVC.view)
        NSRunLoop.currentRunLoop().runUntilDate(NSDate())
        editTableVC.nameField.becomeFirstResponder()
        XCTAssertTrue(editTableVC.nameField.isFirstResponder())
        editTableVC.textFieldShouldReturn(editTableVC.nameField)
        XCTAssertTrue(editTableVC.aboutField.isFirstResponder())
        XCTAssertFalse(editTableVC.nameField.isFirstResponder())
    }
    
    func testTextFieldShouldReturnAboutField() {
        UIWindow().addSubview(editTableVC.view)
        NSRunLoop.currentRunLoop().runUntilDate(NSDate())
        editTableVC.aboutField.becomeFirstResponder()
        XCTAssertTrue(editTableVC.aboutField.isFirstResponder())
        editTableVC.textFieldShouldReturn(editTableVC.aboutField)
        XCTAssertTrue(editTableVC.ageField.isFirstResponder())
        XCTAssertFalse(editTableVC.aboutField.isFirstResponder())
    }
    
    func testTextFieldShouldChangeCharactersInRangeWithValidReplacementString() {
        XCTAssertFalse(editTableVC.applyButton.enabled)
        editTableVC.textField(editTableVC.ageField, shouldChangeCharactersInRange: NSRange(), replacementString: "5")
        XCTAssertTrue(editTableVC.applyButton.enabled)
    }
    
    func testTextFieldShouldChangeCharactersInRangeWithInvalidReplacementString() {
        XCTAssertFalse(editTableVC.applyButton.enabled)
        editTableVC.textField(editTableVC.ageField, shouldChangeCharactersInRange: NSRange(), replacementString: "five")
        XCTAssertFalse(editTableVC.applyButton.enabled)
    }
    
    func testCancelPopsViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        if let navController = storyboard.instantiateInitialViewController() as? UINavigationController {
            UIApplication.sharedApplication().keyWindow!.rootViewController = navController
            navController.pushViewController(editTableVC, animated: false)
            XCTAssertTrue(editTableVC.navigationController?.topViewController == editTableVC)
            editTableVC.cancelChanges(UIButton())
            // TODO: - find someway of checking that the editTableVC is no longer on the stack... or rather get it to not be.
        }
        
        editTableVC.cancelChanges(UIButton())
    }
}

extension Kitten {
    
    init(name: String?, pictureUrl: String) {
        self.name = name
        self.key = ""
        self.about = ""
        self.greeting = ""
        self.age = 1
        self.cutenessLevel = 1
        self.ref = nil
        self.pictureUrl = pictureUrl
    }
}

private func getFakeKittens() -> [Kitten] {
    return [
        Kitten(name: "fakeynamename", about: "", greeting: "", age: 3, cutenessLevel: 5),
        Kitten(name: "", about: "", greeting: "", age: 3, cutenessLevel: 5),
        Kitten(name: "", about: "", greeting: "", age: 3, cutenessLevel: 5),
        Kitten(name: "", about: "", greeting: "", age: 3, cutenessLevel: 5),
        Kitten(name: "", about: "", greeting: "", age: 3, cutenessLevel: 5)
    ]
}
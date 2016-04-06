//
//  DetailViewControllerTests.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 4/1/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import XCTest
@testable import AllisonsCatPalaceSwift
@testable import Firebase

class DetailViewControllerTests: XCTestCase {
    private var detailVC = testDetailVC
    private class var testDetailVC: DetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        if let detailVC = storyboard.instantiateViewControllerWithIdentifier("DetailViewController") as? DetailViewController {
            UIApplication.sharedApplication().keyWindow!.rootViewController = detailVC
            
            detailVC.kitten = getFakeKittens()[0]
            detailVC.kittenImage = UIImage()
            
            XCTAssertNotNil(detailVC.view)
            return detailVC
        }
        return DetailViewController()
    }
    
    func loadViewController() {
        detailVC.viewDidLoad()
        detailVC.viewWillAppear(true)
        detailVC.viewDidAppear(true)
    }
    
    override func setUp() {
        super.setUp()
        loadViewController()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        detailVC.viewWillDisappear(true)
        detailVC.viewDidDisappear(true)
    }

    func testVCLoadsDirectly() {
        XCTAssertNotNil(detailVC.view)
        XCTAssertTrue(detailVC.isViewLoaded())
    }
    
    func testPrepareForSegueEditVC() {
        if let editVC = detailVC.storyboard?.instantiateViewControllerWithIdentifier("EditTableViewController") as? EditTableViewController {
            let segue = UIStoryboardSegue(identifier: "showEditVC", source: detailVC, destination: editVC)
            detailVC.prepareForSegue(segue, sender: nil)
            XCTAssertNotNil(editVC.kitten)
            XCTAssert(editVC.kitten?.name == "fakeynamename")
            XCTAssert(editVC.kitten?.age == 3)
            XCTAssert(editVC.kitten?.cutenessLevel == 5)
        } else {
            XCTFail()
        }
    }
    
    func testPreviewActionItemsHaveCorrectTitles() {
        let items = detailVC.previewActionItems()
        XCTAssertTrue(items.count == 2)
        XCTAssertEqual(items[0].title, "Edit")
        XCTAssertEqual(items[1].title, "Delete")
    }
    
    func testPreviewingContextSetsCompletionHandlersOnDetailVC() {
        let masterVC = MasterViewControllerMock()
        let previewing: UIViewControllerPreviewing = masterVC.registerForPreviewingWithDelegate(masterVC, sourceView: masterVC.view)
        let mockDetailVC = masterVC.previewingContext(previewing, viewControllerForLocation: CGPoint(x: 0,y: 0)) as! DetailViewController
        guard let editCompletion = mockDetailVC.editKittenCompletion else { XCTFail(); return }
        editCompletion()
        XCTAssertEqual(masterVC.completionHandlerHit, "editCompletion")
        guard let deleteCompletion = mockDetailVC.deleteKittenCompletion else { XCTFail(); return }
        deleteCompletion(getFakeKittens()[0])
        XCTAssertEqual(masterVC.completionHandlerHit, "deleteCompletion")
    }
    
    func testPreviewActionItemsHaveCorrectHandlers() {
        let masterVC = MasterViewControllerMock()
        let previewing: UIViewControllerPreviewing = masterVC.registerForPreviewingWithDelegate(masterVC, sourceView: masterVC.view)
        let mockDetailVC = masterVC.previewingContext(previewing, viewControllerForLocation: CGPoint(x: 0,y: 0)) as! DetailViewController
        mockDetailVC.kitten = getFakeKittens()[0]
        mockDetailVC.previewActionItems()
        if let previewActions = mockDetailVC.previewActions {
            let editPreviewAction = previewActions[0]
            editPreviewAction.handler(editPreviewAction, mockDetailVC)
            XCTAssertEqual(masterVC.completionHandlerHit, "editCompletion")
            let deletePreviewAction = previewActions[1]
            deletePreviewAction.handler(deletePreviewAction, mockDetailVC)
            XCTAssertEqual(masterVC.completionHandlerHit, "deleteCompletion")
        } else { XCTFail() }
    }
    
    func testLoadKittenDataWithGoodEndpoint() {
        // note: this is really more of an integration test
        let expectation = expectationWithDescription("kitten data loaded")
        detailVC.loadKittenData() {
            print("hit")
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            XCTAssertNotNil(self.detailVC.kitten)
        }
    }
    
    func testLoadKittenDataCallsObserveSingleEventOfType() {
        detailVC.ref = MockFirebase(withError: false)
        detailVC.loadKittenData() {}
        let ref = detailVC.ref as! MockFirebase
        XCTAssertEqual(ref.eventObservedCount, 1)
    }
}

private class MasterViewControllerMock: MasterViewController {
    var completionHandlerHit: String = ""
    
    override func deleteKittenWithWarning(kitten: Kitten) {
        completionHandlerHit = ("deleteCompletion")
    }
    
    override func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let detailVC = storyboard.instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        detailVC.editKittenCompletion = {
            // maybe fulfill an expectation here? Maybe not because not async or anything
            self.completionHandlerHit = "editCompletion"
            return detailVC
        }
        detailVC.deleteKittenCompletion = deleteKittenWithWarning
        return detailVC
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
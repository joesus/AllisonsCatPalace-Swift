//  MasterViewControllerTests.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 3/28/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import XCTest
@testable import AllisonsCatPalaceSwift
@testable import Firebase

class MasterViewControllerTests: XCTestCase {
    private var masterVC = testMasterVC
    private class var testMasterVC: MasterViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        if let vc = navigationController.topViewController as? MasterViewController {
            return vc
        }
        return MasterViewController()
    }
    
    func loadViewController() {
        masterVC.viewDidLoad()
        masterVC.viewWillAppear(true)
        masterVC.viewDidAppear(true)
    }
    
    func previewing() -> UIViewControllerPreviewing {
        return self.masterVC.registerForPreviewingWithDelegate(self.masterVC, sourceView: self.masterVC.view)
    }
    
    override func setUp() {
        super.setUp()
        loadViewController()
    }
    
    override func tearDown() {
        super.tearDown()
        masterVC.viewWillDisappear(true)
        masterVC.viewDidDisappear(true)
    }
    
    func testVCLoadsInNavigationController() {
        XCTAssertTrue(masterVC.parentViewController is UINavigationController)
        XCTAssertNotNil(masterVC.view)
    }
    
    func testViewLoadsDirectly() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = storyboard.instantiateViewControllerWithIdentifier("MasterViewController")
        vc.loadView()
        XCTAssertNotNil(vc.view)
    }
    
    func testPrepareForSegueEditVC() {
        if let editVC = masterVC.storyboard?.instantiateViewControllerWithIdentifier("EditTableViewController") as? EditTableViewController {
            let segue = UIStoryboardSegue(identifier: "showEditVC", source: masterVC, destination: editVC)
            masterVC.prepareForSegue(segue, sender: nil)
            XCTAssertNotNil(editVC.kitten)
            XCTAssert(editVC.kitten?.name == "")
            XCTAssert(editVC.kitten?.age == 1)
            XCTAssert(editVC.kitten?.cutenessLevel == 5)
        } else {
            XCTFail()
        }
    }
    
    func testPrepareForSegueShowDetailVC() {
        if let detailVC = masterVC.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as? DetailViewController {
            let segue = UIStoryboardSegue(identifier: "showDetail", source: masterVC, destination: detailVC)
            let cell = UITableViewCell()
            cell.tag = 4
            masterVC.kittens = getFakeKittens()
            masterVC.kittenImages = getFakeKittenImages()
            masterVC.prepareForSegue(segue, sender: cell)
            
            XCTAssertNotNil(detailVC.kitten)
            XCTAssertNotNil(detailVC.kittenImage)
        }
    }
    
    func testDeleteKittenWithWarningShowsAlertWithCorrectTitle() {
        let masterVCMock = MasterViewControllerMock()
        masterVCMock.deleteKittenWithWarning(getFakeKittens()[0])
        
        if let alert = masterVCMock.viewControllerToPresent as? UIAlertController {
            XCTAssertNotNil(masterVCMock.deleteKittenAlert)
            XCTAssertEqual(alert.title, "DANGER")
        }
    }
    
    func testDeleteKittenWithWarningShowsAlertWithYesAction() {
        let masterVCMock = MasterViewControllerMock()
        masterVCMock.alertAction = MockAlertAction.self
        masterVCMock.deleteKittenWithWarning(getFakeKittens()[0])
        XCTAssertNotNil(masterVCMock.deleteKittenAlert)
        if let alertVC = masterVCMock.deleteKittenAlert {
            let action = alertVC.actions.first as! MockAlertAction
            action.handler!(action)
            XCTAssertEqual(masterVCMock.actionString, "Yes")
        }
    }
    
    func testDeleteKittenWithWarningShowsAlertWithCancelAction() {
        let masterVCMock = MasterViewControllerMock()
        masterVCMock.alertAction = MockAlertAction.self
        masterVCMock.deleteKittenWithWarning(getFakeKittens()[0])
        XCTAssertNotNil(masterVCMock.deleteKittenAlert)
        if let alertVC = masterVCMock.deleteKittenAlert {
            let action = alertVC.actions.last as! MockAlertAction
            action.handler!(action)
            XCTAssertEqual(masterVCMock.actionString, "Cancel")
        }
    }
    
    func testdownloadImagesForImageViewWithBadLink() {
        let imageView = UIImageView()
        masterVC.downloadImagesForImageView(imageView, link: "badlink", contentMode: .ScaleAspectFit) {}
        XCTAssertNil(imageView.image)
    }
    
    func testLoadKittenDataWithGoodEndpoint() {
        // note: this is really more of an integration test
        let expectation = expectationWithDescription("kitten data loaded")
        masterVC.loadKittenData() {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            XCTAssertFalse(self.masterVC.kittens.isEmpty)
        }
    }
    
    func testLoadKittenDataWithBadInfo() {
        let masterVC = MasterViewController(ref: "https://catpalacebadurl.something.com")
        masterVC.loadKittenData() {}
        XCTAssertTrue(masterVC.kittens.isEmpty)
    }
    
    func testCommitEditingStyleForIndexRowAtPathWithDelete() {
        XCTAssertNil(masterVC.deleteKittenAlert)
        let expectation = expectationWithDescription("kitten data loaded")
        
        masterVC.loadKittenData() {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            self.masterVC.tableView(self.masterVC.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
            XCTAssertNotNil(self.masterVC.deleteKittenAlert)
            XCTAssertFalse(self.masterVC.kittens.isEmpty)
        }
    }
    
    func testPreviewingContextDelegateSetsCompletionOnTargetVC() {
        let expectation = expectationWithDescription("kitten data loaded")
        masterVC.loadKittenData() {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            let rect = self.masterVC.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
            let point = CGPoint(x: rect.origin.x, y: rect.origin.y)
            if let detailVC = self.masterVC.previewingContext(self.previewing(), viewControllerForLocation: point) as? DetailViewController {
                XCTAssertNotNil(detailVC.deleteKittenCompletion)
                XCTAssertNotNil(detailVC.editKittenCompletion)
            } else {
                XCTFail()
            }
        }
    }
    
    func testPreviewingContextDelegateReturnsNoVCWithBadCellLocation() {
        let expectation = expectationWithDescription("kitten data loaded")
        masterVC.loadKittenData() {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let _ = self.masterVC.previewingContext(self.previewing(), viewControllerForLocation: CGPoint(x: -1, y: -1)) as? DetailViewController {
                XCTFail()
            }
        }
    }
    
    func testPreviewingContextDelegateReturnNoVCWhenTableHasNotLoaded() {
        if let _ = self.masterVC.previewingContext(self.previewing(), viewControllerForLocation: CGPoint(x: 1, y: 1)) as? DetailViewController {
            XCTFail()
        }
    }
    
    func testPreviewingContextViewControllerForLocationEditCompletionHandlerSetsCorrectKittenOnEditVC() {
        let expectation = expectationWithDescription("kitten data loaded")
        masterVC.loadKittenData() {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            let rect = self.masterVC.tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
            let point = CGPoint(x: rect.origin.x, y: rect.origin.y)
            if let detailVC = self.masterVC.previewingContext(self.previewing(), viewControllerForLocation: point) as? DetailViewController {
                let editVC = detailVC.editKittenCompletion!() as! EditTableViewController
                XCTAssertTrue(self.masterVC.kittens.first!.name == editVC.kitten!.name)
            } else {
                XCTFail()
            }
        }
    }
    
    func testPreviewingContextCommitViewController() {
        let expectation = expectationWithDescription("kitten data loaded")
        masterVC.loadKittenData() {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(5) { error in
            if let detailVC = self.masterVC.storyboard?.instantiateViewControllerWithIdentifier("DetailViewController") as? DetailViewController {
                self.masterVC.previewingContext(self.previewing(), commitViewController: detailVC)
                // TODO: - Is there any way to actually test this? Somehow get back the popped vc and get info off it?
            }
        }
    }
}

private func getFakeKittens() -> [Kitten] {
    return [
        Kitten(name: "", about: "", greeting: "", age: 3, cutenessLevel: 5),
        Kitten(name: "", about: "", greeting: "", age: 3, cutenessLevel: 5),
        Kitten(name: "", about: "", greeting: "", age: 3, cutenessLevel: 5),
        Kitten(name: "", about: "", greeting: "", age: 3, cutenessLevel: 5),
        Kitten(name: "", about: "", greeting: "", age: 3, cutenessLevel: 5)
    ]
}

private func getFakeKittenImages() -> [Int: UIImage] {
    return [
        1: UIImage(),
        2: UIImage(),
        3: UIImage(),
        4: UIImage()
    ]
}

class MockAlertAction: UIAlertAction {
    typealias Handler = ((UIAlertAction) -> ())
    var handler: Handler?
    var mockTitle: String?
    var mockStyle: UIAlertActionStyle
    
    convenience init(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> ())?) {
        self.init()
        mockTitle = title
        mockStyle = style
        self.handler = handler
    }
    
    override init() {
        mockStyle = .Default
        super.init()
    }
}

private class MasterViewControllerMock: MasterViewController {
    var viewControllerToPresent: UIViewController?
    
    override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        self.viewControllerToPresent = viewControllerToPresent
    }
}
//
//  AllisonsCatPalaceSwiftTests.swift
//  AllisonsCatPalaceSwiftTests
//
//  Created by A658308 on 3/27/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import XCTest
@testable import AllisonsCatPalaceSwift
@testable import Firebase

class AllisonsCatPalaceSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    func testKittenInit() {
        let fakeData = getKittenData()
        let newKitten = Kitten(name: fakeData["name"] as? String, about: fakeData["about"] as? String, greeting: fakeData["greeting"] as? String, age: fakeData["age"] as? Int, cutenessLevel: fakeData["cutenessLevel"] as? Int)
        XCTAssert(newKitten.name == "TestCat")
        XCTAssert(newKitten.age == 5)
    }
    
    func testKittenInitFromSnapshotWithNoName() {
        let snapShot = testableSnapShot(key: "five", value: [])
        do {
            try _ = Kitten.init(snapshot: snapShot)
        } catch {
            XCTAssert(true)
            return
        }
        XCTFail()
    }
    
    func testKittenInitFromSnapshotWithValidName() {
        let snapShot = testableSnapShot(key: "five", value: ["name": "something"])
        do {
            try _ = Kitten.init(snapshot: snapShot)
        } catch {
            XCTAssert(true)
            return
        }
        XCTFail()
    }
    
    func testKittenInitFromSnapshotWithValidCuteness() {
        let snapShot = testableSnapShot(key: "five", value: ["name": "", "cutenesslevel": ""])
        do {
            try _ = Kitten.init(snapshot: snapShot)
        } catch {
            XCTAssert(true)
            return
        }
        XCTFail()
    }
    
    func testKittenInitFromSnapshotWithValidAbout() {
        let snapShot = testableSnapShot(key: "five", value: ["name": "", "cutenesslevel": "", "about": ""])
        do {
            try _ = Kitten.init(snapshot: snapShot)
        } catch {
            XCTAssert(true)
            return
        }
        XCTFail()
    }
    
    func testKittenInitFromSnapshotWithValidGreeting() {
        let snapShot = testableSnapShot(key: "five", value: ["name": "", "cutenesslevel": "", "about": "", "greeting": ""])
        do {
            try _ = Kitten.init(snapshot: snapShot)
        } catch {
            XCTAssert(true)
            return
        }
        XCTFail()
    }
    
    func testKittenInitFromSnapshotWithValidPicture() {
        let snapShot = testableSnapShot(key: "five", value: ["name": "", "cutenesslevel": "", "about": "", "greeting": "", "picture": ""])
        do {
            try _ = Kitten.init(snapshot: snapShot)
        } catch {
            XCTAssert(true)
            return
        }
        XCTFail()
    }
    
    func testKittenInitFromSnapshotWithAllValidFields() {
        let snapShot = testableSnapShot(key: "five", value: ["name": "", "cutenesslevel": "", "about": "", "greeting": "", "picture": "", "age": ""])
        do {
            try _ = Kitten.init(snapshot: snapShot)
        } catch {
            XCTFail()
            return
        }
        XCTAssert(true)
    }
    
    func testKittenInitFromSnapshotWithNilName() {
        let snapShot = testableSnapShot(key: "five", value: ["name": ""])
        do {
            try _ = Kitten.init(snapshot: snapShot)
        } catch {
            XCTAssert(true)
            return
        }
        XCTFail()
    }
    
    func getKittenData() -> [String: AnyObject] {
        let fakeData: [String: AnyObject] = [
            "name": "TestCat",
            "about": "About TestCat",
            "greeting": "Hello TestCat",
            "picture": "www.com",
            "age": 5,
            "cutenesslevel": 10
        ]
        return fakeData
    }
}

class testableSnapShot: SnapShotable {
    var value: AnyObject! = "badValue"
    var key: String! = "five"
    var ref: Firebase! = Firebase()
    
    init(key: String, value: AnyObject) {
        self.key = key
        self.value = value
    }
    
    func hasChild(childPathString: String!) -> Bool {
        if self.value[childPathString] != nil {
            return true
        } else {
            return false
        }
    }
}




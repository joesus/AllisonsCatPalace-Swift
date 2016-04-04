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
    
    func testKittenInitFromSnapshotWithBadData() {
        let snapShot = testableSnapShot()
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
            "age": 5,
            "cutenessLevel": 10
        ]
        return fakeData
    }
}

class testableSnapShot: FDataSnapshot {
    override var key: String {
        get {
            return super.key ?? "five"
        }
    }
    override var value: AnyObject {
        get {
            return "badValue"
        }
    }
}




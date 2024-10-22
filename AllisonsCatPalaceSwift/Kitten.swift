//
//  Kitten.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 1/5/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import Foundation
import Firebase

enum KittenError: ErrorType {
    case InvalidData(String)
}

struct Kitten {
    
    let key: String
    let name: String?
    let about: String?
    let greeting: String?
    let pictureUrl: String!
    var age: Int?
    var cutenessLevel: Int?
    var ref: Firebaseable?
    
    // Initialize from arbitrary data
    init(name: String?, about: String?, greeting: String?, age: Int?, cutenessLevel: Int?, key: String = "") {
        self.key = key
        self.name = name
        self.about = about
        self.greeting = greeting
        self.age = age
        self.cutenessLevel = cutenessLevel
        self.pictureUrl = "http://placekitten.com/" + "\((300...500).randomInt)/\((300...500).randomInt)"
        self.ref = nil
    }
    
    init(snapshot: SnapShotable) throws {
        let error = KittenError.InvalidData("No value for key in snapshot")
        if let key = snapshot.key {
            self.key = key
        } else {
            throw error
        }
        guard let name = snapshot.value["name"] where snapshot.hasChild("name") else { throw error }
        guard let cutenessLevel = snapshot.value["cutenesslevel"] where snapshot.hasChild("cutenesslevel") else { throw error }
        guard let about = snapshot.value["about"] where snapshot.hasChild("about") else { throw error }
        guard let greeting = snapshot.value["greeting"] where snapshot.hasChild("greeting") else { throw error }
        guard let pictureUrl = snapshot.value["picture"] where snapshot.hasChild("picture") else { throw error }
        guard let age = snapshot.value["age"] where snapshot.hasChild("age") else { throw error }
        self.name = name as? String
        self.about = about as? String
        self.greeting = greeting as? String
        self.pictureUrl = pictureUrl as? String
        self.age = age as? Int
        self.cutenessLevel = cutenessLevel as? Int
        ref = snapshot.ref
    }
}
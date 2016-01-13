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
    
    let key: String!
    let name: String!
    let about: String!
    let greeting: String!
    let pictureUrl: String!
    var age: Int!
    var cutenessLevel: Int!
    let ref: Firebase?
    
    // Initialize from arbitrary data
    init(name: String, about: String, greeting: String, age: Int, cutenessLevel: Int, key: String = "") {
        self.key = key
        self.name = name
        self.about = about
        self.greeting = greeting
        self.age = age
        self.cutenessLevel = cutenessLevel
        self.pictureUrl = "http://placekitten.com/" + "\((300...500).randomInt)/\((300...500).randomInt)"
        self.ref = nil
    }
    
    init(snapshot: FDataSnapshot) throws {
        key = snapshot.key
        guard let guardedName = snapshot.value["name"] else {
            throw KittenError.InvalidData("No value for name key")
        }
        guard let guardedAbout = snapshot.value["about"] else {
            throw KittenError.InvalidData("No value for about key")
        }
        guard let guardedGreeting = snapshot.value["greeting"] else {
            throw KittenError.InvalidData("No value for greeting key")
        }
        guard let guardedPictureURL = snapshot.value["picture"] else {
            throw KittenError.InvalidData("No value for picture key")
        }
        guard let guardedAge = snapshot.value["age"] else {
            throw KittenError.InvalidData("No value for age key")
        }
        guard let guardedCutenessLevel = snapshot.value["cutenesslevel"] else {
            throw KittenError.InvalidData("No value for cutenesslevel key")
        }
        name = guardedName as! String
        about = guardedAbout as! String
        greeting = guardedGreeting as! String
        pictureUrl = guardedPictureURL as! String
        age = guardedAge as! Int
        cutenessLevel = guardedCutenessLevel as! Int
        ref = snapshot.ref
    }
    
    func toAnyObject() -> [String: AnyObject] {
        return [
            "name": name,
            "about": about,
            "greeting": greeting,
            "pictureUrl": pictureUrl,
            "age": age,
            "cutenessLevel": cutenessLevel,
        ]
    }
    
}
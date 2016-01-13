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
        if let name = snapshot.value["name"],
            about = snapshot.value["about"],
            greeting = snapshot.value["greeting"],
            pictureUrl = snapshot.value["picture"],
            age = snapshot.value["age"],
            cutenessLevel = snapshot.value["cutenesslevel"] {
            self.name = name as! String
            self.about = about as! String
            self.greeting = greeting as! String
            self.pictureUrl = pictureUrl as! String
            self.age = age as! Int
            self.cutenessLevel = cutenessLevel as! Int
        } else {
            throw KittenError.InvalidData("No value for required key")
        }
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
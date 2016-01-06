//
//  Kitten.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 1/5/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import Foundation
import Firebase

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
//    init(name: String, about: String, completed: Bool, key: String = "") {
//        self.key = key
//        self.name = name
//        self.addedByUser = addedByUser
//        self.completed = completed
//        self.ref = nil
//    }
    
    init(snapshot: FDataSnapshot) {
        key = snapshot.key
        name = snapshot.value["name"] as! String
        about = snapshot.value["about"] as! String
        greeting = snapshot.value["greeting"] as! String
        pictureUrl = snapshot.value["picture"] as! String
        age = snapshot.value["age"] as! Int
        cutenessLevel = snapshot.value["cutenesslevel"] as! Int
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
//
//  Firebaseable.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 4/6/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import Foundation
import Firebase

protocol Firebaseable {
    func updateChildValues(values: [NSObject : AnyObject]!, withCompletionBlock block: ((NSError!, Firebase!) -> Void)!)
    func childByAutoId() -> Firebase!
    func removeValue()
    func setValue(value: AnyObject!) -> Void
    func observeSingleEventOfType(eventType: FEventType, withBlock block: ((FDataSnapshot!) -> Void)!)
}

extension Firebase: Firebaseable { }
//
//  SnapShotable.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 4/6/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import Foundation
import Firebase

protocol SnapShotable {
    func hasChild(childPathString: String!) -> Bool
    var value: AnyObject! { get }
    var key: String! { get }
    var ref: Firebase! { get }
}

extension FDataSnapshot: SnapShotable { }
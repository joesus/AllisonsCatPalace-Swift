//
//  AppDelegate.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 1/4/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import UIKit
import Firebase

let FirebaseUrl = "https://catpalace.firebaseio.com/"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    override init() {
        super.init()
        Firebase.defaultConfig().persistenceEnabled = true
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
}


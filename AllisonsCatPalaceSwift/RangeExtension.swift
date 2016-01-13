//
//  RangeExtension.swift
//  AllisonsCatPalaceSwift
//
//  Created by A658308 on 1/13/16.
//  Copyright © 2016 Joe Susnick Co. All rights reserved.
//

import Foundation

extension Range
{
    var randomInt: Int
        {
        get
        {
            var offset = 0
            
            if (startIndex as! Int) < 0   // allow negative ranges
            {
                offset = abs(startIndex as! Int)
            }
            
            let mini = UInt32(startIndex as! Int + offset)
            let maxi = UInt32(endIndex   as! Int + offset)
            
            return Int(mini + arc4random_uniform(maxi - mini)) - offset
        }
    }
}
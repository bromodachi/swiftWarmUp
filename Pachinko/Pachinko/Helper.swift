//
//  Helper.swift
//  Pachinko
//
//  Created by a on 12/1/15.
//  Copyright © 2015 bromodachi. All rights reserved.
//

import Foundation
import UIKit
import GameKit


func RandomColor() -> UIColor {
    return UIColor(red: RandomCGFloat(), green: RandomCGFloat(), blue: RandomCGFloat(), alpha: 1)
}

func RandomCGFloat () ->CGFloat{
    return CGFloat(Float(arc4random()) / Float(UInt32.max))
}
func RandomFloat() -> Float {
    return Float(arc4random()) /  Float(UInt32.max)
}

func randomCGPoint() -> CGPoint {
    return CGPoint(x: GKRandomDistribution(lowestValue: 0, highestValue: 1000).nextInt(), y: GKRandomDistribution(lowestValue: 350, highestValue: 600).nextInt())
}

func randomCGFloat(min: Float, max: Float) -> CGFloat {
    return CGFloat((Float(arc4random()) / Float(UInt32.max)) * (max - min) + min)
}



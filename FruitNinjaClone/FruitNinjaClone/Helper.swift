//
//  Helper.swift
//  FruitNinjaClone
//
//  Created by a on 12/13/15.
//  Copyright © 2015 bromodachi. All rights reserved.
//

import Foundation
import UIKit
import GameKit

func randomInt(min:Int, max: Int) ->Int {
    if max < min{return min}
    return Int(arc4random_uniform(UInt32((max-min)+1))) + min
}

func runDelay(delay: NSTimeInterval, block: dispatch_block_t){
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(time, dispatch_get_main_queue(), block)
}

func RandomColor() -> UIColor {
    return UIColor(red: RandomCGFloat(), green: RandomCGFloat(), blue: RandomCGFloat(), alpha: 1)
}

func RandomCGFloat () ->CGFloat{
    return CGFloat(Float(arc4random()) / Float(UInt32.max))
}
func RandomFloat() -> Float {
    return Float(arc4random()) /  Float(UInt32.max)
}

func randomDouble (min :Double, max:Double) -> Double {
    return (Double(arc4random()) / Double(UInt32.max)) * (max-min) + min
}

func randomCGPoint() -> CGPoint {
    return CGPoint(x: GKRandomDistribution(lowestValue: 0, highestValue: 1000).nextInt(), y: GKRandomDistribution(lowestValue: 350, highestValue: 600).nextInt())
}

func randomCGFloat(min: Float, max: Float) -> CGFloat {
    return CGFloat((Float(arc4random()) / Float(UInt32.max)) * (max - min) + min)
}
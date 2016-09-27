//
//  Utilities.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 3/1/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import Foundation
import CoreGraphics
import AVFoundation

// MARK: - Functions -
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *= (left: inout CGPoint, right: CGPoint) {
    left = left * right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (point: inout CGPoint, scalar: CGFloat) {
    point = point * scalar
}

func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func /= (left: inout CGPoint, right: CGPoint) {
    left = left / right
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (point: inout CGPoint, scalar: CGFloat) {
    point = point / scalar
}

// Point inside rect
func < (point: CGPoint, rect: CGRect) -> Bool {
    return point.x >= rect.minX && point.x <= rect.maxX &&
        point.y >= rect.minY && point.y <= rect.maxY
}

// Point outside rect
func > (point: CGPoint, rect: CGRect) -> Bool {
    return point.x < rect.minX || point.x > rect.maxX ||
        point.y < rect.minY || point.y < rect.maxY
}

func randomCGPointInRect(_ rect:CGRect,margin:CGFloat)->CGPoint{
    let x = CGFloat.random(rect.minX + margin, max: rect.maxX - margin)
    let y = CGFloat.random(rect.minY + margin, max: rect.maxY - margin)
    return CGPoint(x: x,y: y)
}

let π = CGFloat(M_PI)
let degreesToRadians = π / 180
let radiansToDegree = 180 / π

func shortestAngleBetween(_ angle1: CGFloat, angle2: CGFloat) -> CGFloat {
    let twoπ = π * 2.0
    var angle = (angle2 - angle1).truncatingRemainder(dividingBy: twoπ)
    if angle >= π {
        angle = angle - twoπ
    }
    if angle <= -π {
        angle = angle + twoπ
    }
    return angle
}

#if !(arch(x86_64) || arch(arm64))
    func atan2(y: CGFloat, x: CGFloat) -> CGFloat {
        return CGFloat(atan2f(Float(y), Float(x)))
    }
    
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif


// MARK: - Extensions -
extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
    
    var angle: CGFloat {
        return atan2(y, x)
    }
    
    public static func randomUnitVector()->CGPoint{
        let vector = CGPoint(x: CGFloat.random(-1.0,max:1.0),y: CGFloat.random(-1.0,max:1.0))
        return vector.normalized()
    }
}

extension CGFloat {
    func sign() -> CGFloat {
        return (self >= 0.0) ? 1.0 : -1.0
    }
    
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    
    static func random(_ min: CGFloat, max: CGFloat) -> CGFloat {
        //assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}

extension Int{
    static func random(_ range: ClosedRange<Int>) -> Int {
        var offset = 0
        
        if range.lowerBound < 0 {
            offset = abs(range.lowerBound)
        }
        
        let min = UInt32(range.lowerBound + offset)
        let max = UInt32(range.upperBound   + offset)
        
        return Int(min + arc4random_uniform(max - min)) - offset
    }
}


// MARK: - Music -
var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(_ filename: String) {
    let resourceUrl = Bundle.main.url(forResource: filename, withExtension: nil)
    guard let url = resourceUrl else {
        print("Could not find file: \(filename)")
        return
    }
    
    do {
        try backgroundMusicPlayer = AVAudioPlayer(contentsOf: url)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    } catch {
        print("Could not create audio player!")
        return
    }
}

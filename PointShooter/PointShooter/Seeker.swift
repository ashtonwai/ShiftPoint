//
//  Seeker.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/9/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import Foundation
import SpriteKit

class Seeker : SKShapeNode {
    var forward: CGPoint = CGPointMake(0.0, 1.0)
    var velocity: CGPoint = CGPointZero
    var direction: CGPoint = CGPointZero
    var delta: CGFloat = 300.0
    var rotateSpeed: CGFloat = 3.0 * π
    
    var lastUpdateTime: NSTimeInterval = 0
    var deltaTime: NSTimeInterval = 0
    
    init(size: CGSize) {
        super.init()
        
        let pathToDraw = CGPathCreateMutable()
        CGPathMoveToPoint(pathToDraw, nil, 0, size.height/2)
        CGPathAddLineToPoint(pathToDraw, nil, -size.width/2, -size.height/2)
        CGPathAddLineToPoint(pathToDraw, nil, size.width/2, -size.height/2)
        CGPathAddLineToPoint(pathToDraw, nil, 0, size.height/2)
        CGPathCloseSubpath(pathToDraw)
        path = pathToDraw
        lineWidth = 0
        fillColor = UIColor.blueColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func seek(currentTime: NSTimeInterval, location: CGPoint) {
        if lastUpdateTime > 0 {
            deltaTime = currentTime - lastUpdateTime
        } else {
            deltaTime = 0
        }
        lastUpdateTime = currentTime
        
        let offset = location - self.position
        direction = offset.normalized()
        velocity = direction * delta
        position += velocity * CGFloat(deltaTime)
        rotate()
    }
    
    func rotate() {
        let shortest = shortestAngleBetween(self.zRotation, angle2: velocity.angle)
        let amountToRotate = min(rotateSpeed * CGFloat(deltaTime), abs(shortest))
        self.zRotation += shortest.sign() * amountToRotate
    }
}
//
//  Seeker.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/9/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Seeker : SKShapeNode {
    var forward: CGPoint = CGPointMake(0.0, 1.0)
    var velocity: CGPoint = CGPointZero
    var direction: CGPoint = CGPointZero
    var delta: CGFloat = 250.0
    var rotateSpeed: CGFloat = 3.0 * π
    
    init(size: CGSize) {
        super.init()
        
        let pathToDraw = CGPathCreateMutable()
        CGPathMoveToPoint(pathToDraw, nil, 0, size.height/2)
        CGPathAddLineToPoint(pathToDraw, nil, size.width/2, -size.height/2)
        CGPathAddLineToPoint(pathToDraw, nil, -size.width/2, -size.height/2)
        CGPathAddLineToPoint(pathToDraw, nil, 0, size.height/2)
        CGPathCloseSubpath(pathToDraw)
        path = pathToDraw
        lineWidth = 3
        strokeColor = UIColor.redColor()
        fillColor = UIColor.clearColor()
        
        self.name = "seeker"
        
        self.physicsBody = SKPhysicsBody(polygonFromPath: path!)
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func seek(deltaTime: NSTimeInterval, location: CGPoint) {
        let offset = location - self.position
        direction = offset.normalized()
        velocity = direction * delta
        position += velocity * CGFloat(deltaTime)
        
        // rotation
        let shortest = shortestAngleBetween(self.zRotation + π/2, angle2: velocity.angle)
        let amountToRotate = min(rotateSpeed * CGFloat(deltaTime), abs(shortest))
        self.zRotation += shortest.sign() * amountToRotate
    }
}
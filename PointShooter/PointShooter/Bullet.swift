//
//  Bullet.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/4/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Bullet : SKShapeNode {
    let bulletSpeed: Double = 1
    
    init(circleOfRadius: CGFloat) {
        super.init()
        
        let diameter = circleOfRadius * 2
        let center = CGPoint(x: -circleOfRadius, y: -circleOfRadius)
        let size = CGSize(width: diameter, height: diameter)
        
        self.name = "bullet"
        
        self.path = CGPathCreateWithEllipseInRect(CGRect(origin: center, size: size), nil)
        self.fillColor = SKColor.redColor()
        self.lineWidth = 0
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        self.physicsBody?.usesPreciseCollisionDetection = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(dx: CGFloat, dy: CGFloat) {
        let move = SKAction.moveBy(CGVector(dx: dx, dy: dy), duration: bulletSpeed)
        let delete = SKAction.removeFromParent()
        self.runAction(SKAction.sequence([move, delete]))
    }
}
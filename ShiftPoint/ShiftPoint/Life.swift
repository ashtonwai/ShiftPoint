//
//  Life.swift
//  ShiftPoint
//
//  Created by Zach Bebel on 9/12/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Life : SKShapeNode {
    let heal: Int = 1
    
    // MARK: - Initialization -
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
        self.physicsBody?.collisionBitMask = PhysicsCategory.OuterBounds
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 0
        self.physicsBody?.friction = 0
        self.physicsBody?.allowsRotation = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onDestroy() {
        self.removeFromParent()
    }
}

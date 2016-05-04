//
//  Bouncer.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/4/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Bouncer : SKShapeNode {
    var prevPosition : CGPoint = CGPointZero
    var forward: CGPoint = CGPointMake(0.0, 1.0)
    var velocity: CGPoint = CGPointZero
    var delta: CGFloat
    
    // MARK: - Initialization -
    init(rectOfSize: CGSize) {
        self.delta = CGFloat(Int.random(100...500))
        
        super.init()
        
        let width = rectOfSize.width
        let height = rectOfSize.height
        let center = CGPoint(x: -width/2, y: -height/2)
        
        self.name = "bouncer"
        
        self.path = CGPathCreateWithRect(CGRect(origin: center, size: rectOfSize), nil)
        self.fillColor = SKColor.clearColor()
        self.strokeColor = SKColor.greenColor()
        self.lineWidth = 3
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: rectOfSize)
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Movement Controls -
    func move(deltaTime: NSTimeInterval) {
        prevPosition = position
        velocity = forward * delta
        position += velocity * CGFloat(deltaTime)
    }
    
    func reflectX(){
        forward.x *= CGFloat(-1.0)
    }
    
    func reflectY(){
        forward.y *= CGFloat(-1.0)
    }
}

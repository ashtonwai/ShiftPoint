//
//  Enemy.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/4/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import Foundation
import SpriteKit

class Enemy : SKShapeNode {
    var forward: CGPoint = CGPointMake(0.0, 1.0)
    var velocity: CGPoint = CGPointZero
    var delta: CGFloat = 300.0
    
    var lastUpdateTime: NSTimeInterval = 0
    var deltaTime: NSTimeInterval = 0
    
    init(rectOfSize: CGSize) {
        super.init()
        
        let width = rectOfSize.width
        let height = rectOfSize.height
        let center = CGPoint(x: -width/2, y: -height/2)
        
        self.path = CGPathCreateWithRect(CGRect(origin: center, size: rectOfSize), nil)
        self.fillColor = SKColor.greenColor()
        self.lineWidth = 0
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: rectOfSize)
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(currentTime: NSTimeInterval) {
        if lastUpdateTime > 0 {
            deltaTime = currentTime - lastUpdateTime
        } else {
            deltaTime = 0
        }
        lastUpdateTime = currentTime
        move(CGFloat(deltaTime))
    }
    
    func move(dt: CGFloat) {
        velocity = forward * delta
        position += velocity * dt
    }
    
    func reflectX(){
        forward.x *= CGFloat(-1.0)
    }
    
    func reflectY(){
        forward.y *= CGFloat(-1.0)
    }
}
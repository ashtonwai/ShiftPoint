//
//  Bullet.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 3/4/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Bullet : SKShapeNode {
    let bulletSpeed: CGFloat = CGFloat(Config.Player.BULLET_SPEED)
    let bulletMaxPower: Int = Config.Player.BULLET_POWER_MAX
    var bulletPower: Int = Config.Player.BULLET_POWER
    
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Movement Controls -
    func move(dx: CGFloat, dy: CGFloat) {
        self.physicsBody?.applyImpulse(CGVector(dx: dx * bulletSpeed, dy: dy * bulletSpeed))
    }
    
    
    // MARK: - Event Handlers -
    func onHit(damage: Int) {
        bulletPower -= damage
        if bulletPower <= 0 {
            onDestroy()
        }
    }
    
    func onDestroy() {
        self.removeFromParent()
    }
}

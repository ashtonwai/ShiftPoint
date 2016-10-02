//
//  Bullet.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 3/4/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Bullet: SKShapeNode {
    let bulletSpeed: CGFloat = Config.Bullet.BULLET_SPEED
    let bulletMaxPower: Int = Config.Bullet.BULLET_POWER_MAX
    var bulletPower: Int = Config.Bullet.BULLET_POWER
    
    // MARK: - Initialization -
    init(circleOfRadius: CGFloat) {
        super.init()
        
        let diameter = circleOfRadius * 2
        let center = CGPoint(x: -circleOfRadius, y: -circleOfRadius)
        let size = CGSize(width: diameter, height: diameter)
        
        self.name = "bullet"
        
        self.path = CGPath(ellipseIn: CGRect(origin: center, size: size), transform: nil)
        self.fillColor = SKColor.red
        self.lineWidth = 0
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
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
    
    
    // MARK: - Movement Controls -
    func move(_ dx: CGFloat, dy: CGFloat) {
        self.physicsBody?.applyImpulse(CGVector(dx: dx * bulletSpeed, dy: dy * bulletSpeed))
    }
    
    
    // MARK: - Event Handlers -
    func onHit(_ damage: Int) {
        bulletPower -= damage
        if bulletPower <= 0 {
            onDestroy()
        }
    }
    
    func onDestroy() {
        self.removeFromParent()
    }
}

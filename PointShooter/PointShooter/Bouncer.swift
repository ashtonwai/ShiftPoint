//
//  Bouncer.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/4/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Bouncer : Enemy {
    let score: Int = Config.Enemy.Bouncer.BOUNCER_SCORE
    let hp: Int = Config.Enemy.Bouncer.BOUNCER_HEALTH
    let color: SKColor = Config.Enemy.Bouncer.BOUNCER_COLOR
    let bouncerSize: CGSize = Config.Enemy.Bouncer.BOUNCER_SIZE
    
    var velocity: CGPoint = CGPointZero
    var delta: CGFloat
    
    // MARK: - Initialization -
    init() {
        self.delta = CGFloat(Int.random(10...30))
        
        super.init(size: bouncerSize, scorePoints: score, hitPoints: hp, typeColor: color)
        
        self.forward = CGPoint.randomUnitVector()
        
        let width = bouncerSize.width
        let height = bouncerSize.height
        let center = CGPoint(x: -width/2, y: -height/2)
        
        self.name = "bouncer"
        
        self.path = CGPathCreateWithRect(CGRect(origin: center, size: bouncerSize), nil)
        self.fillColor = SKColor.clearColor()
        self.strokeColor = color
        self.lineWidth = 3
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: bouncerSize)
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        self.physicsBody?.collisionBitMask = PhysicsCategory.OuterBounds
        self.physicsBody?.angularDamping = 0
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.friction = 0
        self.physicsBody?.allowsRotation = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Movement Controls -
    override func move() {
        self.physicsBody?.applyImpulse(CGVector(dx: forward.x * delta, dy: forward.y * delta))
    }
    
}

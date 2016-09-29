//
//  Bouncer.swift
//  ShiftPoint
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
    
    var velocity: CGPoint = CGPoint.zero
    var delta: CGFloat
    
    // MARK: - Initialization -
    init(pos: CGPoint, gameScene: GameScene) {
        self.delta = CGFloat(Int.random(20...30))
        
        super.init(size: bouncerSize, scorePoints: score, hitPoints: hp, typeColor: color, gameScene: gameScene)
        
        let threshold: CGFloat = 15
        let vector = CGPoint(
            x: CGFloat.random(cos(threshold * degreesToRadians), max:cos((180 - threshold) * degreesToRadians)),
            y: CGFloat.random(sin(threshold * degreesToRadians), max:sin((180 - threshold) * degreesToRadians))
        )
        self.forward = vector.normalized() // bottom facing up
        //self.forward = CGPoint.randomUnitVector()
        
        let width = bouncerSize.width
        let height = bouncerSize.height
        let center = CGPoint(x: -width/2, y: -height/2)
        
        self.name = "bouncer"
        self.position = pos
        self.zPosition = Config.GameLayer.Sprite
        
        self.path = CGPath(rect: CGRect(origin: center, size: bouncerSize), transform: nil)
        self.fillColor = SKColor.clear
        self.strokeColor = color
        self.lineWidth = 3
        
        self.physicsBody = SKPhysicsBody(rectangleOf: bouncerSize)
        self.physicsBody?.isDynamic = true
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

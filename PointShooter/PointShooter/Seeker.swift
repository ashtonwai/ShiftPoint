//
//  Seeker.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/9/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Seeker : Enemy {
    let points: Int = Config.Enemy.Seeker.SEEKER_SCORE
    let hp: Int = Config.Enemy.Seeker.SEEKER_HEALTH
    let color: SKColor = Config.Enemy.Seeker.SEEKER_COLOR
    let seekerSize: CGSize = Config.Enemy.Seeker.SEEKER_SIZE
    
    var velocity: CGPoint = CGPointZero
    var direction: CGPoint = CGPointZero
    var delta: CGFloat = 250.0
    var rotateSpeed: CGFloat = 3.0 * π
    
    // MARK: - Initialization -
    init(pos: CGPoint) {
        super.init(size: seekerSize, scorePoints: points, hitPoints: hp, typeColor: color)
        
        let pathToDraw = CGPathCreateMutable()
        CGPathMoveToPoint(pathToDraw, nil, 0, seekerSize.height/2)
        CGPathAddLineToPoint(pathToDraw, nil, seekerSize.width/2, -seekerSize.height/2)
        CGPathAddLineToPoint(pathToDraw, nil, -seekerSize.width/2, -seekerSize.height/2)
        CGPathAddLineToPoint(pathToDraw, nil, 0, seekerSize.height/2)
        CGPathCloseSubpath(pathToDraw)
        path = pathToDraw
        lineWidth = 3
        strokeColor = color
        fillColor = SKColor.clearColor()
        
        self.name = "seeker"
        self.position = pos
        self.zPosition = Config.GameLayer.Sprite
        
        self.physicsBody = SKPhysicsBody(polygonFromPath: path!)
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        self.physicsBody?.collisionBitMask = PhysicsCategory.PlayBounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Movement Controls -
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

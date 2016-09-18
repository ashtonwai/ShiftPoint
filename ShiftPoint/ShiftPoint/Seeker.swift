//
//  Seeker.swift
//  ShiftPoint
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
    
    var velocity: CGPoint = CGPoint.zero
    var direction: CGPoint = CGPoint.zero
    var delta: CGFloat = 250.0
    var rotateSpeed: CGFloat = 3.0 * π
    
    // MARK: - Initialization -
    init(pos: CGPoint) {
        super.init(size: seekerSize, scorePoints: points, hitPoints: hp, typeColor: color)
        
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: CGPoint(x: 0, y: seekerSize.height/2))
        pathToDraw.addLine(to: CGPoint(x: seekerSize.width/2, y: -seekerSize.height/2))
        pathToDraw.addLine(to: CGPoint(x: -seekerSize.width/2, y: -seekerSize.height/2))
        pathToDraw.addLine(to: CGPoint(x: 0, y: seekerSize.height/2))
//        CGPathMoveToPoint(pathToDraw, nil, 0, seekerSize.height/2)
//        CGPathAddLineToPoint(pathToDraw, nil, seekerSize.width/2, -seekerSize.height/2)
//        CGPathAddLineToPoint(pathToDraw, nil, -seekerSize.width/2, -seekerSize.height/2)
//        CGPathAddLineToPoint(pathToDraw, nil, 0, seekerSize.height/2)
        pathToDraw.closeSubpath()
        path = pathToDraw
        lineWidth = 3
        strokeColor = color
        fillColor = SKColor.clear
        
        self.name = "seeker"
        self.position = pos
        self.zPosition = Config.GameLayer.Sprite
        
        self.physicsBody = SKPhysicsBody(polygonFrom: path!)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        self.physicsBody?.collisionBitMask = PhysicsCategory.PlayBounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Movement Controls -
    func seek(_ deltaTime: TimeInterval, target: CGPoint) {
        let offset = target - self.position
        direction = offset.normalized()
        velocity = direction * delta
        position += velocity * CGFloat(deltaTime)
        
        // rotation
        let shortest = shortestAngleBetween(self.zRotation + π/2, angle2: velocity.angle)
        let amountToRotate = min(rotateSpeed * CGFloat(deltaTime), abs(shortest))
        self.zRotation += shortest.sign() * amountToRotate
    }
}

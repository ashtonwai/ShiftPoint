//
//  NinjaStar.swift
//  PointShooter
//
//  Created by Ashton Wai on 5/16/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class NinjaStar : Enemy {
    let points: Int = Config.Enemy.NinjaStar.NINJA_SCORE
    let hp: Int = Config.Enemy.NinjaStar.NINJA_HEALTH
    let color: SKColor = Config.Enemy.NinjaStar.NINJA_COLOR
    let ninjaSize: CGSize = Config.Enemy.NinjaStar.NINJA_SIZE
    
    init(pos: CGPoint) {
        super.init(size: ninjaSize, scorePoints: points, hitPoints: hp, typeColor: color)
        
        let width = ninjaSize.width
        let height = ninjaSize.height
        let center = CGPointMake(0, 0)
        
        self.name = "ninjaStar"
        self.position = pos
        self.zPosition = Config.GameLayer.Sprite
        
        let pathToDraw = CGPathCreateMutable()
        CGPathMoveToPoint(pathToDraw, nil, 0, height/3)
        CGPathAddLineToPoint(pathToDraw, nil, width/2, height/2)
        CGPathAddLineToPoint(pathToDraw, nil, width/3, 0)
        CGPathAddLineToPoint(pathToDraw, nil, width/2, -height/2)
        CGPathAddLineToPoint(pathToDraw, nil, 0, -height/3)
        CGPathAddLineToPoint(pathToDraw, nil, -width/2, -height/2)
        CGPathAddLineToPoint(pathToDraw, nil, -width/3, 0)
        CGPathAddLineToPoint(pathToDraw, nil, -width/2, height/2)
        CGPathCloseSubpath(pathToDraw)
        path = pathToDraw
        lineWidth = 3
        strokeColor = color
        fillColor = SKColor.clearColor()
        
        let circle = SKShapeNode(circleOfRadius: width/7)
        circle.position = center
        circle.strokeColor = color
        circle.fillColor = SKColor.clearColor()
        circle.lineWidth = 3
        addChild(circle)
        
        self.physicsBody = SKPhysicsBody(polygonFromPath: path!)
        self.physicsBody?.dynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

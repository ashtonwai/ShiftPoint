//
//  NinjaStar.swift
//  ShiftPoint
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
        let center = CGPoint(x: 0, y: 0)
        
        self.name = "ninjaStar"
        self.position = pos
        self.zPosition = Config.GameLayer.Sprite
        
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: CGPoint(x: 0, y: height/3))
        pathToDraw.addLine(to: CGPoint(x: width/2, y: height/2))
        pathToDraw.addLine(to: CGPoint(x: width/3, y: 0))
        pathToDraw.addLine(to: CGPoint(x: width/2, y: -height/2))
        pathToDraw.addLine(to: CGPoint(x: 0, y: -height/3))
        pathToDraw.addLine(to: CGPoint(x: -width/2, y: -height/2))
        pathToDraw.addLine(to: CGPoint(x: -width/3, y: 0))
        pathToDraw.addLine(to: CGPoint(x: -width/2, y: height/2))
        pathToDraw.closeSubpath()
        path = pathToDraw
        lineWidth = 3
        strokeColor = color
        fillColor = SKColor.clear
        
        let circle = SKShapeNode(circleOfRadius: width/7)
        circle.position = center
        circle.strokeColor = color
        circle.fillColor = SKColor.clear
        circle.lineWidth = 3
        addChild(circle)
        
        self.physicsBody = SKPhysicsBody(polygonFrom: path!)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

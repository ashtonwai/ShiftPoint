//
//  Giant.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 10/2/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Giant: Enemy {
    let points: Int = Config.Enemy.Giant.GIANT_SCORE
    let hp: Int = Config.Enemy.Giant.GIANT_HEALTH
    let color: SKColor = Config.Enemy.Giant.GIANT_COLOR
    let giantSize: CGSize = Config.Enemy.Giant.GIANT_SIZE
    var center: CGPoint!
    
    // MARK: - Initialization -
    init(pos: CGPoint, gameScene: GameScene) {
        super.init(size: giantSize, scorePoints: points, hitPoints: hp, typeColor: color, gameScene: gameScene)
        
        self.name = "giant"
        self.position = pos
        self.zPosition = Config.GameLayer.Sprite
        
        center = CGPoint(x: -giantSize.width/2, y: -giantSize.height/2)
        self.path = CGPath(ellipseIn: CGRect(origin: center, size: giantSize), transform: nil)
        self.fillColor = SKColor.clear
        self.strokeColor = color
        self.lineWidth = 3
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: giantSize.width/2, center: center)
        self.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        run(SKAction.repeatForever(grow()))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func grow() -> SKAction {
        return SKAction.customAction(withDuration: 1.0, actionBlock: { (node: SKNode!, elapsedTime: CGFloat) in
            node.xScale += 0.02
            node.yScale += 0.02
            let newBody = SKPhysicsBody(circleOfRadius: node.frame.width/2, center: self.center)
            newBody.categoryBitMask = PhysicsCategory.Enemy
            newBody.contactTestBitMask = PhysicsCategory.Bullet
            newBody.collisionBitMask = PhysicsCategory.None
            node.physicsBody = newBody
        })
    }
}

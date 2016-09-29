//
//  Enemy.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 5/7/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class Enemy : SKShapeNode {
    var size: CGSize
    var scorePoints: Int
    var hitPoints: Int
    var typeColor: SKColor
    var forward: CGPoint = CGPoint(x: 0.0, y: 1.0)
    var gameScene: GameScene
    
    let scoreSound: SKAction = SKAction.playSoundFileNamed("Score.mp3", waitForCompletion: false)
    
    // MARK: - Initialization -
    init(size: CGSize, scorePoints: Int, hitPoints: Int, typeColor: SKColor, gameScene: GameScene) {
        self.size = size
        self.scorePoints = scorePoints
        self.hitPoints = hitPoints
        self.typeColor = typeColor
        self.gameScene = gameScene
        super.init()
        
        gameScene.numOfEnemies += 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Particles -
    func explosion() -> SKEmitterNode {
        let emitter = SKEmitterNode(fileNamed: "Explosion")!
        emitter.particleColorSequence = nil
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColor = typeColor
        emitter.position = self.position
        emitter.zPosition = Config.GameLayer.Animation
        return emitter
    }
    
    func scoreMarker() -> SKLabelNode {
        let scoreMarker = SKLabelNode(fontNamed: Config.Font.MainFont)
        scoreMarker.fontColor = UIColor.cyan
        scoreMarker.fontSize = 30
        scoreMarker.text = "\(scorePoints)"
        scoreMarker.position = self.position
        scoreMarker.zPosition = Config.GameLayer.Sprite
        return scoreMarker
    }
    
    
    // MARK: - Event Handlers -
    func move() {
        fatalError("Must Override")
    }
    
    func onHit(_ damage: Int) -> Int {
        hitPoints -= damage
        if hitPoints <= 0 {
            onDestroy()
        }
        return hitPoints
    }
    
    func onDestroy() {
        gameScene.numOfEnemies -= 1
        self.removeFromParent()
    }
}

//
//  GameOverScene.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/5/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene : SKScene {
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "GameOver.png")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        background.xScale = 2
        background.yScale = 2
        self.addChild(background)
        
        //let gameTitle = SKLabelNode(fontNamed: "MicrogrammaDOT-MediumExtended")
        let gameover = SKLabelNode(fontNamed: "Inversionz")
        gameover.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        gameover.zPosition = 1
        gameover.horizontalAlignmentMode = .Center
        gameover.verticalAlignmentMode = .Center
        gameover.fontColor = UIColor.redColor()
        gameover.fontSize = 250
        gameover.text = "Game Over"
        self.addChild(gameover)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sceneTapped()
    }
    
    func sceneTapped() {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        let reveal = SKTransition.crossFadeWithDuration(1.5)
        self.view?.presentScene(gameScene, transition: reveal)
    }
}
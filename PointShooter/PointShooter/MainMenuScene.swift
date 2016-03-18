//
//  MainMenuScene.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/5/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene : SKScene {
    let startButton: SKLabelNode
    
    override init(size: CGSize) {
        self.startButton = SKLabelNode(fontNamed: Constants.Font.MainFont)
        
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu.png")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        background.xScale = 1.45
        background.yScale = 1.45
        addChild(background)
        
        let gameTitle = SKLabelNode(fontNamed: Constants.Font.TitleFont)
        gameTitle.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        gameTitle.zPosition = 1
        gameTitle.horizontalAlignmentMode = .Center
        gameTitle.verticalAlignmentMode = .Center
        gameTitle.fontSize = 200
        gameTitle.text = "Point Shooter"
        addChild(gameTitle)
        
        startButton.position = CGPoint(x: self.size.width/2, y: self.size.height/2-200)
        startButton.zPosition = 1
        startButton.horizontalAlignmentMode = .Center
        startButton.verticalAlignmentMode = .Center
        startButton.fontSize = 80
        startButton.text = "Start"
        startButton.alpha = 0
        addChild(startButton)
        
        runAction(SKAction.sequence([
            SKAction.runBlock() {
                gameTitle.runAction(SKAction.moveToY(self.size.height/2+300, duration: 1.0))
            },
            SKAction.waitForDuration(1.0),
            SKAction.runBlock() {
                self.startButton.runAction(SKAction.fadeInWithDuration(1.0))
            }
        ]))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            if nodeAtPoint(touch.locationInNode(self)) == startButton {
                startButton.fontColor = UIColor.cyanColor()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        startButton.fontColor = UIColor.whiteColor()
        for touch: AnyObject in touches {
            if nodeAtPoint(touch.locationInNode(self)) == startButton {
                startGame()
            }
        }
    }
    
    func startGame() {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        let reveal = SKTransition.crossFadeWithDuration(1.5)
        self.view?.presentScene(gameScene, transition: reveal)
    }
}
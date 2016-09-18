//
//  MainMenuScene.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 3/5/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene : SKScene {
    let userDefaults = UserDefaults.standard
    let gameManager: GameManager
    let startButton: SKLabelNode
    
    // MARK: - Initialization -
    init(size: CGSize, scaleMode: SKSceneScaleMode, gameManager: GameManager) {
        self.gameManager = gameManager
        self.startButton = SKLabelNode(fontNamed: Config.Font.MainFont)
        super.init(size: size)
        self.scaleMode = scaleMode
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu.png")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        background.xScale = 1.45
        background.yScale = 1.45
        addChild(background)
        
        let gameTitle = SKLabelNode(fontNamed: Config.Font.TitleFont)
        gameTitle.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        gameTitle.zPosition = 1
        gameTitle.horizontalAlignmentMode = .center
        gameTitle.verticalAlignmentMode = .center
        gameTitle.fontColor = UIColor.green
        gameTitle.fontSize = 200
        gameTitle.text = "Shift Point"
        addChild(gameTitle)
        
        startButton.position = CGPoint(x: self.size.width/2, y: self.size.height/2-200)
        startButton.zPosition = 1
        startButton.horizontalAlignmentMode = .center
        startButton.verticalAlignmentMode = .center
        startButton.fontSize = 80
        startButton.text = "Start"
        startButton.alpha = 0
        addChild(startButton)
        
        run(SKAction.sequence([
            SKAction.run() {
                gameTitle.run(SKAction.moveTo(y: self.size.height/2+300, duration: 1.0))
            },
            SKAction.wait(forDuration: 1.0),
            SKAction.run() {
                self.startButton.run(SKAction.fadeIn(withDuration: 1.0))
            }
        ]))
    }
    
    // MARK: - Event Handlers -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            if atPoint(touch.location(in: self)) == startButton {
                startButton.fontColor = UIColor.cyan
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        startButton.fontColor = UIColor.white
        for touch: AnyObject in touches {
            if atPoint(touch.location(in: self)) == startButton {
                startButton.fontColor = UIColor.white
                
                if userDefaults.bool(forKey: "skipTutorial") && Config.Developer.SkipTutorial {
                    gameManager.loadGameScene()
                } else {
                    gameManager.loadTutorialScene()
                }
            }
        }
    }
}

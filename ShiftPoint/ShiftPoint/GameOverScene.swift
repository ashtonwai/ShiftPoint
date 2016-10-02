//
//  GameOverScene.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 3/5/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    var gameManager: GameManager
    let userDefaults = UserDefaults.standard
    let highscore: Int
    let score: Int
    let playButton: SKLabelNode
    
    init(size: CGSize, scaleMode: SKSceneScaleMode, gameManager: GameManager, score: Int) {
        self.gameManager = gameManager
        self.score = score
        self.highscore = userDefaults.object(forKey: "highScore") != nil ? (userDefaults.value(forKey: "highScore") as? Int)! : 0
        self.playButton = SKLabelNode(fontNamed: Config.Font.MainFont)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "GameOver.png")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        background.xScale = 2
        background.yScale = 2
        addChild(background)
        
        let gameover = SKLabelNode(fontNamed: Config.Font.GameOverFont)
        gameover.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        gameover.zPosition = 1
        gameover.horizontalAlignmentMode = .center
        gameover.verticalAlignmentMode = .center
        gameover.fontColor = UIColor.red
        gameover.fontSize = 250
        gameover.text = "Game Over"
        addChild(gameover)
        
        let tagLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
        tagLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2+50)
        tagLabel.zPosition = 1
        tagLabel.fontColor = UIColor.green
        tagLabel.fontSize = 50
        if score > highscore {
            tagLabel.text = "NEW HIGH SCORE"
            userDefaults.setValue(score, forKey: "highScore")
            userDefaults.synchronize()
        } else {
            tagLabel.text = "Your Score"
        }
        tagLabel.alpha = 0
        addChild(tagLabel)
        
        let scoreLabel = SKLabelNode(fontNamed: Config.Font.MainFont)
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2-50)
        scoreLabel.zPosition = 1
        scoreLabel.fontColor = UIColor.green
        scoreLabel.fontSize = 100
        scoreLabel.text = "\(score)"
        scoreLabel.alpha = 0
        addChild(scoreLabel)
        
        playButton.position = CGPoint(x: self.size.width/2, y: self.size.height/2-400)
        playButton.zPosition = 1
        playButton.fontSize = 75
        playButton.text = "Play Again"
        playButton.alpha = 0
        addChild(playButton)
        
        run(SKAction.sequence([
            SKAction.run() {
                gameover.run(SKAction.moveTo(y: self.size.height/2+400, duration: 1.0))
            },
            SKAction.wait(forDuration: 1.0),
            SKAction.run() {
                tagLabel.run(SKAction.fadeIn(withDuration: 1.0))
                scoreLabel.run(SKAction.fadeIn(withDuration: 1.0))
            },
            SKAction.wait(forDuration: 1.0),
            SKAction.run() {
                self.playButton.run(SKAction.fadeIn(withDuration: 1.0))
            }
        ]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            if atPoint(touch.location(in: self)) == playButton {
                playButton.fontColor = UIColor.cyan
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playButton.fontColor = UIColor.white
        for touch: AnyObject in touches {
            if atPoint(touch.location(in: self)) == playButton {
                playButton.fontColor = UIColor.white
                gameManager.loadGameScene()
            }
        }
    }
}

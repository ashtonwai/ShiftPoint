//
//  GameOverScene.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/5/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class GameOverScene : SKScene {
    var gameManager: GameManager
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let highscore: Int
    let score: Int
    let playButton: SKLabelNode
    
    init(size: CGSize, scaleMode: SKSceneScaleMode, gameManager: GameManager, score: Int) {
        self.gameManager = gameManager
        self.score = score
        self.highscore = (userDefaults.valueForKey("highScore") as? Int)!
        self.playButton = SKLabelNode(fontNamed: Constants.Font.MainFont)
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
        addChild(background)
        
        let gameover = SKLabelNode(fontNamed: Constants.Font.GameOverFont)
        gameover.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        gameover.zPosition = 1
        gameover.horizontalAlignmentMode = .Center
        gameover.verticalAlignmentMode = .Center
        gameover.fontColor = UIColor.redColor()
        gameover.fontSize = 250
        gameover.text = "Game Over"
        addChild(gameover)
        
        let tagLabel = SKLabelNode(fontNamed: Constants.Font.MainFont)
        tagLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2+50)
        tagLabel.zPosition = 1
        tagLabel.fontColor = UIColor.greenColor()
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
        
        let scoreLabel = SKLabelNode(fontNamed: Constants.Font.MainFont)
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2-50)
        scoreLabel.zPosition = 1
        scoreLabel.fontColor = UIColor.greenColor()
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
        
        runAction(SKAction.sequence([
            SKAction.runBlock() {
                gameover.runAction(SKAction.moveToY(self.size.height/2+400, duration: 1.0))
            },
            SKAction.waitForDuration(1.0),
            SKAction.runBlock() {
                tagLabel.runAction(SKAction.fadeInWithDuration(1.0))
                scoreLabel.runAction(SKAction.fadeInWithDuration(1.0))
            },
            SKAction.waitForDuration(1.0),
            SKAction.runBlock() {
                self.playButton.runAction(SKAction.fadeInWithDuration(1.0))
            }
        ]))
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            if nodeAtPoint(touch.locationInNode(self)) == playButton {
                playButton.fontColor = UIColor.cyanColor()
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        playButton.fontColor = UIColor.whiteColor()
        for touch: AnyObject in touches {
            if nodeAtPoint(touch.locationInNode(self)) == playButton {
                gameManager.loadGameScene()
            }
        }
    }
}

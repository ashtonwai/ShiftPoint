//
//  PauseOverlay.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 10/1/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class PauseOverlay: SKSpriteNode {
    var gameManager: GameManager
    var gameViewManager: GameViewManager
    
    var resumeButton: SKLabelNode?
    var restartButton: SKLabelNode?
    var mainMenuButton: SKLabelNode?
    var settingsButton: SKLabelNode?
    
    // MARK: - Initialization -
    init(size: CGSize, gameManager: GameManager, gameViewManager: GameViewManager) {
        self.gameManager = gameManager
        self.gameViewManager = gameViewManager
        super.init(texture: nil, color: UIColor.clear, size: size)
        
        self.name = "pauseOverlay"
        self.alpha = 0
        
        let background = SKShapeNode(rectOf: size)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = Config.GameLayer.Overlay
        background.fillColor = UIColor.black
        background.alpha = 0.5
        addChild(background)
        
        let pauseLabel = SKLabelNode(fontNamed: Config.Font.GameOverFont)
        pauseLabel.position = CGPoint(x: size.width/2, y: size.height/2+250)
        pauseLabel.zPosition = Config.GameLayer.Overlay
        pauseLabel.fontColor = UIColor.cyan
        pauseLabel.fontSize = 200
        pauseLabel.text = "Paused"
        addChild(pauseLabel)
        
        resumeButton = SKLabelNode(fontNamed: Config.Font.MainFont)
        resumeButton?.position = CGPoint(x: size.width/2, y: size.height/2-250)
        resumeButton?.zPosition = Config.GameLayer.Overlay
        resumeButton?.fontSize = 60
        resumeButton?.text = "Resume"
        addChild(resumeButton!)
        
        restartButton = SKLabelNode(fontNamed: Config.Font.MainFont)
        restartButton?.position = CGPoint(x: size.width/2, y: size.height/2-350)
        restartButton?.zPosition = Config.GameLayer.Overlay
        restartButton?.fontSize = 60
        restartButton?.text = "Restart"
        addChild(restartButton!)
        
        settingsButton = SKLabelNode(fontNamed: Config.Font.MainFont)
        settingsButton?.position = CGPoint(x: size.width/2, y: size.height/2-450)
        settingsButton?.zPosition = Config.GameLayer.Overlay
        settingsButton?.fontSize = 60
        settingsButton?.text = "Settings"
        addChild(settingsButton!)
        
        mainMenuButton = SKLabelNode(fontNamed: Config.Font.MainFont)
        mainMenuButton?.position = CGPoint(x: size.width/2, y: size.height/2-550)
        mainMenuButton?.zPosition = Config.GameLayer.Overlay
        mainMenuButton?.fontSize = 60
        mainMenuButton?.text = "Main Menu"
        addChild(mainMenuButton!)
        
        run(SKAction.fadeIn(withDuration: 0.25))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Event Handlers -
    func onResume() {
        run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]))
    }
    
    func onRestart() {
        gameManager.loadGameScene()
    }
    
    func onSettings() {
        gameViewManager.showSettingsView()
    }
    
    func onMainMenu() {
        gameViewManager.showMainMenuView()
    }
}

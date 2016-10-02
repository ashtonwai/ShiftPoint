//
//  PauseOverlay.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 10/1/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

class PauseOverlay: SKSpriteNode {
    var resumeButton: SKLabelNode?
    
    init(size: CGSize, gameScene: GameScene) {
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
        
        run(SKAction.fadeIn(withDuration: 0.25))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onResume() {
        run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]))
    }
}

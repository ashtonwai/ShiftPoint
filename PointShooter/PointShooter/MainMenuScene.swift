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
    override init(size: CGSize) {
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
        self.addChild(background)
        
        let gameTitle = SKLabelNode(fontNamed: Constants.Font.TitleFont)
        gameTitle.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        gameTitle.zPosition = 1
        gameTitle.horizontalAlignmentMode = .Center
        gameTitle.verticalAlignmentMode = .Center
        gameTitle.fontSize = 200
        gameTitle.text = "Point Shooter"
        self.addChild(gameTitle)
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
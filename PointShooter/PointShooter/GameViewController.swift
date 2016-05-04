//
//  GameViewController.swift
//  PointShooter
//
//  Created by Ashton Wai on 2/25/16.
//  Copyright (c) 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameManager {
    let screenSize = CGSize(width: 2048, height: 1536)
    let scaleMode = SKSceneScaleMode.AspectFill
    var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        loadMainMenuScene()
    }
    
    
    // MARK: - Scene Navigation -
    func loadMainMenuScene() {
        let menuScene = MainMenuScene(size: screenSize, scaleMode: scaleMode, gameManager: self)
        let reveal = SKTransition.crossFadeWithDuration(1.0)
        skView.presentScene(menuScene, transition: reveal)
    }
    
    func loadGameScene() {
        let gameScene = GameScene(size: screenSize, scaleMode: scaleMode, gameManager: self)
        let reveal = SKTransition.crossFadeWithDuration(1.0)
        if Constants.Developer.DebugMode {
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
        if Constants.Developer.DebugPhysics {
            skView.showsPhysics = true
        }
        skView.presentScene(gameScene, transition: reveal)
    }
    
    func loadGameOverScene(score: Int) {
        let gameOverScene = GameOverScene(size: screenSize, scaleMode: scaleMode, gameManager: self, score: score)
        let reveal = SKTransition.crossFadeWithDuration(1.0)
        skView.presentScene(gameOverScene, transition: reveal)
    }
    
    
    // MARK: - View Lifecycle -
    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

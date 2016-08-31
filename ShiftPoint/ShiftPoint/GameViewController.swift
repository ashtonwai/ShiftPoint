//
//  GameViewController.swift
//  ShiftPoint
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
    var gameScene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        loadMainMenuScene()
        setupNotifications()
    }
    
    
    // MARK: - Scene Navigation -
    func loadMainMenuScene() {
        let menuScene = MainMenuScene(size: screenSize, scaleMode: scaleMode, gameManager: self)
        let reveal = SKTransition.crossFadeWithDuration(1.0)
        skView.presentScene(menuScene, transition: reveal)
    }
    
    func loadTutorialScene() {
        let tutorialScene = TutorialScene(size: screenSize, scaleMode: scaleMode, gameManager: self)
        tutorialScene.size = screenSize
        tutorialScene.scaleMode = scaleMode
        tutorialScene.gameManager = self
        let reveal = SKTransition.crossFadeWithDuration(1.0)
        skView.presentScene(tutorialScene, transition: reveal)
    }
    
    func loadGameScene() {
        gameScene = GameScene(size: screenSize, scaleMode: scaleMode, gameManager: self)
        let reveal = SKTransition.crossFadeWithDuration(1.0)
        if Config.Developer.DebugMode {
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
        if Config.Developer.DebugPhysics {
            skView.showsPhysics = true
        }
        skView.presentScene(gameScene!, transition: reveal)
    }
    
    func loadGameOverScene(score: Int) {
        let gameOverScene = GameOverScene(size: screenSize, scaleMode: scaleMode, gameManager: self, score: score)
        let reveal = SKTransition.crossFadeWithDuration(1.0)
        skView.presentScene(gameOverScene, transition: reveal)
    }
    
    
    // MARK: - Notifications -
    func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(GameViewController.willResignActive(_:)),
            name: UIApplicationWillResignActiveNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(GameViewController.didBecomeActive(_:)),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
    }
    
    func willResignActive(n:NSNotification){
        print("willResignActive notification")
        gameScene?.gameActive = false
    }
    
    func didBecomeActive(n:NSNotification){
        print("didBecomeActive notification")
        gameScene?.gameActive = true
    }
    
    func teardownNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self)
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

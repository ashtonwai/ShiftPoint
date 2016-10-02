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
    let userDefaults = UserDefaults.standard
    let screenSize = CGSize(width: 2048, height: 1536)
    let scaleMode = SKSceneScaleMode.aspectFill
    var skView: SKView!
    var gameScene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.becomeFirstResponder()
        skView = self.view as! SKView
        skView.ignoresSiblingOrder = true
        
        let skipTutorial = userDefaults.object(forKey: "skipTutorial") != nil ? (userDefaults.object(forKey: "skipTutorial") as! Bool) : Config.Settings.skipTutorial
        if !skipTutorial {
            loadTutorialScene()
        } else {
            loadGameScene()
        }
        setupNotifications()
    }
    
    
    // MARK: - Scene Navigation -
    func loadTutorialScene() {
        let tutorialScene = TutorialScene(size: screenSize, scaleMode: scaleMode, gameManager: self)
        tutorialScene.size = screenSize
        tutorialScene.scaleMode = scaleMode
        tutorialScene.gameManager = self
        let reveal = SKTransition.crossFade(withDuration: 1.0)
        skView.presentScene(tutorialScene, transition: reveal)
    }
    
    func loadGameScene() {
        gameScene = GameScene(size: screenSize, scaleMode: scaleMode, gameManager: self)
        let reveal = SKTransition.crossFade(withDuration: 1.0)
        if Config.Developer.DebugMode {
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
        if Config.Developer.DebugPhysics {
            skView.showsPhysics = true
        }
        skView.presentScene(gameScene!, transition: reveal)
    }
    
    func loadGameOverScene(_ score: Int) {
        let gameOverScene = GameOverScene(size: screenSize, scaleMode: scaleMode, gameManager: self, score: score)
        let reveal = SKTransition.crossFade(withDuration: 1.0)
        skView.presentScene(gameOverScene, transition: reveal)
    }
    
    
    // MARK: - Notifications -
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(GameViewController.willResignActive(_:)),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(GameViewController.didBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }
    
    func willResignActive(_ n:Notification){
        print("willResignActive notification")
        gameScene?.onGamePaused()
    }
    
    func didBecomeActive(_ n:Notification){
        print("didBecomeActive notification")
    }
    
    func teardownNotifications(){
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - View Lifecycle -
    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}

//
//  MenuViewController.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 9/27/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet weak var gameTitle: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var highScoreButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    var moveDistance: CGFloat = 200
    
    override func viewDidLoad() {
        // check resolution
        let screenSize: CGSize = CGSize(
            width: UIScreen.main.bounds.size.width * UIScreen.main.scale,
            height: UIScreen.main.bounds.size.height * UIScreen.main.scale)
        if screenSize != CGSize(width: 2048, height: 1536) {
            moveDistance *= 1.5
        }
        
        // fade in elements
        fadeInGameTitle()
    }
    
    func fadeInGameTitle() {
        UIView.animate(withDuration: 1.0, delay: 0.5, options: UIViewAnimationOptions.curveLinear, animations: {
            self.gameTitle.alpha = 1.0
        }, completion: { finished in
            UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.gameTitle.frame.origin.y -= self.moveDistance
            }, completion: { finished in
                self.fadeInStartButton()
                self.fadeInHighScoreButton()
                self.fadeInSettingsButton()
                self.fadeInAboutButton()
            })
        })
    }
    
    func fadeInStartButton() {
        UIView.animate(withDuration: 1.0, animations: {
            self.startButton.alpha = 1.0
        })
    }
    
    func fadeInHighScoreButton() {
        UIView.animate(withDuration: 1.0, delay: 0.25, animations: {
            self.highScoreButton.alpha = 1.0
        })
    }
    
    func fadeInSettingsButton() {
        UIView.animate(withDuration: 1.0, delay: 0.5, animations: {
            self.settingsButton.alpha = 1.0
        })
    }
    
    func fadeInAboutButton() {
        UIView.animate(withDuration: 1.0, delay: 0.75, animations: {
            self.aboutButton.alpha = 1.0
        })
    }
}

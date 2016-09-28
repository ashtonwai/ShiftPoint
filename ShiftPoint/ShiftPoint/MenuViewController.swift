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
    
    override func viewDidLoad() {
        UIView.animate(withDuration: 1.0, delay: 0.5, options: UIViewAnimationOptions.curveLinear, animations: {
            self.gameTitle.alpha = 1.0
        }, completion: { finished in
            UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.gameTitle.frame.origin.y -= 150
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
            self.startButton.frame.origin.y += 50
        })
    }
    
    func fadeInHighScoreButton() {
        UIView.animate(withDuration: 1.0, delay: 0.4, animations: {
            self.highScoreButton.alpha = 1.0
            self.highScoreButton.frame.origin.y += 50
        })
    }
    
    func fadeInSettingsButton() {
        UIView.animate(withDuration: 1.0, delay: 0.8, animations: {
            self.settingsButton.alpha = 1.0
            self.settingsButton.frame.origin.y += 50
        })
    }
    
    func fadeInAboutButton() {
        UIView.animate(withDuration: 1.0, delay: 1.2, animations: {
            self.aboutButton.alpha = 1.0
            self.aboutButton.frame.origin.y += 50
        })
    }
}

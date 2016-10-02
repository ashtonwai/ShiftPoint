//
//  SettingViewController.swift
//  ShiftPoint
//
//  Created by Ashton Wai on 9/27/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    @IBOutlet weak var musicSwitch: UISwitch!
    @IBOutlet weak var soundEffectSwitch: UISwitch!
    @IBOutlet weak var tutorialSwitch: UISwitch!
    @IBOutlet weak var musicSlider: UISlider!
    @IBOutlet weak var soundEffectSlider: UISlider!
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        // Background Music
        let musicEnable: Bool = userDefaults.object(forKey: "musicEnable") != nil ? (userDefaults.object(forKey: "musicEnable") as! Bool) : Config.Settings.musicEnable
        musicSwitch.setOn(musicEnable, animated: false)
        
        let musicVolumn: Float = userDefaults.object(forKey: "musicVolumn") != nil ? (userDefaults.object(forKey: "musicVolumn") as! Float) : Config.Settings.musicVolumn
        musicSlider.setValue(musicVolumn, animated: false)
        
        // Sound Effect
        let soundEffectEnable: Bool = userDefaults.object(forKey: "soundEffectEnable") != nil ? (userDefaults.object(forKey: "soundEffectEnable") as! Bool) : Config.Settings.soundEffectEnable
        soundEffectSwitch.setOn(soundEffectEnable, animated: false)
        
        let soundEffectVolumn: Float = userDefaults.object(forKey: "soundEffectVolumn") != nil ? (userDefaults.object(forKey: "soundEffectVolumn") as! Float) : Config.Settings.soundEffectVolumn
        soundEffectSlider.setValue(soundEffectVolumn, animated: false)
        
        // Skip Tutorial
        let skipTutorial: Bool = userDefaults.object(forKey: "skipTutorial") != nil ? (userDefaults.object(forKey: "skipTutorial") as! Bool) : Config.Settings.skipTutorial
        tutorialSwitch.setOn(skipTutorial, animated: false)
    }
    
    @IBAction func setMusicEnable(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: "musicEnable")
    }
    
    @IBAction func setSoundEffectEnable(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: "soundEffectEnable")
    }
    
    @IBAction func setSkipTutorial(_ sender: UISwitch) {
        userDefaults.set(sender.isOn, forKey: "skipTutorial")
    }
    
    @IBAction func setMusicVolumn(_ sender: UISlider) {
        userDefaults.set(sender.value, forKey: "musicVolumn")
    }
    
    @IBAction func setSoundEffectVolumn(_ sender: UISlider) {
        userDefaults.set(sender.value, forKey: "soundEffectVolumn")
    }
    
    @IBAction func returnToPreviousView(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

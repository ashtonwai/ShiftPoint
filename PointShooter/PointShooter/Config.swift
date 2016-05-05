//
//  Config.swift
//  PointShooter
//
//  Created by Ashton Wai on 3/14/16.
//  Copyright © 2016 Ashton Wai & Zachary Bebel. All rights reserved.
//

import SpriteKit

struct Config {
    struct Font {
        static let TitleFont = "6 Cells"
        static let GameOverFont = "Inversionz"
        static let MainFont = "MicrogrammaDOT-MediumExtended"
    }
    
    struct Developer {
        static let DebugMode = true
        static let DebugPhysics = false
        static let GodMode = false
        static let Endless = false
    }
    
    struct Enemy {
        static let BOUNCER_SCORE : Int = 10
    }
    
    struct GameLimit {
        static let MAX_BOUNCER  : Int = 20
        static let MAX_SEEKER   : Int = 4
    }
    
    struct GameLayer {
        static let Background   : CGFloat = 0
        static let Sprite       : CGFloat = 1
        static let Animation    : CGFloat = 2
        static let HUD          : CGFloat = 3
        static let Debug        : CGFloat = 4
        static let Overlay      : CGFloat = 5
    }
    
    struct Player {
        static let FIRE_RATE    : Float = 0.1
        static let BULLET_SPEED : Double = 1.0
        static let PLAYER_LIFE  : Int = 5
    }
}

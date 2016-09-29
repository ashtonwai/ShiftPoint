//
//  Config.swift
//  ShiftPoint
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
        static let GameUIColor      : UIColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 0.75)
        static let GameTextSize     : CGFloat = 50
        static let GameLabelSize    : CGFloat = 80
    }
    
    struct Developer {
        static let DebugMode     : Bool = true
        static let DebugPhysics  : Bool = false
        static let GodMode       : Bool = false
        static let Endless       : Bool = false
        static let SkipTutorial  : Bool = true
    }
    
    struct GameLayer {
        static let Background   : CGFloat = 0
        static let Sprite       : CGFloat = 1
        static let Animation    : CGFloat = 2
        static let HUD          : CGFloat = 3
        static let Debug        : CGFloat = 4
        static let Overlay      : CGFloat = 5
    }
    
    struct Settings {
        static let skipTutorial      : Bool = false
        static let musicEnable       : Bool = true
        static let musicVolumn       : Float = 1.0
        static let soundEffectEnable : Bool = true
        static let soundEffectVolumn : Float = 1.0
    }
    
    struct Player {
        static let FIRE_RATE        : Float = 0.2
        static let BULLET_SPEED     : Float = 50.0
        static let BULLET_POWER     : Int = 1
        static let BULLET_POWER_MAX : Int = 3
        static let PLAYER_LIFE      : Int = 5
        static let PLAYER_MAX_LIFE  : Int = 5
    }
    
    struct Enemy {
        static let ENEMY_MAX_SIZE     : CGSize = CGSize(width: 100, height: 100)
        struct Bouncer {
            static let BOUNCER_SCORE  : Int = 10
            static let BOUNCER_HEALTH : Int = 1
            static let BOUNCER_COLOR  : SKColor = SKColor.green
            static let BOUNCER_SIZE   : CGSize = CGSize(width: 50, height: 50)
        }
        struct Seeker {
            static let SEEKER_SCORE   : Int = 25
            static let SEEKER_HEALTH  : Int = 2
            static let SEEKER_COLOR   : SKColor = SKColor.red
            static let SEEKER_SIZE    : CGSize = CGSize(width: 50, height: 50)
        }
        struct NinjaStar {
            static let NINJA_SCORE    : Int = 50
            static let NINJA_HEALTH   : Int = 3
            static let NINJA_COLOR    : SKColor = SKColor.yellow
            static let NINJA_SIZE     : CGSize = CGSize(width: 50, height: 50)
        }
    }
    
    struct PowerUp {
        struct LifeUp {
            static let LIFEUP_ICON        : SKTexture = SKTexture.init(imageNamed: "LifeUp")
            static let LIFEUP_NAME        : String = "LIFE UP"
            static let LIFEUP_TIME        : Int = 7
            static let LIFEUP_ENEMY_COUNT : Int = 4
        }
    }
}

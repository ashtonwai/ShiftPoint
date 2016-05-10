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
        static let DebugMode     : Bool = true
        static let DebugPhysics  : Bool = false
        static let GodMode       : Bool = false
        static let Endless       : Bool = false
    }
    
    struct Enemy {
        struct Bouncer {
            static let BOUNCER_SCORE  : Int = 10
            static let BOUNCER_HEALTH : Int = 1
            static let BOUNCER_COLOR  : SKColor = SKColor.greenColor()
            static let BOUNCER_SIZE   : CGSize = CGSize(width: 50, height: 50)
        }
        struct Seeker {
            static let SEEKER_SCORE   : Int = 25
            static let SEEKER_HEALTH  : Int = 1
            static let SEEKER_COLOR   : SKColor = SKColor.redColor()
            static let SEEKER_SIZE    : CGSize = CGSize(width: 50, height: 50)
        }
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
        static let FIRE_RATE    : Float = 0.2
        static let BULLET_SPEED : Double = 1.0
        static let PLAYER_LIFE  : Int = 5
    }
}

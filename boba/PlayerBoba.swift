//
//  playerBoba.swift
//  boba
//
//  Created by Tracy Ma on 7/24/17.
//  Copyright © 2017 Tracy Ma. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayerBoba: SKSpriteNode, SKPhysicsContactDelegate {
    let swipeLeft: SKAction = SKAction.init(named: "swipeLeft")!
    let swipeRight: SKAction = SKAction.init(named: "swipeRight")!
    var direction: Direction = .none {
        didSet {
            if direction == .left {
                if !(self.position.x <= -89.9) {
                    run(swipeLeft)
                }
            } else if direction == .right {
                if !(self.position.x >= 90) {
                    run(swipeRight)
                }

            }
            
        }
    }

    override init(texture: SKTexture?, color: UIColor, size: CGSize) { //required for subclass to work
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) { //required for subclass to work
        super.init(coder: aDecoder)
    }
}

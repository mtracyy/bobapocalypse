//
//  EnemyBoba.swift
//  boba
//
//  Created by Tracy Ma on 7/27/17.
//  Copyright © 2017 Tracy Ma. All rights reserved.
//

import SpriteKit
import GameplayKit

class EnemyBoba: SKSpriteNode {
    
    
    
    
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) { //required for subclass to work
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) { //required for subclass to work
        super.init(coder: aDecoder)
    }


}

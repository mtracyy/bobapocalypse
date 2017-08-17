//
//  storeScreen.swift
//  boba
//
//  Created by Tracy Ma on 8/17/17.
//  Copyright © 2017 Tracy Ma. All rights reserved.
//

import SpriteKit

class storeScreen: SKScene {
    var homeButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        
        let bgMusic = SKAudioNode(fileNamed: "menuBGunity")
        self.addChild(bgMusic)
        
        homeButton = self.childNode(withName: "homeButton") as! MSButtonNode
        
        
        
        homeButton.selectedHandler = { [unowned self] in
            let skView = self.view as SKView!
            let scene = MainMenu(fileNamed: "MainMenu") as MainMenu!
            scene?.scaleMode = .aspectFill
            skView?.presentScene(scene)
        }
    }
}

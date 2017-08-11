//
//  MainMenu.swift
//  boba
//
//  Created by Tracy Ma on 8/8/17.
//  Copyright © 2017 Tracy Ma. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    var playButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        
        playButton = self.childNode(withName: "playButton") as! MSButtonNode
        
        playButton.selectedHandler = {
            self.loadGame()
        }
    }
    
    public func loadGame() {
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = GameScene(fileNamed:"GameScene") else {
            print("Could not make GameScene, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFill
        
        /* Show debug */
        skView.showsPhysics = true
        skView.showsDrawCount = true
        skView.showsFPS = true
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
}

//
//  extrasScreen.swift
//  boba
//
//  Created by Tracy Ma on 8/16/17.
//  Copyright © 2017 Tracy Ma. All rights reserved.
//

import SpriteKit

class extrasScreen: SKScene {
    var homeButton: MSButtonNode!
    var lvlTable: SKSpriteNode!
    var lvlSidewalk: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        lvlTable = self.childNode(withName: "lvlTable") as! SKSpriteNode
        lvlTable.isHidden = true
        
        lvlSidewalk = self.childNode(withName: "lvlSidewalk") as! SKSpriteNode
        lvlSidewalk.isHidden = true
        
        let bgMusic = SKAudioNode(fileNamed: "menuBGunity")
        self.addChild(bgMusic)
        
        homeButton = self.childNode(withName: "homeButton") as! MSButtonNode
        
        if UserDefaults().bool(forKey: "table") == true {
            lvlTable.isHidden = false
        }
        
        if UserDefaults().bool(forKey: "sidewalk") == true {
            lvlSidewalk.isHidden = false
        }
        
        
        homeButton.selectedHandler = { [unowned self] in
            let skView = self.view as SKView!
            let scene = MainMenu(fileNamed: "MainMenu") as MainMenu!
            scene?.scaleMode = .aspectFit
            skView?.presentScene(scene)
        }
    }
}

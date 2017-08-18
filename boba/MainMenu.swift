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
    var extrasButton: MSButtonNode!
    var storeButton: MSButtonNode!
    var creditsButton: MSButtonNode!
    
    var creditsTab: SKSpriteNode!
    var exitCredits: MSButtonNode!
    
    override func didMove(to view: SKView) {
        
        let bgMusic = SKAudioNode(fileNamed: "menuBGunity")
        self.addChild(bgMusic)
        
        playButton = self.childNode(withName: "playButton") as! MSButtonNode
        extrasButton = self.childNode(withName: "extrasButton") as! MSButtonNode
        storeButton = self.childNode(withName: "storeButton") as! MSButtonNode
        creditsButton = self.childNode(withName: "creditsButton") as! MSButtonNode
        creditsTab = self.childNode(withName: "creditsTab") as! SKSpriteNode
        exitCredits = creditsTab.childNode(withName: "exitCredits") as! MSButtonNode
        
        creditsTab.isHidden = true
        
        
        playButton.selectedHandler = { [unowned self] in
            savedCoins = nil
            savedScore = nil
            self.loadGame()
        }
        
        extrasButton.selectedHandler = { [unowned self] in
            let skView = self.view as SKView!
            let scene = extrasScreen(fileNamed: "extrasScreen") as extrasScreen!
            scene?.scaleMode = .aspectFill
            skView?.presentScene(scene)
        }
        
        storeButton.selectedHandler = { [unowned self] in
            let skView = self.view as SKView!
            let scene = storeScreen(fileNamed: "storeScreen") as storeScreen!
            scene?.scaleMode = .aspectFill
            skView?.presentScene(scene)
        }
        
        creditsButton.selectedHandler = { [unowned self] in
            self.creditsTab.isHidden = false
        }
        
        exitCredits.selectedHandler = { [unowned self] in
            self.creditsTab.isHidden = true
        }
    }
    
    public func loadGame() {
        /* 1) Grab reference to our SpriteKit view */
        theme = "tea"
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

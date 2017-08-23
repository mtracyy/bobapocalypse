//
//  GameScene.swift
//  boba
//
//  Created by Tracy Ma on 7/23/17.
//  Copyright © 2017 Tracy Ma. All rights reserved.
//

import SpriteKit
import GameplayKit

//public var coinCount: Int = 0
enum GameSceneState {
    case active, gameOver
}

var unlockedTable = UserDefaults.standard.bool(forKey: "table")
var unlockedSidewalk = UserDefaults.standard.bool(forKey: "sidewalk")

//enum themeState {
//    case tea, table
//}
var savedScore: Int?
var savedCoins: Int?

var theme = "tea"

enum Direction {
    case right, left, none
}

class GameScene: SKScene, SKPhysicsContactDelegate {
//    var worldNode: SKNode!
//    var pause = false
    
    var comingSoon: SKLabelNode?
    
    var coinCount = UserDefaults.standard.integer(forKey: "COINS")
    var highScore = UserDefaults.standard.integer(forKey: "HIGHSCORE")
    
    var firstTime = UserDefaults.standard.bool(forKey: "TUT")
    let tut: SKAction = SKAction.init(named: "tut")!
    
    let coinCollected: SKAction = SKAction.init(named: "coinCollect")!
    let bobaAbsorbed: SKAction = SKAction.init(named: "bobaAbsorb")!
    
    var fixedDelta: CFTimeInterval = 1.0 / 60.0
    let zoomOut: SKAction = SKAction.init(named: "zoomOut")!
    let flicker: SKAction = SKAction.init(named: "flicker")!
    let burst: SKAction = SKAction.init(named: "burst")!
    let fadeToWhite: SKAction = SKAction.init(named: "FadeToWhite")!
    let fadeIn: SKAction = SKAction.init(named: "fadeIn")!
    let fadeOut: SKAction = SKAction.init(named: "fadeOut")!
    let wait: SKAction = SKAction.wait(forDuration: 3.30)
    
    var ready = false
    var halt = false
    
    var gameState: GameSceneState = .active
    
    var playerBoba: PlayerBoba!
    var boss: SKSpriteNode!
    
    var fingerTut: SKNode!
    
    var coinLayer: SKNode!
    var teaLeaf: SKSpriteNode!
    var shadow: SKSpriteNode!
    var warning: SKSpriteNode!
    var crack: SKSpriteNode!
//    var glassLayer: SKNode!
    var whiteTransition: SKSpriteNode!
    
    var scrollLayer: SKNode!
    var enemySource: EnemyBoba!
    var enemyLayer: SKNode!
    var spawnTimer: CFTimeInterval = 0
    var coinTimer: CFTimeInterval = 0
    var scrollSpeed: CGFloat = 200
    var spawnVar: CFTimeInterval = 1.0
    var bossTimer: CFTimeInterval = 0
    var bossSpawnTime: CFTimeInterval = 15.0
    
    var scaleFactor: Double = 1.0
    var sizeLabel: SKLabelNode!
    
    var scoreLabel: SKLabelNode!
    var playerScore: Int = savedScore ?? 10 {
        didSet {
            updatePlayerSize()
        }
    }
    var coinScore: Int = savedCoins ?? 0 {
        didSet {
            if coinScore == 10 {
                coinLabel.position.x -= 10
            } else if coinScore == 100 {
                coinLabel.position.x -= 10
            } else if coinScore == 1000 {
                coinLabel.position.x -= 10
            }
        }
    }
    var coinLabel: SKLabelNode!

    var touchStartPoint:(location: CGPoint, time: TimeInterval)? //starting point of swipe; stores location and time
    let minDistance: CGFloat = 10 //parameters of swipe: distance, speed
    let minSpeed: CGFloat = 50
    let maxSpeed: CGFloat = 6000
    
    let locations = [70, 160, 250]
    
    //paused
    var pauseBG: SKSpriteNode!
    var pauseHome: MSButtonNode!
    var pauseResume: MSButtonNode!
    var pauseRestart: MSButtonNode!
    
    
    //buttons
    var buttonRestart: MSButtonNode!
    var pauseButton: MSButtonNode!
    var homeButton: MSButtonNode!
    
    //gameover
    var coinStatLabel: SKLabelNode!
    var totalCoinsLabel: SKLabelNode!
    var finalScoreLabel: SKLabelNode!
    var highScoreLabel: SKLabelNode!
    var newHighScore: SKSpriteNode!
    var endScoreBG: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        self.view?.showsPhysics = false
        self.view?.showsFPS = false
        self.view?.showsNodeCount = false
        self.view?.showsDrawCount = false

        comingSoon = self.childNode(withName: "comingSoon") as? SKLabelNode
        comingSoon?.isHidden = true
        
        let bgMusic = SKAudioNode(fileNamed: "mellow")
        self.addChild(bgMusic)
        
//        worldNode = self.childNode(withName: "worldNode")
        
        playerBoba = self.childNode(withName: "//playerBoba") as! PlayerBoba
        boss = self.childNode(withName: "boss") as! SKSpriteNode
        
        scrollLayer = self.childNode(withName: "scrollLayer")
        coinLayer = self.childNode(withName: "coinLayer")
        teaLeaf = self.childNode(withName: "teaLeaf") as! SKSpriteNode
        shadow = self.childNode(withName: "shadow") as! SKSpriteNode
        warning = shadow.childNode(withName: "warning") as! SKSpriteNode
        shadow.isHidden = true

        if UserDefaults().bool(forKey: "TUT") == false {
            fingerTut = self.childNode(withName: "fingerTut")
            fingerTut.position = CGPoint(x: 200, y: 306)
        }
        
        crack = self.childNode(withName: "crack") as? SKSpriteNode
        crack?.isHidden = true
//        glassLayer = self.childNode(withName: "glassNode")
        whiteTransition = self.childNode(withName: "whiteTransition") as? SKSpriteNode
        whiteTransition?.isHidden = true

        enemySource = self.childNode(withName: "//enemyBoba") as! EnemyBoba
        enemyLayer = self.childNode(withName: "enemyLayer")
        
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        sizeLabel = enemySource.childNode(withName: "//sizeLabel") as! SKLabelNode
        coinLabel = self.childNode(withName: "coinLabel") as! SKLabelNode
        coinStatLabel = self.childNode(withName: "coinStatLabel") as! SKLabelNode
        totalCoinsLabel = self.childNode(withName: "totalCoinsLabel") as! SKLabelNode
        finalScoreLabel = self.childNode(withName: "finalScoreLabel") as! SKLabelNode
        highScoreLabel = self.childNode(withName: "highScoreLabel") as! SKLabelNode
        newHighScore = self.childNode(withName: "newHighScore") as! SKSpriteNode
        endScoreBG = self.childNode(withName: "endScoreBG") as! SKSpriteNode
        
        scoreLabel.text = "\(playerScore)"
        coinLabel.text = "\(coinScore)"
        coinStatLabel.text = "\(coinScore)"
        totalCoinsLabel.text = "\(coinCount)"
        
        coinStatLabel.isHidden = true
        totalCoinsLabel.isHidden = true
        finalScoreLabel.isHidden = true
        highScoreLabel.isHidden = true
        newHighScore.isHidden = true
        endScoreBG.isHidden = true
        
        if theme == "table" || theme == "sidewalk" {
            scoreLabel.fontColor = UIColor.black
            coinLabel.fontColor = UIColor.black
        }
        
        if theme == "tea" {
            scoreLabel.fontColor = UIColor.white
            coinLabel.fontColor = UIColor.white
        }
        
        
        buttonRestart = self.childNode(withName: "buttonRestart") as! MSButtonNode
        buttonRestart.selectedHandler = { [unowned self] in
            savedScore = nil
            savedCoins = nil
            let skView = self.view as SKView! //grab ref to our spritekit view
            let scene = GameScene(fileNamed: "GameScene") as GameScene! //load game scene
            scene?.scaleMode = .aspectFit //ensure correct aspect mode
            theme = "tea"
            skView?.presentScene(scene) //restart game scene
            
        }
        buttonRestart.state = .hidden
        
        homeButton = self.childNode(withName: "homeButton") as! MSButtonNode
        homeButton.selectedHandler = { [unowned self] in
            let skView = self.view as SKView!
            let scene = MainMenu(fileNamed: "MainMenu") as MainMenu!
            scene?.scaleMode = .aspectFit
            skView?.presentScene(scene)
        }
        homeButton.state = .hidden
        
        pauseBG = self.childNode(withName: "pauseBG") as! SKSpriteNode
        pauseBG.isHidden = true
        
        pauseButton = self.childNode(withName: "pauseButton") as! MSButtonNode
        pauseButton.selectedHandler = { [unowned self] in
//            self.pause = true
            self.pauseBG.isHidden = false
            let pauseAction = SKAction.run {
                self.playerBoba.isPaused = true
                self.fixedDelta = 0.0
            }
            self.run(pauseAction)
        }
        
        pauseRestart = pauseBG.childNode(withName: "pauseRestart") as! MSButtonNode
        pauseRestart.selectedHandler = { [unowned self] in
            savedScore = nil
            savedCoins = nil
            let skView = self.view as SKView! //grab ref to our spritekit view
            let scene = GameScene(fileNamed: "GameScene") as GameScene! //load game scene
            scene?.scaleMode = .aspectFit //ensure correct aspect mode
            theme = "tea"
            skView?.presentScene(scene) //restart game scene
        }
        
        pauseHome = pauseBG.childNode(withName: "pauseHome") as! MSButtonNode
        pauseHome.selectedHandler = { [unowned self] in
            let skView = self.view as SKView!
            let scene = MainMenu(fileNamed: "MainMenu") as MainMenu!
            scene?.scaleMode = .aspectFit
            skView?.presentScene(scene)
        }
        
        pauseResume = pauseBG.childNode(withName: "pauseResume") as! MSButtonNode
        pauseResume.selectedHandler = { [unowned self] in
//            self.pause = false
            self.pauseBG.isHidden = true
            let unpauseAction = SKAction.run {
                self.boss.isPaused = false
                self.playerBoba.isPaused = false
                self.fixedDelta = 1.0 / 60.0
            }
            self.run(unpauseAction)
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState != .active { return }
        if let touch = touches.first { //saves location and time of first touch
            touchStartPoint = (touch.location(in:self), touch.timestamp)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if UserDefaults().bool(forKey: "TUT") == false {
//            removeTut()
//        }
        var swiped: Bool = false
        
        if let touch = touches.first, let startTime = self.touchStartPoint?.time, let startLocation = self.touchStartPoint?.location {
            let location = touch.location(in: self)
            let dx = location.x  - startLocation.x
            let dy = location.y - startLocation.y
            let distance = sqrt(dx*dx + dy*dy)
            
            if distance > minDistance { //check if user's finger moved at least min distance
                let deltaTime = CGFloat(touch.timestamp - startTime) // change in time from first touch to end touch
                let speed = distance / deltaTime
                
                if speed >= minSpeed && speed <= maxSpeed { //determines direction of swipe
                    let x = abs(dx/distance) > 0.4 ? Int(sign(Float(dx))) : 0
                    let y = abs(dy/distance) > 0.4 ? Int(sign(Float(dy))) : 0
                    
                    swiped = true
                    
                    if swiped {
                        UserDefaults().set(true, forKey: "TUT")
                        if UserDefaults().bool(forKey: "TUT") == true {
                            removeTut()
                        }
                        
                        switch (x, y) {
                        case (-1,0): //left
                            playerBoba.direction = .left
                        case (1,0): //right
                            playerBoba.direction = .right
                        case (1,1): //upright
                            playerBoba.direction = .right
                        case (-1,-1): //downleft
                            playerBoba.direction = .left
                        case (-1,1): //upleft
                            playerBoba.direction = .left
                        case (1,-1): //downright
                            playerBoba.direction = .right
                        default:
                            swiped = false
                            break
                        }
                    }
                }
            }
        }
    }

    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameState != .active { return }
        let contactA = contact.bodyA //get refs to body involved in collision
        let contactB = contact.bodyB
        
        let nodeA = contactA.node //as! SKSpriteNode  //get refs to physics body parent nodes
        let nodeB = contactB.node //as! SKSpriteNode
        
    
        if contactA.categoryBitMask == 2 && contactB.categoryBitMask == 1 {
            if let enemy = nodeA as? EnemyBoba, let player = nodeB as? PlayerBoba {
                if enemy.size.width <= player.size.width {
                    run(bobaAbsorbed)
                    playerScore += enemy.getPoints()
//                    print(player.size.width)
//                    scaleFactor = (Double(enemy.getPoints()) * 0.001) + 1
                    nodeA?.removeFromParent()
                    if scrollSpeed <= 350 {
                        scrollSpeed += 7
                    }
                    if spawnVar >= 0.5 {
                        spawnVar -= 0.05
                    }
                    
                } else {
                    gameState = .gameOver
                    setCoinTotal()
                    nodeB?.removeFromParent()
                }
            }
            scoreLabel.text = String(playerScore)
            return
        } else if contactA.categoryBitMask == 1 && contactB.categoryBitMask == 2 {
            if let enemy = nodeB as? EnemyBoba, let player = nodeA as? PlayerBoba {
                if enemy.size.width <= player.size.width {
                    run(bobaAbsorbed)
                    playerScore += enemy.getPoints()
//                    scaleFactor = (Double(enemy.getPoints()) * 0.001) + 1
//                    print(player.size.width)
                    nodeB?.removeFromParent()
                    if scrollSpeed <= 350 {
                        scrollSpeed += 7
                    }
                    if spawnVar >= 0.5 {
                        spawnVar -= 0.05
                    }
                } else {
                    gameState = .gameOver
                    setCoinTotal()
                    nodeA?.removeFromParent()
                }
            }
            scoreLabel.text = String(playerScore)
            return
        
        } else if contactA.categoryBitMask == 1 && contactB.categoryBitMask == 4 {
            if let leaf = nodeB as? SKSpriteNode {
                run(coinCollected)
                coinScore += 1
                leaf.removeFromParent()
            }
            coinLabel.text = String(coinScore)
            return
        } else if contactA.categoryBitMask == 4 && contactB.categoryBitMask == 1 {
            if let leaf = nodeA as? SKSpriteNode {
                run(coinCollected)
                coinScore += 1
                leaf.removeFromParent()
            }
            coinLabel.text = String(coinScore)
            return
        }
        
        if (contactA.categoryBitMask == 8 && contactB.categoryBitMask == 1) {
            if let player = nodeB as? SKSpriteNode {
                gameState = .gameOver
                player.removeFromParent()
            }
        } else if (contactA.categoryBitMask == 1 && contactB.categoryBitMask == 8) {
            if let player = nodeA as? SKSpriteNode {
                gameState = .gameOver
                player.removeFromParent()
            }
        }
        
        if (contactA.categoryBitMask == 8 && contactB.categoryBitMask == 2) || (contactA.categoryBitMask == 8 && contactB.categoryBitMask == 4) {
            if let toBeRemoved = nodeB as? SKSpriteNode {
                toBeRemoved.removeFromParent()
            }
        } else if (contactA.categoryBitMask == 2 && contactB.categoryBitMask == 8) || (contactA.categoryBitMask == 4 && contactB.categoryBitMask == 8) {
            if let toBeRemoved = nodeA as? SKSpriteNode {
                toBeRemoved.removeFromParent()
            }
        }
        
    
    }
    
    func removeTut() {
        if let fingerTut = fingerTut {
            fingerTut.removeFromParent()
        }
    }
    
    func updatePlayerSize() {
//        if playerScore > 900 && theme == "sidewalk" {
//            let grow: SKAction = SKAction.scale(by: CGFloat(scaleFactor), duration: 1.0)
//            playerBoba.run(grow)
//        }
//            let grow: SKAction = SKAction.scale(to: 1.1, duration: 1.0)
//            playerBoba.run(grow)
//        }
        
        for case let enemy as EnemyBoba in enemyLayer.children {
            for case let enemyLabel as SKLabelNode in enemy.children {
                if let label = Int(enemyLabel.text!) {
                    let zoomOutgen: SKAction = SKAction.scale(by: CGFloat(1/(scaleFactor*1.3)), duration: 0.5)
                    enemy.run(zoomOutgen)
                    
                    if (enemy.size.width > playerBoba.size.width) && (label < playerScore) {
                        let zoomOut: SKAction = SKAction.scale(by: CGFloat(playerBoba.size.width/enemy.size.width), duration: 0.5)
                        enemy.run(zoomOut)
                    } else if label == playerScore {
                        let adjust: SKAction = SKAction.scale(to: playerBoba.size, duration: 0.5)
                        enemy.run(adjust)
                    }
                }
            }
        }

        
    }
    
    func spawnBoss() {
        if theme == "tea" {
            boss.texture = SKTexture(imageNamed: "lgstrawrefhap")
        } else if theme == "table" {
            boss.texture = SKTexture(imageNamed: "armAsset 2")
        } else if theme == "sidewalk" {
            boss.texture = SKTexture(imageNamed: "leg")
        }
        
//        if pause == true { return }
        
        if bossTimer >= bossSpawnTime + Double(randomBetweenNumbers(firstNum: 5.0, secondNum: 15.0)) && playerBoba.size.width < 100.0 {
            boss.isHidden = false
            let bossSpawnLoc = CGPoint(x: locations.random(), y: Int(randomBetweenNumbers(firstNum: 250, secondNum: 400)))
            let wait1 = SKAction.wait(forDuration: 2.0)
            let wait2 = SKAction.wait(forDuration: 1.0)
            let shadowFin = SKAction.scale(by: (3.0/2.0), duration: 1.0)
            let shadowSpawn = SKAction.run {
                self.shadow.isHidden = false
                self.warning.run(self.flicker)
                let approach: SKAction = SKAction.scale(by: 2.0, duration: 2.0)
                self.shadow.position = bossSpawnLoc
                self.shadow.run(approach)
                
            }
            let bossSpawn = SKAction.run {
                self.shadow.run(shadowFin)
                self.boss.position = CGPoint(x: bossSpawnLoc.x, y: 960)
                let attack: SKAction = SKAction.move(to: CGPoint(x: bossSpawnLoc.x, y: bossSpawnLoc.y + (self.boss.size.height/2)), duration: 1.0)
                self.boss.run(attack)
            }
            let retreat = SKAction.run {
                let retreatBoss: SKAction = SKAction.moveTo(y: 1000, duration: 1.0)
                let retreatShadow: SKAction = SKAction.scale(by: (1/3.0), duration: 2.0)
                self.boss.run(retreatBoss)
                self.shadow.run(retreatShadow)
            }
            let end = SKAction.run {
                self.shadow.isHidden = true
            }
            let spawn = SKAction.sequence([shadowSpawn, wait1, bossSpawn, wait2, retreat, wait1, end])

            self.run(spawn)
            bossTimer = 0
        }
    }
    
    func updateEnemies() {
    
        enemyLayer.position.y += scrollSpeed * CGFloat(fixedDelta)
        for enemy in enemyLayer.children {
            let enemyPos = enemyLayer.convert(enemy.position, to: self)
            if enemyPos.y  >= 650 {
                enemy.removeFromParent()
            }
        }
        
        if spawnTimer >= spawnVar {
            let spawnLoc = CGPoint(x: locations.random(), y: -50)
            let newEnemy = enemySource.copy() as! EnemyBoba
            let newSize = sizeLabel.copy() as! SKLabelNode
            let newScale = randomBetweenNumbers(firstNum: 0.2, secondNum: 1.2)
            
            if theme == "tea" {
                newEnemy.texture = SKTexture(imageNamed: "test_0005_Layer-1-copy-4")
            } else if theme == "table" {
                if newScale <= 0.6 {
                    newEnemy.texture = SKTexture(imageNamed: "donut")
                } else if newScale > 0.6 && newScale <= 1.0 {
                    newEnemy.texture = SKTexture(imageNamed: "breakfast")
                } else if newScale > 1.0 {
                    newEnemy.texture = SKTexture(imageNamed: "pizza")
                }
                newSize.fontColor = UIColor.black
                
            } else if theme == "sidewalk" {
                if newScale <= 0.4 {
                    newEnemy.texture = SKTexture(imageNamed: "gum")
                }else if newScale > 0.4 && newScale <= 0.6  {
                    newEnemy.texture = SKTexture(imageNamed: "apple")
                } else if newScale > 0.6 && newScale <= 1.0 {
                    newEnemy.texture = SKTexture(imageNamed: "drink6")
                } else if newScale > 1.0 {
                    newEnemy.texture = SKTexture(imageNamed: "pigeon")
                }
                newSize.fontColor = UIColor.white
            }
            
            newEnemy.setScale(CGFloat(newScale))
            newSize.text = "\(Int(newEnemy.getPoints() + (playerScore - 10)))"
            newEnemy.position = self.convert(spawnLoc, to: enemyLayer)
//            newSize.position = self.convert(spawnLoc, to: enemySource)
            enemyLayer.addChild(newEnemy)
            newEnemy.addChild(newSize)
            spawnTimer = 0
        }
    }
    
    func updateCoins() {
        coinLayer.position.y += scrollSpeed * CGFloat(fixedDelta)
        for coin in coinLayer.children {
            let coinPos = enemyLayer.convert(coin.position, to: self)
            if coinPos.y  >= 600 {
                coin.removeFromParent()
            }
        }
        
        if coinTimer > spawnVar + Double(randomBetweenNumbers(firstNum: 0.5, secondNum: 1.0)) {
            let spawnLoc = CGPoint(x: locations.random(), y: -100)
            let newCoin = teaLeaf.copy() as! SKSpriteNode
            newCoin.position = self.convert(spawnLoc, to: coinLayer)
            coinLayer.addChild(newCoin)
            coinTimer = 0
        }
    }
    
    func scrollWorld() {
        if theme == "tea" {
            scrollLayer.position.y += 50 * CGFloat(fixedDelta)
            for bubbles in scrollLayer.children as! [SKSpriteNode] {
                let bubblesPos = scrollLayer.convert(bubbles.position, to: self)
                if bubblesPos.y  >= bubbles.size.height * 1.5 {
                    let newPos = CGPoint(x: bubblesPos.x, y: -(bubbles.size.height / 2 ))
                    bubbles.position = self.convert(newPos, to: scrollLayer)
                }
            }
        } else if theme == "table" || theme == "sidewalk" {
            scrollLayer.position.y += scrollSpeed * CGFloat(fixedDelta)
            for bubbles in scrollLayer.children as! [SKSpriteNode] {
                let bubblesPos = scrollLayer.convert(bubbles.position, to: self)
                if bubblesPos.y  >= (bubbles.size.height * 1.5) - (round(scrollSpeed * 0.03)) {
                    let newPos = CGPoint(x: bubblesPos.x, y: round(-(bubbles.size.height / 2) /*+ (scrollSpeed * 0.28)*/))
                    bubbles.position = self.convert(newPos, to: scrollLayer)
                }
            }
        }
        
    }
    func transition() {
//        let gravityField = SKFieldNode.radialGravityField()
//        gravityField.categoryBitMask = 16
//        gravityField.strength = -0.25
        let growHuge: SKAction = SKAction.scale(to: 50, duration: 15.0)
        let playerEv = SKAction.run {
            self.fixedDelta = 0.0
            self.playerBoba.physicsBody?.categoryBitMask = 0
            self.playerBoba.run(growHuge)
        }
        
        let waitGlass = SKAction.wait(forDuration: 2.5)
        let waitWhite = SKAction.wait(forDuration: 0.5)
        
        let glassCrack = SKAction.run {
//            print("glass should crack")
            self.crack.isHidden = false
            self.crack.run(self.burst)
        }
        
//        let glassShards = SKAction.run {
//            print("shards should show")
//            gravityField.isEnabled = true
//            gravityField.position = CGPoint(x: 160, y: 284)
////            for glass in self.glassLayer.children as! [SKSpriteNode] {
////                glass.physicsBody?.fieldBitMask = 16
////            }
////        self.glassLayer.position = CGPoint(x: 160, y: 268)
//        self.addChild(gravityField)
//        
//        }
        
        let endTransition = SKAction.run {
//            print("fade should happen")
            self.whiteTransition.isHidden = false
            let fadeIn = SKAction.run{
                self.whiteTransition.run(self.fadeIn)
            }
            let fadeOut = SKAction.run{
                self.whiteTransition.run(self.fadeOut)
            }
            let fadeSeq = SKAction.sequence([fadeIn, waitWhite, fadeOut])
            self.whiteTransition.run(fadeSeq)
        }
        
        let breakGlass = SKAction.sequence([glassCrack, playerEv, /*glassShards,*/ waitGlass, endTransition])
        self.run(breakGlass)
    }
    
    func loadNextLevel(levelName: String, themeName: String) {
        savedScore = playerScore
        savedCoins = coinScore
        theme = themeName
        self.whiteTransition.run(self.fadeOut)
        
        /* 1) Grab reference to our SpriteKit view */
        guard let skView = self.view as SKView! else {
            print("Could not get Skview")
            return
        }
        
        /* 2) Load Game scene */
        guard let scene = GameScene(fileNamed:"\(levelName)") else {
            print("Could not make GameScene2, check the name is spelled correctly")
            return
        }
        
        /* 3) Ensure correct aspect mode */
        scene.scaleMode = .aspectFit
        
        /* Show debug */
        skView.showsPhysics = true
        skView.showsDrawCount = true
        skView.showsFPS = true
        
        /* 4) Start game scene */
        skView.presentScene(scene)
    }
    
    func saveHighScore() {
//        highScore = UserDefaults().integer(forKey: "HIGHSCORE")
        UserDefaults().set(playerScore, forKey: "HIGHSCORE")
    }
    
    func setCoinTotal() {
        coinCount += coinScore
        UserDefaults().set(coinCount, forKey: "COINS")
    }
    
//    func sizeAdjust() {
//        playerBoba.removeAllActions()
//        for enemy in enemyLayer.children as! [SKSpriteNode] {
//            enemy.removeAllActions()
//        }
//        let endGrow: SKAction = SKAction.scale(to: 200, duration: 2.0)
//        playerBoba.run(endGrow)
//    }
    
    func transitionToNextLevel(levelName: String, themeName: String) {
        let trans1: SKAction = SKAction.run {
            self.transition()
        }
        let trans2: SKAction = SKAction.run {
            self.loadNextLevel(levelName: "\(levelName)", themeName: "\(themeName)")
        }
        let transitionSeq = SKAction.sequence([trans1, wait, trans2])
        run(transitionSeq)
    }
    
    func checkTransition(){
        if halt {
            ready = false
        } else {
            ready = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
//        print(playerBoba.size.width)
        scrollWorld()
        updateEnemies()
        updateCoins()
        spawnBoss()
        spawnTimer += fixedDelta
        coinTimer += fixedDelta
        bossTimer += fixedDelta
        
        if gameState == .gameOver {
            if let fingerTut = fingerTut {
                fingerTut.isHidden = true
            }
            
            if playerScore > highScore {
                newHighScore.isHidden = false
                saveHighScore()
            }
            
            if playerScore >= 900 && theme == "sidewalk" {
                comingSoon?.isHidden = false
            }
            
            buttonRestart.state = .active
            homeButton.state = .active
            coinStatLabel.text = "\(coinScore)"
            totalCoinsLabel.text = "\(UserDefaults().integer(forKey: "COINS"))"
            finalScoreLabel.text = "\(playerScore)"
            highScoreLabel.text = "\(UserDefaults().integer(forKey: "HIGHSCORE"))"
            
            coinStatLabel.isHidden = false
            totalCoinsLabel.isHidden = false
            finalScoreLabel.isHidden = false
            highScoreLabel.isHidden = false
            endScoreBG.isHidden = false
            
            savedScore = nil
        }
        
        
        if playerScore >= 300 && theme == "tea" {
            UserDefaults().set(true, forKey: "table")
            checkTransition()
            if ready {
                transitionToNextLevel(levelName: "GameScene2", themeName: "table")
                halt = true
                ready = false
            }
        }
        
        if playerScore >= 600 && theme == "table" {
            UserDefaults().set(true, forKey: "sidewalk")
            checkTransition()
            if ready {
                transitionToNextLevel(levelName: "GameScene3", themeName: "sidewalk")
                halt = true
                ready = false
            }
        }
        
    }
    
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
}

extension Array {
    func random() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

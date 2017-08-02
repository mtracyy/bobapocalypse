//
//  GameScene.swift
//  boba
//
//  Created by Tracy Ma on 7/23/17.
//  Copyright © 2017 Tracy Ma. All rights reserved.
//

import SpriteKit
import GameplayKit

public var coinCount: Int = 0
enum GameSceneState {
    case active, gameOver
}

enum Direction {     
    case right, left, none
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let fixedDelta: CFTimeInterval = 1.0 / 60.0
    let zoomOut: SKAction = SKAction.init(named: "zoomOut")!
    
    var gameState: GameSceneState = .active
    
    var playerBoba: PlayerBoba!
    
    var coinLayer: SKNode!
    var teaLeaf: SKSpriteNode!
    var scrollLayer: SKNode!
    var enemySource: EnemyBoba!
    var enemyLayer: SKNode!
    var spawnTimer: CFTimeInterval = 0
    var coinTimer: CFTimeInterval = 0
    var scrollSpeed: CGFloat = 200
    var spawnVar: CFTimeInterval = 1.0
    
    var scaleFactor: Double = 1.0
    var sizeLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var playerScore: Int = 10 {
        didSet {
            updatePlayerSize()
        }
    }
    var coinScore: Int = 0 {
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
    
    //gameover
    var buttonRestart: MSButtonNode!
//    var coinStatLabel: SKLabelNode!
//    var totalCoinsLabel: SKLabelNode!
    var coinStat: SKLabelNode!
    var totalCoins: SKLabelNode!
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        playerBoba = self.childNode(withName: "//playerBoba") as! PlayerBoba
        
        scrollLayer = self.childNode(withName: "scrollLayer")
        coinLayer = self.childNode(withName: "coinLayer")
        teaLeaf = self.childNode(withName: "teaLeaf") as! SKSpriteNode
        
        enemySource = self.childNode(withName: "//enemyBoba") as! EnemyBoba
        enemyLayer = self.childNode(withName: "enemyLayer")
        
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        sizeLabel = enemySource.childNode(withName: "//sizeLabel") as! SKLabelNode
        coinLabel = self.childNode(withName: "coinLabel") as! SKLabelNode
        coinStat = self.childNode(withName: "coinStat") as! SKLabelNode
        totalCoins = self.childNode(withName: "totalCoins") as! SKLabelNode
        
        scoreLabel.text = "\(playerScore)"
        coinLabel.text = "\(coinScore)"
        coinStat.text = "\(coinScore)"
        totalCoins.text = "\(coinCount)"
        
        buttonRestart = self.childNode(withName: "buttonRestart") as! MSButtonNode
        buttonRestart.selectedHandler = { [unowned self] in
            let skView = self.view as SKView! //grab ref to our spritekit view
            let scene = GameScene(fileNamed: "GameScene") as GameScene! //load game scene
            scene?.scaleMode = .aspectFill //ensure correct aspect mode
            skView?.presentScene(scene) //restart game scene
            
        }
        
        buttonRestart.state = .hidden
        coinStat.isHidden = true
        totalCoins.isHidden = true
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState != .active { return }
        if let touch = touches.first { //saves location and time of first touch
            touchStartPoint = (touch.location(in:self), touch.timestamp)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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
                    playerScore += enemy.getPoints()
                    print(player.size.width)
                    scaleFactor = (Double(enemy.getPoints()) * 0.001) + 1
                    print(player.size.width)
                    nodeA?.removeFromParent()
                    if scrollSpeed <= 350 {
                        scrollSpeed += 7
                    }
                    if spawnVar >= 0.5 {
                        spawnVar -= 0.05
                    }
//                    enumerateChildNodes(withName: "sizeLabel*", using:
//                        { (node, stop) -> Void in
//                            let nodeAPos = self.enemyLayer.convert((nodeA?.position)!, to: self)
//                            let node1 = self.enemyLayer.convert(node.position, to: self)
//                            if ((node as? SKLabelNode) != nil) && nodeAPos == node1 {
//                                node.removeFromParent()
//                            }
//                            print(nodeAPos)
//                            print(node)
//                    })
//                    print(enemy.size.width)
                    
                } else {
                    gameState = .gameOver
                    if coinCount == 0 {
                        coinCount = coinScore
                    } else {
                        coinCount += coinScore
                    }
                    nodeB?.removeFromParent()
                }
            }
            scoreLabel.text = String(playerScore)
            return
        } else if contactA.categoryBitMask == 1 && contactB.categoryBitMask == 2 {
            if let enemy = nodeB as? EnemyBoba, let player = nodeA as? PlayerBoba {
                if enemy.size.width <= player.size.width {
                    playerScore += enemy.getPoints()
                    scaleFactor = (Double(enemy.getPoints()) * 0.001) + 1
                    print(player.size.width)
                    nodeB?.removeFromParent()
                    if scrollSpeed <= 350 {
                        scrollSpeed += 7
                    }
                    if spawnVar >= 0.5 {
                        spawnVar -= 0.05
                    }
//                    enumerateChildNodes(withName: "sizeLabel*", using:
//                        { (node, stop) -> Void in
//                            let nodeBPos = self.enemyLayer.convert((nodeB?.position)!, to: self)
//                            let node1 = self.enemyLayer.convert(node.position, to: self)
//                            if ((node as? SKLabelNode) != nil) && nodeBPos == node1 {
//                                node.removeFromParent()
//                            }
//                            print(nodeBPos)
//                            print(node)
//                    })
//                    print(enemy.size.width)
                } else {
                    gameState = .gameOver
                    if coinCount == 0 {
                        coinCount = coinScore
                    } else {
                        coinCount += coinScore
                    }
                    nodeA?.removeFromParent()
                }
            }
            scoreLabel.text = String(playerScore)
            return
        
        } else if contactA.categoryBitMask == 1 && contactB.categoryBitMask == 4 {
            if let leaf = nodeB as? SKSpriteNode {
                coinScore += 1
                leaf.removeFromParent()
            }
            coinLabel.text = String(coinScore)
            return
        } else if contactA.categoryBitMask == 4 && contactB.categoryBitMask == 1 {
            if let leaf = nodeA as? SKSpriteNode {
                coinScore += 1
                leaf.removeFromParent()
            }
            coinLabel.text = String(coinScore)
            return
        }
        
    
    }
    
    func updatePlayerSize() {
        let grow: SKAction = SKAction.scale(by: CGFloat(scaleFactor), duration: 1.0)
        playerBoba.run(grow)
        
        for case let enemy as EnemyBoba in enemyLayer.children {
            for case let enemyLabel as SKLabelNode in enemy.children {
                if let label = Int(enemyLabel.text!) {
                    if (enemy.size.width > playerBoba.size.width) && label < playerScore {
                        let zoomOut: SKAction = SKAction.scale(by: CGFloat(playerBoba.size.width/enemy.size.width), duration: 1.0)
                        enemy.run(zoomOut)
                    } else if label == playerScore {
                        let adjust: SKAction = SKAction.scale(to: playerBoba.size, duration: 1.0)
                        enemy.run(adjust)
                    } else if (enemy.size.width > playerBoba.size.width && label > playerScore) || (enemy.size.width < playerBoba.size.width && label < playerScore) {
                        let zoomOutgen: SKAction = SKAction.scale(by: CGFloat(1/(scaleFactor * 1.3)), duration: 1.0)
                        enemy.run(zoomOutgen)
                    }
                }
            }
        }

        
    }
//        for enemy in enemyLayer.children {
//            if enemy.xScale > 1.0 {
//                let zoomOut: SKAction = SKAction.scale(by: CGFloat(1/scaleFactor), duration: 1.0)
//                enemy.run(zoomOut)
//            }
//        }
//    func updateEnemySize() {
//        for case let enemy as EnemyBoba in enemyLayer.children {
//            if (playerScore > (enemy.getPoints() + (playerScore-10))) && (enemy.size.width > playerBoba.size.width) {
//                let zoomOut: SKAction = SKAction.scale(by: CGFloat(1/(scaleFactor*2)), duration: 1.0)
//                enemy.run(zoomOut)
//            }
//        }
//    }
    
    func updateEnemies() {
    
        enemyLayer.position.y += scrollSpeed * CGFloat(fixedDelta)
        for enemy in enemyLayer.children {
            let enemyPos = enemyLayer.convert(enemy.position, to: self)
            if enemyPos.y  >= 620 {
                enemy.removeFromParent()
            }
        }
        
        if spawnTimer >= spawnVar {
            let spawnLoc = CGPoint(x: locations.random(), y: -50)
            let newEnemy = enemySource.copy() as! EnemyBoba
            let newSize = sizeLabel.copy() as! SKLabelNode
            let newScale = randomBetweenNumbers(firstNum: 0.2, secondNum: 1.5)
            newEnemy.setScale(CGFloat(newScale))
//            if let newSize = newEnemy.childNode(withName: "sizeLabel")?.copy() as? SKLabelNode {
//                newSize.text = "\(newEnemy.getPoints())"
////              newSize.position = self.convert(spawnLoc, to: enemyLayer)
//                newEnemy.addChild(newSize)
//            }
            newSize.text = "\(Int(newEnemy.getPoints() + (playerScore - 10)))"
            newSize.fontSize = 15
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
        scrollLayer.position.y += 50 * CGFloat(fixedDelta)
        for bubbles in scrollLayer.children as! [SKSpriteNode] {
            let bubblesPos = scrollLayer.convert(bubbles.position, to: self)
            if bubblesPos.y  >= bubbles.size.height * 1.5 {
                let newPos = CGPoint(x: bubblesPos.x, y: -(bubbles.size.height / 2 ))
                bubbles.position = self.convert(newPos, to: scrollLayer)
            }
        }
        
    }
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first! as! UITouch
//    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameState == .gameOver {
            buttonRestart.state = .active
            coinStat.text = "\(coinScore)"
            totalCoins.text = "\(coinCount)"
            coinStat.isHidden = false
            totalCoins.isHidden = false
        }
        
        scrollWorld()
        updateEnemies()
        updateCoins()
        spawnTimer += fixedDelta
        coinTimer += fixedDelta
//        print(playerBoba.position.x)
        
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

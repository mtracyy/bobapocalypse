//
//  GameScene.swift
//  boba
//
//  Created by Tracy Ma on 7/23/17.
//  Copyright © 2017 Tracy Ma. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GameSceneState {
    case active, gameOver
}

enum Direction {     
    case right, left, none
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let fixedDelta: CFTimeInterval = 1.0 / 60.0
    var gameState: GameSceneState = .active
    
    var playerBoba: PlayerBoba!
    var buttonRestart: MSButtonNode!
    
    var scrollLayer: SKNode!
    var enemySource: EnemyBoba!
    var enemyLayer: SKNode!
    var spawnTimer: CFTimeInterval = 0
    var scrollSpeed: CGFloat = 200
    var spawnVar: CFTimeInterval = 1.0
    
    var sizeLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var playerScore: Int = 10
    var touched = false

    var touchStartPoint:(location: CGPoint, time: TimeInterval)? //starting point of swipe; stores location and time
    let minDistance: CGFloat = 10 //parameters of swipe: distance, speed
    let minSpeed: CGFloat = 50
    let maxSpeed: CGFloat = 6000
    
    let locations = [70, 160, 250]
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        playerBoba = self.childNode(withName: "//playerBoba") as! PlayerBoba
        
        scrollLayer = self.childNode(withName: "scrollLayer")
        
        enemySource = self.childNode(withName: "//enemyBoba") as! EnemyBoba
        enemyLayer = self.childNode(withName: "enemyLayer")
        
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        sizeLabel = self.childNode(withName: "sizeLabel") as! SKLabelNode
        
        scoreLabel.text = "\(playerScore)"
        
        buttonRestart = self.childNode(withName: "buttonRestart") as! MSButtonNode
        buttonRestart.selectedHandler = {
            let skView = self.view as SKView! //grab ref to our spritekit view
            let scene = GameScene(fileNamed: "GameScene") as GameScene! //load game scene
            scene?.scaleMode = .aspectFill //ensure correct aspect mode
            skView?.presentScene(scene) //restart game scene
            
        }
        
        buttonRestart.state = .hidden
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
                    print(enemy.size.width)
                    
                } else {
                    gameState = .gameOver
                    nodeB?.removeFromParent()
                    buttonRestart.state = .active
                }
            }
            scoreLabel.text = String(playerScore)
            return
        } else if contactA.categoryBitMask == 1 && contactB.categoryBitMask == 2 {
            if let enemy = nodeB as? EnemyBoba, let player = nodeA as? PlayerBoba {
                if enemy.size.width <= player.size.width {
                    playerScore += enemy.getPoints()
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
                    print(enemy.size.width)
                } else {
                    gameState = .gameOver
                    nodeA?.removeFromParent()
                    buttonRestart.state = .active
                }
            }
            scoreLabel.text = String(playerScore)
            return
        
        }
        
    
    }
    
    func updateEnemies() {
    
        enemyLayer.position.y += scrollSpeed * CGFloat(fixedDelta)
        for enemy in enemyLayer.children {
            let enemyPos = enemyLayer.convert(enemy.position, to: self)
            if enemyPos.y  >= 600 {
                enemy.removeFromParent()
            }
        }
        
        if spawnTimer >= spawnVar {
        
            let newEnemy = enemySource.copy() as! EnemyBoba
            let newSize = sizeLabel.copy() as! SKLabelNode
            let newScale = randomBetweenNumbers(firstNum: 0.2, secondNum: 1.5)
            newEnemy.setScale(CGFloat(newScale))
            newSize.text = "\(newEnemy.getPoints())"
            let spawnLoc = CGPoint(x: locations.random(), y: -20)
            newEnemy.position = self.convert(spawnLoc, to: enemyLayer)
            newSize.position = self.convert(spawnLoc, to: enemyLayer)
            enemyLayer.addChild(newEnemy)
            enemyLayer.addChild(newSize)
            spawnTimer = 0
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
//        if gameState != .active { return }
        
        scrollWorld()
        updateEnemies()
        spawnTimer += fixedDelta
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

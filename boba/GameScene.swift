//
//  GameScene.swift
//  boba
//
//  Created by Tracy Ma on 7/23/17.
//  Copyright © 2017 Tracy Ma. All rights reserved.
//

import SpriteKit
import GameplayKit



enum Direction {     
    case right, left, none
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let fixedDelta: CFTimeInterval = 1.0 / 60.0
    
    var playerBoba: PlayerBoba!
    
    var scrollLayer: SKNode!
    var enemySource: SKSpriteNode!
    var enemyLayer: SKNode!
    var spawnTimer: CFTimeInterval = 0
    let scrollSpeed: CGFloat = 200
    
    var scoreLabel: SKLabelNode!
    var playerScore: Int = 0

    var touchStartPoint:(location: CGPoint, time: TimeInterval)? //starting point of swipe; stores location and time
    let minDistance: CGFloat = 20 //parameters of swipe: distance, speed
    let minSpeed: CGFloat = 100
    let maxSpeed: CGFloat = 6000
    
    let locations = [70, 160, 250]
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        playerBoba = self.childNode(withName: "//playerBoba") as! PlayerBoba
        
        scrollLayer = self.childNode(withName: "scrollLayer")
        
        enemySource = self.childNode(withName: "//enemyBoba") as! SKSpriteNode
        enemyLayer = self.childNode(withName: "enemyLayer")
        
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        
        scoreLabel.text = "\(playerScore)"
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        
        let contactA = contact.bodyA //get refs to body involved in collision
        let contactB = contact.bodyB
        
        let nodeA = contactA.node as! SKSpriteNode  //get refs to physics body parent nodes
        let nodeB = contactB.node as! SKSpriteNode
    
        if contactA.categoryBitMask == 2 && contactB.categoryBitMask == 1 {
            if nodeA.size.width <= nodeB.size.width {
                playerScore += Int(nodeA.size.width)
                print("1")
                nodeA.removeFromParent()
            } else {
                playerScore -= 1
            }
    
            scoreLabel.text = String(playerScore)
            return
        } else if contactA.categoryBitMask == 1 && contactB.categoryBitMask == 2 {
            if nodeB.size.width <= nodeA.size.width {
                playerScore += Int(nodeB.size.width)
                nodeB.removeFromParent()
                print("2")
            } else {
                playerScore -= 1
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
        
        if spawnTimer >= 1.0 {
            let newEnemy = enemySource.copy() as! SKSpriteNode
            let newScale = randomBetweenNumbers(firstNum: 0.2, secondNum: 1.5)
            newEnemy.setScale(CGFloat(newScale))
            enemyLayer.addChild(newEnemy)
            let spawnLoc = CGPoint(x: locations.random(), y: -570)
            newEnemy.position = self.convert(spawnLoc, to: enemyLayer)
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

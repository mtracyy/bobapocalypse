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

    var playerBoba: PlayerBoba!
    var enemyBoba: SKNode!

    var touchStartPoint:(location: CGPoint, time: TimeInterval)? //starting point of swipe; stores location and time
    let minDistance: CGFloat = 20 //parameters of swipe: distance, speed
    let minSpeed: CGFloat = 100
    let maxSpeed: CGFloat = 6000
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        playerBoba = self.childNode(withName: "//playerBoba") as! PlayerBoba
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
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touch = touches.first! as! UITouch
//    }
    
    override func update(_ currentTime: TimeInterval) {


    }

}

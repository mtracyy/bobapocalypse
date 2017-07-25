//
//  playerBoba.swift
//  boba
//
//  Created by Tracy Ma on 7/24/17.
//  Copyright © 2017 Tracy Ma. All rights reserved.
//

import SpriteKit
import GameplayKit

class PlayerBoba: SKSpriteNode {
    
    var direction: Direction = .none {
        didSet {
            if direction == .left {
                self.physicsBody?.applyImpulse(CGVector(dx: -200, dy: 0))
            } else if direction == .right {
                self.physicsBody?.applyImpulse(CGVector(dx: 200, dy: 0))

            }
            
        }
    }
    
    
//    var touchStartPoint:(location: CGPoint, time: TimeInterval)? //starting point of swipe; stores location and time
//    let minDistance: CGFloat = 25 //parameters of swipe: distance, speed
//    let minSpeed: CGFloat = 200
//    let maxSpeed: CGFloat = 6000
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first { //saves location and time of first touch
//            touchStartPoint = (touch.location(in:self), touch.timestamp)
//        }
//    }
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        var swiped = false
//        if let touch = touches.first, let startTime = self.touchStartPoint?.time, let startLocation = self.touchStartPoint?.location {
//            let location = touch.location(in: self)
//            let dx = location.x  - startLocation.x
//            let dy = location.y - startLocation.y
//            let distance = sqrt(dx*dx + dy*dy)
//            
//            if distance > minDistance { //check if user's finger moved at least min distance
//                let deltaTime = CGFloat(touch.timestamp - startTime) // change in time from first touch to end touch
//                let speed = distance / deltaTime
//                
//                if speed >= minSpeed && speed <= maxSpeed { //determines direction of swipe
//                    let x = abs(dx/distance) > 0.4 ? Int(sign(Float(dx))) : 0
//                    let y = abs(dy/distance) > 0.4 ? Int(sign(Float(dy))) : 0
//                    
//                    swiped = true
//                    switch (x, y) {
//                    case (-1,0): //left
//                        print("swiped left")
//                    case (1,0): //right
//                        print("swiped right")
//                    default:
//                        swiped = false
//                        break
//                        
//                    }
//                }
//            }
//        }
//    }
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) { //required for subclass to work
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) { //required for subclass to work
        super.init(coder: aDecoder)
    }
}

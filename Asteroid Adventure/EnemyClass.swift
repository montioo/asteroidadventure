//
//  EnemyClass.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 10.08.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation
import SpriteKit


class EnemyClass : SKSpriteNode {
    
    private var explosionActive : Bool = false
    private var Leben : Int = 4
    
    private var flyMovementXactive : Bool = false
    private var flyMovementYactive : Bool = false
    private var CenterPoint : CGPoint = CGPoint(x: 0, y: 0)
    private var Cage_X : CGFloat = 0
    private var Cage_Y : CGFloat = 0
    private var movingTime : Double = 0

    
    init(Leben: Int, MovingTime: Double) {
        
        let texture = SKTexture(imageNamed: "Enemy_v1")
        
        super.init(texture: texture, color: UIColor.redColor(), size: texture.size())
        self.setLives(Leben)
        self.setMovingTime(MovingTime)
        self.name = "enemy"
        self.zPosition = 0.6
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.PhyEnemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.PhyLaser | PhysicsCategory.PhyBombExpl
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setLives (neueLeben: Int) {
        self.Leben = neueLeben
    }
    
    func setMovingTime (Time: Double) {
        self.movingTime = Time
    }
    
    func gotHitAndIsExploding (isPowerLaser: Bool) -> Bool {
        
        //Beim ersten Treffer, der das Leben auf 0 setzt,
        //startet die Explosion. Nur dann wird true returned.
        
        if explosionActive {
            return false
        }
        
        if isPowerLaser {
            Leben -= 2
        } else {
            Leben -= 1
        }
        
        if self.Leben > 0 {
            self.colorBlendFactor = 0.8
            self.runAction(SKAction.colorizeWithColorBlendFactor(0.0, duration: 0.4))
        } else {
            explosionActive = true
            explode()
            return true
        }
        return false
    }
    
    
    func shootLaser (raumschiffPos: CGPoint, praezisionInPercent: CGFloat, gameViewHeight: CGFloat) -> SKSpriteNode {
        let laser = SKSpriteNode(imageNamed: "Game_LaserGruen_v2")
        laser.zPosition = 0.5
        laser.position = self.position
    
        laser.physicsBody = SKPhysicsBody(rectangleOfSize: laser.size)
        laser.physicsBody?.dynamic = true
        laser.physicsBody?.categoryBitMask = PhysicsCategory.PhyEnemyLaser
        laser.physicsBody?.collisionBitMask = PhysicsCategory.None
        laser.physicsBody?.usesPreciseCollisionDetection = true
        
        let bereich = random(min: -gameViewHeight*(1-(praezisionInPercent/100)), max: gameViewHeight*(1-(praezisionInPercent/100)))
        
        let targetDirection : CGPoint = CGPoint(x: raumschiffPos.x, y: raumschiffPos.y+bereich)
        
        let winkelGrad = atan((self.position.y - targetDirection.y) / (self.position.x - targetDirection.x))
        
        laser.zRotation = winkelGrad
        
        let targetPos = CGVector(dx: -cos(winkelGrad)*1000, dy: -sin(winkelGrad)*1000)
        
        laser.runAction(SKAction.sequence([
            SKAction.moveBy(targetPos, duration: 2.0),
            SKAction.removeFromParent()
        ]))
        
        if let sound = playSoundEffectGame(soundEffect_shoot, looped: false) {
            self.addChild(sound)
        }
        
        return laser
    }
    
    
    private func explode () {
        
        let explosion = SKEmitterNode(fileNamed: "bomb_explosion")
        explosion?.setScale(0.6)
        explosion?.zPosition = 0.1
        
        self.addChild(explosion!)
        
        if let sound = playSoundEffect(soundEffect_explosion, looped: false) {
            self.addChild(sound)
        }
        
        self.runAction(SKAction.sequence([
            SKAction.waitForDuration(0.1),
            SKAction.runBlock({
                self.size = CGSizeMake(0, 0)
            }),
            SKAction.waitForDuration(0.3),
            SKAction.runBlock({self.removeFromParent()})
            ]))
        
        
    }
    
    
    func setCage_X (value: CGFloat) {
        Cage_X = value
    }
    
    func setCage_Y (value: CGFloat) {
        Cage_Y = value
    }
    
    func setCenterPoint (point: CGPoint) {
        CenterPoint = point
    }
    
    func flyEnemy () {
        //wird in update aufgerufen
        
        //X
        if flyMovementXactive == false {
            
            //Bewegungsspielraum
            var maxMove_X : CGFloat = 0
            var minMove_X : CGFloat = 0
            
            maxMove_X = maxAbs( (CenterPoint.x-Cage_X) - self.position.x , b: (CenterPoint.x+Cage_X) - self.position.x)
            minMove_X = (1/3)*maxMove_X
            
            var MoveDistanceX = random(min: abs(minMove_X), max: abs(maxMove_X))
            if maxMove_X < 0 {
                MoveDistanceX = MoveDistanceX * (-1)
            }
            
            flyMovementXactive = true
            
            let move_X_action = SKAction.moveToX(self.position.x + MoveDistanceX , duration: movingTime)
            move_X_action.timingMode = SKActionTimingMode.EaseInEaseOut
            self.runAction(SKAction.sequence([move_X_action, SKAction.runBlock({self.flyMovementXactive = false})]))
            
        }
        
        
        //Y
        if flyMovementYactive == false {
            
            //Bewegungsspielraum
            var maxMove_Y : CGFloat = 0
            var minMove_Y : CGFloat = 0
            
            maxMove_Y = maxAbs( (CenterPoint.y-Cage_Y) - self.position.y , b: (CenterPoint.y+Cage_Y) - self.position.y)
            minMove_Y = (1/3)*maxMove_Y
            
            var MoveDistanceY = random(min: abs(minMove_Y), max: abs(maxMove_Y))
            if maxMove_Y < 0 {
                MoveDistanceY = MoveDistanceY * (-1)
            }
            
            let Drehung_1_0 = MoveDistanceY/(2*Cage_Y)
            let Winkel_Rad = Drehung_1_0*CGFloat(M_PI/20)
            flyMovementYactive = true
            
            let move_Y_action = SKAction.moveToY(self.position.y + MoveDistanceY , duration: movingTime)
            move_Y_action.timingMode = SKActionTimingMode.EaseInEaseOut
            
            let rotate_Z_action_first = SKAction.rotateToAngle(Winkel_Rad, duration: movingTime/2)
            rotate_Z_action_first.timingMode = SKActionTimingMode.EaseInEaseOut
            
            let rotate_Z_action_second = SKAction.rotateToAngle(0, duration: movingTime/2)
            rotate_Z_action_second.timingMode = SKActionTimingMode.EaseInEaseOut
            
            self.runAction(SKAction.sequence([SKAction.group([move_Y_action, SKAction.sequence([rotate_Z_action_first, rotate_Z_action_second])]), SKAction.runBlock({self.flyMovementYactive = false})]))
            
        }
        
    }
    
    
}



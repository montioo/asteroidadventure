//
//  BombClass.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 10.08.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation
import SpriteKit

class BombExplNode : SKSpriteNode {
    var hitSpaceship : Bool = false
}

class BombClass : SKSpriteNode {
    
    private var countdown : Double = 0
    private var explosionActive : Bool = false
    
    private let Background = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(10, 10))
    private let Time = SKLabelNode(fontNamed: "Arial-BoldMT")
    
    
    init(starttime: Double) {
        
        countdown = starttime
        
        let texture = SKTexture(imageNamed: "AstAdv_Bomb_v2")
        
        super.init(texture: texture, color: UIColor.whiteColor(), size: texture.size())
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.categoryBitMask = PhysicsCategory.PhyBombBody
        self.physicsBody?.contactTestBitMask = PhysicsCategory.PhyLaser | PhysicsCategory.PhyRaumschiff
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        Background.size = CGSizeMake(self.size.width*0.35, self.size.height*0.35)
        Background.zPosition = -0.2
        self.addChild(Background)
        
        Time.text = String(countdown)
        Time.fontSize = 18
        Time.horizontalAlignmentMode = .Center
        Time.verticalAlignmentMode = .Center
        Time.zPosition = -0.1
        self.addChild(Time)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startCountdown () {
        Background.removeActionForKey("startCountdown")
        
        let countAction = SKAction.repeatAction(
            SKAction.sequence([
                SKAction.runBlock({
                    self.Time.text = String(Int(self.countdown));
                    self.playCountdownSound()
                    self.countdown -= 1}),
                SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1, duration: 0.5),
                SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 1, duration: 0.5),
                ]), count: Int(countdown))
        
        Background.runAction(SKAction.sequence([
            countAction,
            SKAction.runBlock({self.explode()})
            ]), withKey: "startCountdown")
    }
    
    func playCountdownSound () {
        if let sound = playSoundEffectGame(soundEffect_bombCountdown, looped: false) {
            self.addChild(sound)
        }
    }
    
    func explode () {
        
        if explosionActive {
            return
        } else {
            explosionActive = true
        }
        
        let explosion = SKEmitterNode(fileNamed: "bomb_explosion")
        explosion?.setScale(0.6)
        explosion?.zPosition = 0.1
        
        
        self.addChild(explosion!)
        
        let explosionCollBody = BombExplNode(imageNamed: "ExplosionCollisionBody_v1")
        explosionCollBody.zPosition = 0.05
        explosionCollBody.alpha = 0.1
        self.addChild(explosionCollBody)
        
        explosionCollBody.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        explosionCollBody.physicsBody?.categoryBitMask = PhysicsCategory.PhyBombExpl
        explosionCollBody.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        explosionCollBody.runAction(SKAction.sequence([
            SKAction.resizeToWidth(explosionCollBody.size.width*8, height: explosionCollBody.size.height*10, duration: 0.3),
            SKAction.removeFromParent()
        ]))
        
        if let sound = playSoundEffectGame(soundEffect_explosion, looped: false) {
            self.addChild(sound)
        }
        
        self.runAction(SKAction.sequence([
            SKAction.waitForDuration(0.1),
            SKAction.runBlock({
                self.size = CGSizeMake(0, 0)
                self.Time.hidden = true
                self.Background.hidden = true
            }),
            SKAction.waitForDuration(0.3),
            SKAction.runBlock({self.removeFromParent()})
            ]))
       
    }
    
    func setCountdown (starttime: Double) {
        countdown = starttime
    }
    
    
    
}



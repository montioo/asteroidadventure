//
//  BombClass.swift
//  Animation Playground
//
//  Created by Marius Montebaur on 01.07.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation
import SpriteKit

class BombClass : SKSpriteNode {
    
    private var countdown : Double = 0
    
    private let Background = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(10, 10))
    private let Time = SKLabelNode(fontNamed: "Arial-BoldMT")
    
    
    init(starttime: Double) {
        
        countdown = starttime
        
        let texture = SKTexture(imageNamed: "AstAdv_Bomb_v2")
        
        super.init(texture: texture, color: UIColor.whiteColor(), size: texture.size())
        
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
                    self.countdown -= 1}),
                SKAction.colorizeWithColor(UIColor.redColor(), colorBlendFactor: 1, duration: 0.5),
                SKAction.colorizeWithColor(UIColor.whiteColor(), colorBlendFactor: 1, duration: 0.5),
                ]), count: Int(countdown))
        
        Background.runAction(SKAction.sequence([
            countAction,
            SKAction.runBlock({self.explode()})
            ]), withKey: "startCountdown")
    }
    
    func explode () {
        let explosion = SKEmitterNode(fileNamed: "bomb_explosion")
        explosion?.setScale(0.6)
        explosion?.zPosition = 0.1
        
        /*
        explosion!.physicsBody = SKPhysicsBody(rectangleOfSize: explosion.size)
        
        BombTest.physicsBody?.categoryBitMask = PhysicsCategory.PhyBomb
        
        BombTest.physicsBody?.contactTestBitMask = PhysicsCategory.PhyRaumschiff
        BombTest.physicsBody?.collisionBitMask = PhysicsCategory.None
        */
        
        self.addChild(explosion!)
        
        let explosionCollBody = SKSpriteNode(imageNamed: "ExplosionCollisionBody_v1")
        explosionCollBody.zPosition = 0.05
        explosionCollBody.alpha = 0.1
        self.addChild(explosionCollBody)
        
        explosionCollBody.runAction(SKAction.resizeToWidth(explosionCollBody.size.width*8, height: explosionCollBody.size.height*8, duration: 0.3))
        
        self.runAction(SKAction.sequence([
            SKAction.waitForDuration(0.1),
            SKAction.runBlock({
                self.size = CGSizeMake(0, 0)
                self.Time.hidden = true
                self.Background.hidden = true
            }),
            SKAction.waitForDuration(0.9),
            SKAction.runBlock({self.removeFromParent()})
        ]))
        
       
    }
    
    func setCountdown (starttime: Double) {
        countdown = starttime
    }
    
    
    
}























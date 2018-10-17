//
//  SpaceshipClass.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 01.07.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import SpriteKit
import Foundation


class SpaceshipNode : SKSpriteNode {
    
    var firstUse : Bool = true
    
    //maxMovement abhängig von Pos
    var maximumMovement : CGFloat = 0
    let maxRotation : CGFloat = CGFloat(M_PI/10)
    let borderPercent : CGFloat = 0.2 //Prozentualer Anteil eines Rahmens an Height
    let minSpeedPercent : CGFloat = 0.2 //Minimaler prozentualer Anteil der Geschwindigkeit im Grenzbereich
    
    var referenceInput : CGFloat = 0
    private var momentaryInput : CGFloat = 0
    
    private var maxHeight : CGFloat = 0
    private var minHeight : CGFloat = 0
    private var centerPos : CGFloat = 0
    private var viewHeight : CGFloat = 0
    
    private var viewBorderUpper : CGFloat = 0 //Höhengrenze, ab der das Schiff langsamer wird
    private var viewBorderLower : CGFloat = 0 //Höhengrenze, ab der das Schiff langsamer wird
    private var borderHeight : CGFloat = 0
    
    private var Orientation : CGFloat = 0 //1 oder -1, je nach Ausrichtng
    
    func resetReference () {
        firstUse = true
    }
    
    func setMaxFlightHeight (height: CGFloat) {
        maxHeight = height
        maximumMovement = height/45
        setBounds()
        //print(maxHeight)
    }
    
    func setMinFlightHeight (height: CGFloat) {
        minHeight = height
        setBounds()
    }
    
    private func setBounds () {
        centerPos = (maxHeight + minHeight)/2
        viewHeight = maxHeight - minHeight
        viewBorderUpper = (maxHeight - minHeight)*(1-borderPercent)
        viewBorderLower = (maxHeight - minHeight)*borderPercent
        borderHeight = viewBorderLower
    }
    
    private func map (value value: CGFloat, inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat) -> CGFloat {
        return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
    }
    
    func setOrientation (gravityX: Double) {
        if gravityX > 0 {
            Orientation = -1
        } else {
            Orientation = 1
        }
    }
    
    
    func moveToY (attitudeWert: Double) {
        momentaryInput = CGFloat(attitudeWert) * 0.65 // Diesen Wert ändert die Empfindlichkeit
        
        if firstUse {
            referenceInput = momentaryInput
            firstUse = false
        }
        
        let turnRate = momentaryInput - referenceInput
        if abs(turnRate) > 0.45 && (self.position.y == minHeight || self.position.y == maxHeight) {
            referenceInput += 0.05*(turnRate/abs(turnRate))
        }
        let targetPos = Orientation*(momentaryInput - referenceInput)*20
        
        if targetPos < 0 {
            //DOWN
            if self.position.y > viewBorderLower {
                changePosBy(max(targetPos, -maximumMovement))
                return
            }
            
            var percentFromTop = self.position.y / borderHeight
            percentFromTop = map(value: percentFromTop, inMin: 0, inMax: 1, outMin: minSpeedPercent, outMax: 1)
            changePosBy(max(targetPos, -maximumMovement*percentFromTop, -self.position.y))
            return
        } else {
            //UP
            if self.position.y < viewBorderUpper {
                changePosBy(min(targetPos, maximumMovement))
                return
            }
            
            var percentFromTop = (maxHeight - self.position.y) / borderHeight
            percentFromTop = map(value: percentFromTop, inMin: 0, inMax: 1, outMin: minSpeedPercent, outMax: 1)
            changePosBy(min(targetPos, maximumMovement*percentFromTop, maxHeight-self.position.y))
            return
        }
        
    }
    
    func changePosBy (way : CGFloat) {
        self.position.y += way
        let percentOfMaxMovement = way/maximumMovement
        self.zRotation = percentOfMaxMovement*maxRotation
    }
    
    func gotHit() {
        self.color = UIColor.redColor()
        self.colorBlendFactor = 0.8
        self.runAction(SKAction.colorizeWithColorBlendFactor(0.0, duration: 0.4))
    }
    
    func gotEnergy() {
        
        if let sound = playSoundEffectGame(soundEffect_powerUp, looped: false) {
            self.addChild(sound)
        }
        
        self.color = UIColor.blueColor()
        self.colorBlendFactor = 0.4
        self.runAction(SKAction.colorizeWithColorBlendFactor(0.0, duration: 0.2))
    }
    
}
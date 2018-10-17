//
//  AudioAndVibration.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 10.06.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation
import AudioToolbox
import SpriteKit



struct soundEffect {
    var fileName : String = ""
    var durationInSec : Double = 0.0
    var volume : Float = 1.0
}


var soundEffect_shoot = soundEffect(fileName: "LaserShoot_v2.mp3", durationInSec: 0.32, volume: 0.35)
var soundEffect_explosion = soundEffect(fileName: "Explosion_v2.mp3", durationInSec: 1, volume: 0.2)
var soundEffect_longAlarm = soundEffect(fileName: "Alarmsound_v2.mp3", durationInSec: 4, volume: 1)
var soundEffect_bombCountdown = soundEffect(fileName: "BombCountdown_v2.mp3", durationInSec: 0.5, volume: 1)
var soundEffect_buttonKlick = soundEffect(fileName: "Klick_v2.mp3", durationInSec: 1, volume: 1)
var soundEffect_shieldSound = soundEffect(fileName: "SchildSound_v2.mp3", durationInSec: 0.5, volume: 0.4)
var soundEffect_powerUp = soundEffect(fileName: "PowerUp_v2.mp3", durationInSec: 5, volume: 0.5)

var gleichzeitigeSounds : Int = 0

func playSoundEffectGame (effectName: soundEffect, looped: Bool) -> SKAudioNode? {
    
    if !getBoolOption("sound_effects") { return nil }
    
    if gleichzeitigeSounds >= 7 { return nil }
    
    if isIPhone4s && gleichzeitigeSounds >= 5 { return nil }
    
    let soundNode = SKAudioNode(fileNamed: effectName.fileName)
    
    soundNode.runAction(SKAction.changeVolumeTo(effectName.volume, duration: 0))
    
    if !looped {
        //soundNode.looped = false
        gleichzeitigeSounds += 1
        soundNode.runAction(SKAction.sequence([SKAction.waitForDuration(effectName.durationInSec), SKAction.removeFromParent()]))
        extSoundNode.runAction(SKAction.sequence([SKAction.waitForDuration(effectName.durationInSec), SKAction.runBlock({gleichzeitigeSounds -= 1})]))
    }
    
    return soundNode
}


func playSoundEffect (effectName: soundEffect, looped: Bool) -> SKAudioNode? {
    
    if !getBoolOption("sound_effects") { return nil }
    
    let soundNode = SKAudioNode(fileNamed: effectName.fileName)
    
    soundNode.runAction(SKAction.changeVolumeTo(effectName.volume, duration: 0))
    
    if !looped {
        soundNode.runAction(SKAction.sequence([SKAction.waitForDuration(effectName.durationInSec), SKAction.removeFromParent()]))
    }
    
    return soundNode
}



func vibrate () {
    if getBoolOption("vibration") {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}










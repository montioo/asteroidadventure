//
//  GameScene.swift
//  Animation Playground
//
//  Created by Marius Montebaur on 20.06.16.
//  Copyright (c) 2016 Marius Montebaur. All rights reserved.
//

import SpriteKit
import CoreMotion


class SpaceshipNode : SKSpriteNode {
    
    //maxMovement abhängig von Pos
    let maximumMovement : CGFloat = 10
    let maxRotation : CGFloat = CGFloat(M_PI/10)
    let borderPercent : CGFloat = 0.2 //Prozentualer Anteil eines Rahmens an Height
    let minSpeedPercent : CGFloat = 0.2 //Minimaler prozentualer Anteil der Geschwindigkeit im Grenzbereich
    
    var referenceInput : CGFloat = 0
    var momentaryInput : CGFloat = 0

    var maxHeight : CGFloat = 0
    var minHeight : CGFloat = 0
    var centerPos : CGFloat = 0
    var viewHeight : CGFloat = 0
    
    var viewBorderUpper : CGFloat = 0 //Höhengrenze, ab der das Schiff langsamer wird
    var viewBorderLower : CGFloat = 0 //Höhengrenze, ab der das Schiff langsamer wird
    var borderHeight : CGFloat = 0
    
    
    func setReference (referenzWert: Double) {
        referenceInput = CGFloat(referenzWert)
    }
    
    func setMaxFlightHeight (height: CGFloat) {
        maxHeight = height
        setBounds()
        print(maxHeight)
    }
    
    func setMinFlightHeight (height: CGFloat) {
        minHeight = height
        setBounds()
    }
    
    func setBounds () {
        centerPos = (maxHeight + minHeight)/2
        viewHeight = maxHeight - minHeight
        viewBorderUpper = (maxHeight - minHeight)*(1-borderPercent)
        viewBorderLower = (maxHeight - minHeight)*borderPercent
        borderHeight = viewBorderLower
    }
    
    func map (value value: CGFloat, inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat) -> CGFloat {
        return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
    }
    
    
    func moveToY (attitudeWert: Double) {
        momentaryInput = CGFloat(attitudeWert)
        
        let turnRate = momentaryInput - referenceInput
        if abs(turnRate) > 0.45 && (self.position.y == minHeight || self.position.y == maxHeight){
            referenceInput += 0.05*(turnRate/abs(turnRate))
        }
        let targetPos = -(momentaryInput - referenceInput)*50
        
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
        self.zRotation = percentOfMaxMovement*maxRotation + CGFloat(-M_PI/2)
    }
    
}

class GameScene: SKScene {
    
    let Pause_Brick_1 = SKSpriteNode(imageNamed: "PlayPauseBrick")
    let Pause_Brick_2 = SKSpriteNode(imageNamed: "PlayPauseBrick")
    let Pause_Brick_3 = SKSpriteNode(imageNamed: "PlayPauseBrick")
    
    let Brick_x = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(100, 10))
    let Brick_y = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(100, 10))
    let Brick_z = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(100, 10))
    
    var progressTest : progressBarClass? = nil
    
    let Play_Pause_Node = SKSpriteNode()
    
    var i = 0
    
    var j = 9
    
    let Play_Pause_AnimationDuration : Double = 0.6
    
    let spaceship = SpaceshipNode(imageNamed: "Spaceship")
    
    let motionManager = CMMotionManager()
    var motionManager_firstUse : Bool = true
    
    let Bomb = BombClass(starttime: 4)
   
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        backgroundColor = setRGBColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        Play_Pause_Node.position = CGPoint(x: size.width*0.1, y: size.height*0.1)
        addChild(Play_Pause_Node)
        
        Play_Pause_Node.addChild(Pause_Brick_1)
        Play_Pause_Node.addChild(Pause_Brick_2)
        Play_Pause_Node.addChild(Pause_Brick_3)
        
        let attitudeNode = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(60, 30))
        attitudeNode.anchorPoint = CGPointMake(0, 1)
        attitudeNode.position = CGPoint(x: 0, y: size.height)
        addChild(attitudeNode)
        
        Brick_x.anchorPoint = CGPointMake(0, 0.5)
        Brick_x.position = CGPoint(x: attitudeNode.size.width/2, y: -attitudeNode.size.height*(1/6))
        attitudeNode.addChild(Brick_x)
        
        Brick_y.anchorPoint = CGPointMake(0, 0.5)
        Brick_y.position = CGPoint(x: attitudeNode.size.width/2, y: -attitudeNode.size.height*0.5)
        attitudeNode.addChild(Brick_y)
        
        Brick_z.anchorPoint = CGPointMake(0, 0.5)
        Brick_z.position = CGPoint(x: attitudeNode.size.width/2, y: -attitudeNode.size.height*(5/6))
        attitudeNode.addChild(Brick_z)
        
        
        spaceship.setScale(0.3)
        spaceship.position = CGPoint(x: spaceship.size.width, y: size.height/2)
        spaceship.zRotation = CGFloat(-M_PI/2)
        spaceship.setMaxFlightHeight(size.height)
        self.addChild(spaceship)
        
        
        if (motionManager.deviceMotionAvailable) {
            motionManager.startDeviceMotionUpdates()
        }
        
        
        Bomb.position = CGPoint(x: size.width*0.75, y: size.height/2)
        addChild(Bomb)
        
        
        progressTest = progressBarClass(title: "energy", width: 200, height: 30, effectName: "progressParticle")
        progressTest!.position = CGPoint(x: size.width*0.3, y: size.height*0.3)
        progressTest!.zPosition = 1
        progressTest!.setProgressInPercent(0)
        addChild(progressTest!)
        
        
        let barBackground = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: progressTest!.getBarWidth(), height: progressTest!.getBarHeight()))
        barBackground.position = CGPoint(x: size.width*0.3, y: size.height*0.3)
        addChild(barBackground)
        
        
        let highscoreCarrierNode = SKSpriteNode()
        highscoreCarrierNode.position = CGPoint(x: size.width/2, y: size.height/2)
        highscoreCarrierNode.zPosition = 4
        addChild(highscoreCarrierNode)
        
        let highscoreEmitterNode = SKEmitterNode(fileNamed: "newHighscoreParticle")
        highscoreCarrierNode.addChild(highscoreEmitterNode!)
        
        let highscoreText = SKLabelNode(fontNamed: "Arial-MT")
        highscoreText.fontColor = UIColor.whiteColor()
        highscoreText.text = "new highscore"
        highscoreText.verticalAlignmentMode = .Center
        highscoreText.horizontalAlignmentMode = .Center
        highscoreText.fontSize = 18
        highscoreText.zPosition = 1
        highscoreCarrierNode.addChild(highscoreText)
        
        highscoreEmitterNode?.particlePositionRange = CGVector(dx: highscoreText.frame.size.width, dy: highscoreText.frame.size.height)
        
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.runBlock({self.updateBackgroundColor()})])))
        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
       
        if motionManager.deviceMotion?.attitude.roll != nil {
            if motionManager_firstUse {
                motionManager_firstUse = false
                spaceship.setReference((motionManager.deviceMotion?.attitude.roll )!)
            }
            
            spaceship.moveToY((motionManager.deviceMotion?.attitude.roll )!)
            Brick_x.size.width = CGFloat((motionManager.deviceMotion?.attitude.pitch )!)*10
            Brick_y.size.width = CGFloat((motionManager.deviceMotion?.attitude.roll )!)*10
            Brick_z.size.width = CGFloat((motionManager.deviceMotion?.attitude.yaw )!)*10
           
        }
        
    }
    
    struct colorRGB {
        var red : CGFloat = 0
        var green : CGFloat = 0
        var blue : CGFloat = 0
        var alpha : CGFloat = 0
    }
    
    var targetColor = colorRGB(red: 0, green: 0, blue: 0, alpha: 0)
    var startColor = colorRGB()
    
    var changePercent : CGFloat = 0 //von 0 bis 100
    
    //ErhöhungProAusführung = 100 / (Gesamtverlaufzeit / DauerZwischenZweiAusführungen)
    
    func updateBackgroundColor () {
        
        if changePercent > 100 {
            
            startColor = targetColor
            
            targetColor.red = randomNumber(min: 0, max: 50)
            targetColor.green = randomNumber(min: 0, max: 30)
            targetColor.blue = randomNumber(min: 0, max: 50)
            
            changePercent = 0
            
        }
        
        let changeProgress : CGFloat = max(0, min(1, changePercent/100))
        
        let momentaryColor = setRGBColor(
            red: startColor.red + (targetColor.red - startColor.red)*changeProgress,
            green: startColor.green + (targetColor.green - startColor.green)*changeProgress,
            blue: startColor.blue + (targetColor.blue - startColor.blue)*changeProgress,
            alpha: 1)
        
        
        backgroundColor = momentaryColor
        
        changePercent += 100/(5/0.1)
        
    }
    
    func randomNumber (min min: CGFloat, max: CGFloat) -> CGFloat {
        return (CGFloat(Float(arc4random()) / 0xFFFFFFFF)) * (max - min) + min
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if i == 0 {
            i = 1
            switchToPlayIcon()
        } else {
            i = 0
            switchToPauseIcon()
        }
        
        j += 1
        
        Bomb.startCountdown()
        
        for touch in touches {
            let location = touch.locationInView(self.view)
            
            if location.x < self.size.width/2 {
                progressTest?.addProgressInPercent(-2)
            } else {
                progressTest?.addProgressInPercent(2)
            }
            
        }
        
        
        
    }
    
    func switchToPauseIcon () {
        
        let h : CGFloat = sqrt(3) * Pause_Brick_2.size.width/2
        
        Pause_Brick_1.runAction(SKAction.group([
            SKAction.moveTo(CGPoint(x: h/4, y: 0), duration: Play_Pause_AnimationDuration),
            SKAction.rotateToAngle(CGFloat(M_PI/2), duration: Play_Pause_AnimationDuration)
            ]))
        Pause_Brick_2.runAction(SKAction.group([
            SKAction.moveTo(CGPoint(x: -h/4, y: 0), duration: Play_Pause_AnimationDuration),
            SKAction.rotateToAngle(CGFloat(-M_PI/2), duration: Play_Pause_AnimationDuration)
            ]))
        Pause_Brick_3.runAction(SKAction.group([
            SKAction.moveTo(CGPoint(x: -h/4, y: 0), duration: Play_Pause_AnimationDuration),
            SKAction.rotateToAngle(CGFloat(-M_PI/2), duration: Play_Pause_AnimationDuration)
            ]))
        
    }
    
    func switchToPlayIcon () {
        
        let h : CGFloat = sqrt(3) * Pause_Brick_2.size.width/2
        
        Pause_Brick_1.runAction(SKAction.group([
            //SKAction.resizeToHeight(15, duration: Play_Pause_AnimationDuration),
            SKAction.moveTo(CGPoint(x: -h/2, y: 0), duration: Play_Pause_AnimationDuration),
            SKAction.rotateToAngle(CGFloat(-M_PI/2), duration: Play_Pause_AnimationDuration)
            ]))
        Pause_Brick_2.runAction(SKAction.group([
            //SKAction.resizeToHeight(15, duration: Play_Pause_AnimationDuration),
            SKAction.moveTo(CGPoint(x: 0, y: Pause_Brick_2.size.width/4), duration: Play_Pause_AnimationDuration),
            SKAction.rotateToAngle(CGFloat((-M_PI/6)+M_PI), duration: Play_Pause_AnimationDuration)
        ]))
        Pause_Brick_3.runAction(SKAction.group([
            //SKAction.resizeToHeight(15, duration: Play_Pause_AnimationDuration),
            SKAction.moveTo(CGPoint(x: 0, y: -Pause_Brick_3.size.width/4), duration: Play_Pause_AnimationDuration),
            SKAction.rotateToAngle(CGFloat(M_PI/6), duration: Play_Pause_AnimationDuration)
        ]))
    }
  
}

func setRGBColor (red red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
}

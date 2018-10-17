//
//  MainGame.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 16.03.16.
//  Copyright (c) 2016 Marius Montebaur. All rights reserved.
//


import SpriteKit
import Foundation
import CoreMotion

var extSoundNode = SKSpriteNode()

class MainGame: SKScene, SKPhysicsContactDelegate {
    
    class AsteroidSprite: SKSpriteNode {
        var isMiniAst : Bool = false
    }
    
    
    class LaserSprite: SKSpriteNode {
        var targetsHit : Int = 0    //Vorher mit dem Laser getroffene Asteroiden
        var sisterLaserID : Int = 0   //Laser die aus einem Burst stammen.
        var sisterLaserCount : Int = 1
        
        var isPowerLaser : Bool = false
    }
    
    class HinweisSprite: SKLabelNode {
        var isActive : Bool = false
    }
    
    var Tut_Active : Bool = true
    
    var playerEnergy : CGFloat = 100
    let playerMaxEnergy : CGFloat = 100
    var GamePaused = false
    
    var gameViewHeight : CGFloat = 0
    
    var backgroundStdSpeed : CGFloat = 0
    var backgroundSpeedMultiplier : CGFloat = 1
    
    var RSMovement_X_Active : Bool = false
    var RSCenterPoint : CGPoint = CGPoint(x: 0, y: 0)
    var RSCage_X : CGFloat = 0
    
    var willSpawnPowerUp : Bool = false
    
    var PwrUp_Mlt_Lasermenge = 1
    var PwrUp_Pwr_Active = false
   
    var Ast_last_k : Int = 0
    let Ast_wave_amplitude : Float = 0.035 //a
    let Ast_wave_period_length : Float = 0.7 //b
    
    var Ast_Time : Double = 0
    let Ast_Time_gP : Double = 120
    let Ast_Time_max : Double = 5
    let Ast_Time_min : Double = 2.4
    var Ast_Time_m : Double = 0
    let BigAst_Slower : Double = 1.3
    
    var enemysAlive : Int = 0
    
    var BG_Speed : Float = 0
    var BG_Speed_m : Float = 0
    let BG_Speed_max : Float = 3
    
    struct colorRGB {
        var red : CGFloat = 0
        var green : CGFloat = 0
        var blue : CGFloat = 0
        var alpha : CGFloat = 0
    }
    
    var backgroundTargetColor = colorRGB(red: 0, green: 0, blue: 0, alpha: 0)
    var backgroundStartColor = colorRGB()
    
    var backgroundChangeInPercent : CGFloat = 0 //von 0 bis 100
    
    var AsteroidsHit : Int = 0 //Stats
    var ShotsFired : Int = 0 //Stats
    var collectedPowerUps : Int = 0 //Stats
    var Score : Int = 0 //Stats
    var enemysKilled : Int = 0 //Stats
    var collectedEnergy : Int = 0
    
    var System_Uptime : Double = 0
    var Game_Runtime : Double = 0
    
    let worldNode = SKSpriteNode()
    
    let ObjektMotherNode = SKSpriteNode()
    let spawnNode = SKSpriteNode()
    let LaserMotherNode = SKSpriteNode()
    let PictureMotherNode = SKSpriteNode()
    let HUD_Node = SKSpriteNode()
    let PwrUp_Node = SKSpriteNode()
    
    let GamePauseNode = SKSpriteNode()
    let Pause_Verlauf = SKSpriteNode(imageNamed: "Pause_Verlauf")
    let PauseTitle_left = SKLabelNode(fontNamed: "Arial-BoldMT")
    let PauseTitle_right = SKLabelNode(fontNamed: "Arial-BoldMT")
    var Pause_QuitButton : ButtonClass? = nil
    var Pause_CaliButton : ButtonClass? = nil
    
    let Game_Raumschiff = SpaceshipNode(imageNamed: "Game_Raumschiff_v2")
    let Game_Raumschiff_Schild = SKSpriteNode(imageNamed: "Schild_v1")
    let Game_Raumschiff_Laserkanone = SKSpriteNode(imageNamed: "Game_Raumschiff_Laserkanone_v1")
    let Game_RS_Schild_Crop = SKCropNode()
    let Game_RS_Schild_SoundNode = SKSpriteNode()
    
    let Game_Statusbar = SKSpriteNode(color: gameGlasColor, size: CGSizeMake(100, 100))
    let Game_Statusbar_Logo = SKSpriteNode(imageNamed: "AstAdv_Logo")
    let lowEnergyWarning = HinweisSprite(fontNamed: "Arial-BoldMT")
    
    let spaceshipEngineRefNode = SKSpriteNode(texture: nil, color: whiteFont, size: CGSize(width: 0, height: 0))
    
    var tutUpdFunction : () -> () = {return}
    let TutorialNode = SKSpriteNode()
    let TutorialSteps = SKSpriteNode()
    
    let ScoreLabel = SKLabelNode(fontNamed: "Arial-MT")
    
    let StarEmitter = SKEmitterNode(fileNamed: "stars_maingame")
    let EmitterNodes = SKSpriteNode()
    
    var ButtonState_ShowPause = true
    let Play_Pause_AnimationDuration : Double = 0.4
    let Pause_Brick_1 = SKSpriteNode(imageNamed: "PlayPauseBrick")
    let Pause_Brick_2 = SKSpriteNode(imageNamed: "PlayPauseBrick")
    let Pause_Brick_3 = SKSpriteNode(imageNamed: "PlayPauseBrick")
    let Play_Pause_Node = SKSpriteNode()
    let pauseLayer = SKSpriteNode()
    
    var energyProgressBar : progressBarClass? = nil
    var powerUpProgressBar : progressBarClass? = nil
    
    let motionManager = CMMotionManager()

    override func didMoveToView(view: SKView) {
        
        if extSoundNode.parent == nil {
            addChild(extSoundNode)
        }
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(MainGame.myAppMovedToBackground), name: UIApplicationWillResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(MainGame.myAppMovedToBackground), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        globalNewHighscore = false
        
        addChild(worldNode)
        addChild(HUD_Node)
        
        worldNode.addChild(PictureMotherNode)
        worldNode.addChild(LaserMotherNode)
        worldNode.addChild(ObjektMotherNode)
        worldNode.addChild(PwrUp_Node)
        ObjektMotherNode.addChild(spawnNode)
        
        
//Statusbar Initialisierung:
        Game_Statusbar.anchorPoint = CGPointMake(0.5, 1.0)
        Game_Statusbar.size.height = 52
        Game_Statusbar.size.width = size.width
        Game_Statusbar.position = CGPoint(x: size.width/2, y: size.height)
        Game_Statusbar.zPosition = 3.5
        HUD_Node.addChild(Game_Statusbar)
        
        gameViewHeight = size.height-Game_Statusbar.size.height
        
        let borderLeft = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: 2, height: Game_Statusbar.size.height))
        borderLeft.position = CGPoint(x: -Game_Statusbar.size.width*(1/6), y: -borderLeft.size.height/2)
        Game_Statusbar.addChild(borderLeft)
        
        let borderMiddle = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: 2, height: Game_Statusbar.size.height))
        borderMiddle.position = CGPoint(x: Game_Statusbar.size.width*(1/6), y: -borderMiddle.size.height/2)
        Game_Statusbar.addChild(borderMiddle)
        
        let borderRight = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: 2, height: Game_Statusbar.size.height))
        borderRight.position = CGPoint(x: Game_Statusbar.size.width/2 - Game_Statusbar.size.height, y: -borderRight.size.height/2)
        Game_Statusbar.addChild(borderRight)
        
        Game_Statusbar_Logo.position = CGPoint(x: 0, y: -Game_Statusbar.size.height/2)
        Game_Statusbar_Logo.zPosition = 0.01
        Game_Statusbar_Logo.setScale(0.6)
        if isIPhone4s {Game_Statusbar_Logo.setScale(0.45)}
        Game_Statusbar.addChild(Game_Statusbar_Logo)
        
        Pause_Verlauf.anchorPoint = CGPointMake(0.5, 1)
        Pause_Verlauf.size.height = Pause_Verlauf.size.height/4
        Pause_Verlauf.zPosition = 1
        Pause_Verlauf.position = CGPoint(x: 0, y: -Game_Statusbar.size.height)
        Game_Statusbar.addChild(Pause_Verlauf)
        
        Play_Pause_Node.position = CGPoint(x: Game_Statusbar.size.width/2 - Game_Statusbar.size.height/2, y: -Game_Statusbar.size.height/2)
        Play_Pause_Node.zPosition = 0.1
        let h : CGFloat = sqrt(3) * Pause_Brick_2.size.width/2
        Pause_Brick_1.position = CGPoint(x: h/4, y: 0)
        Pause_Brick_1.zRotation = CGFloat(M_PI/2)
        Pause_Brick_1.color = UIColor.blackColor()
        Pause_Brick_2.position = CGPoint(x: -h/4, y: 0)
        Pause_Brick_2.zRotation = CGFloat(-M_PI/2)
        Pause_Brick_2.color = UIColor.blackColor()
        Pause_Brick_3.position = CGPoint(x: -h/4, y: 0)
        Pause_Brick_3.zRotation = CGFloat(-M_PI/2)
        Pause_Brick_3.color = UIColor.blackColor()
        Game_Statusbar.addChild(Play_Pause_Node)
        Play_Pause_Node.addChild(Pause_Brick_1)
        Play_Pause_Node.addChild(Pause_Brick_2)
        Play_Pause_Node.addChild(Pause_Brick_3)
        
        ScoreLabel.text = "score: 0"
        ScoreLabel.verticalAlignmentMode = .Baseline
        ScoreLabel.horizontalAlignmentMode = .Center
        ScoreLabel.position = CGPoint(x: (borderMiddle.position.x + borderRight.position.x)/2, y: Game_Statusbar_Logo.position.y - Game_Statusbar_Logo.size.height/2)
        ScoreLabel.fontSize = 18
        if isIPhone4s {ScoreLabel.fontSize = 16}
        Game_Statusbar.addChild(ScoreLabel)
        
        let barHeight = Game_Statusbar.size.height*0.3875
        let barDistance = Game_Statusbar.size.height*0.075
        energyProgressBar = progressBarClass(title: "energy", width: size.width/3 - barDistance*2 - borderLeft.size.width*0.5, height: barHeight, startProgressInPercent: 100)
        energyProgressBar!.activateEmitter("progressParticle_1")
        energyProgressBar!.zPosition = 0.01
        energyProgressBar!.position = CGPoint(x: -Game_Statusbar.size.width/2 + barDistance + energyProgressBar!.getBarWidth()/2, y: -barDistance - barHeight/2)
        energyProgressBar!.showValues()
        energyProgressBar!.setProgressInPercentInstant(100)
        Game_Statusbar.addChild(energyProgressBar!)
        
        powerUpProgressBar = progressBarClass(title: "power up", width: size.width/3 - barDistance*2 - borderLeft.size.width*0.5, height: barHeight, startProgressInPercent: 0)
        powerUpProgressBar!.activateEmitter("progressParticle_2")
        powerUpProgressBar!.zPosition = 0.01
        powerUpProgressBar!.position = CGPoint(x: -Game_Statusbar.size.width/2 + barDistance + powerUpProgressBar!.getBarWidth()/2, y: -2*barDistance - barHeight*1.5)
        powerUpProgressBar!.showPercent()
        powerUpProgressBar!.setMaxProgress(50)
        powerUpProgressBar!.setProgressInPercentInstant(0)
        powerUpProgressBar!.setHigherColor(setRGBColor(red: 28, green: 213, blue: 63, alpha: 0.6))
        powerUpProgressBar!.setLowerColor(setRGBColor(red: 0, green: 120, blue: 255, alpha: 0.6))
        powerUpProgressBar!.setColorChangeLimit(progressLimitValue: 90, progressAbsoluteRange: 20)
        Game_Statusbar.addChild(powerUpProgressBar!)
        
        lowEnergyWarning.position = CGPoint(x: size.width/2, y: gameViewHeight/2)
        lowEnergyWarning.horizontalAlignmentMode = .Center
        lowEnergyWarning.verticalAlignmentMode = .Center
        lowEnergyWarning.fontSize = 50
        lowEnergyWarning.alpha = 0
        lowEnergyWarning.zPosition = 2.8
        lowEnergyWarning.text = "energy low"
        lowEnergyWarning.fontColor = UIColor.redColor()
        ObjektMotherNode.addChild(lowEnergyWarning)
        
        
//Hintergrund initialisierung
        StarEmitter?.position = CGPoint(x: size.width, y: size.height/2)
        StarEmitter?.particlePositionRange = CGVector(dx: 0, dy: size.height)
        StarEmitter?.particleLifetime = (size.width / ((StarEmitter?.particleSpeed)! - (StarEmitter?.particleSpeedRange)!)) + (StarEmitter?.particleLifetimeRange)!
        StarEmitter?.particleBirthRate = (StarEmitter?.particleBirthRate)! * (size.height/375)
        backgroundStdSpeed = (StarEmitter?.particleSpeed)!
        StarEmitter?.advanceSimulationTime( Double((StarEmitter?.particleLifetime)!) )
        addChild(EmitterNodes)
        EmitterNodes.addChild(StarEmitter!)
        
        backgroundColor = SKColor.blackColor()
        self.runAction(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.runBlock({self.updateBackgroundColor()})]))
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        
//Pause Layer initialisierung
        
        GamePauseNode.zPosition = 10
        GamePauseNode.alpha = 0
        HUD_Node.addChild(GamePauseNode)
        
        PauseTitle_left.text = "game"
        PauseTitle_left.fontSize = 40
        PauseTitle_left.fontColor = whiteFont
        PauseTitle_left.horizontalAlignmentMode = .Left
        PauseTitle_left.verticalAlignmentMode = .Baseline
        PauseTitle_left.zPosition = 0.05
        PauseTitle_left.position = CGPoint(x: 0, y: gameViewHeight*0.75)
        GamePauseNode.addChild(PauseTitle_left)
        
        PauseTitle_right.text = "paused"
        PauseTitle_right.fontSize = 40
        PauseTitle_right.fontColor = whiteFont
        PauseTitle_right.horizontalAlignmentMode = .Right
        PauseTitle_right.verticalAlignmentMode = .Baseline
        PauseTitle_right.zPosition = 0.05
        PauseTitle_right.position = CGPoint(x: size.width, y: gameViewHeight*0.75)
        GamePauseNode.addChild(PauseTitle_right)
        
        Pause_CaliButton = ButtonClass(title: "calibrate control", fontSize: 20, height: size.height*0.1, width: size.width/3, function: buttonPressed_calibrateControls, appearWithAnimation: true, boldFont: false)
        Pause_CaliButton!.position = CGPoint(x: size.width/2, y: gameViewHeight/2 - PauseTitle_left.frame.height*0.6)
        GamePauseNode.addChild(Pause_CaliButton!)
        
        Pause_QuitButton = ButtonClass(title: "back to menu", fontSize: 20, height: size.height*0.1, width: size.width/3, function: buttonPressed_PauseQuit, appearWithAnimation: true, boldFont: false)
        Pause_QuitButton!.position = CGPoint(x: size.width/2, y: gameViewHeight/2 - PauseTitle_left.frame.height*0.6 - Pause_CaliButton!.getButtonHeight()*1.3)
        GamePauseNode.addChild(Pause_QuitButton!)
    
        pauseLayer.size = CGSize(width: self.size.width, height: gameViewHeight)
        pauseLayer.color = UIColor.blackColor()
        pauseLayer.position = CGPoint(x: size.width/2, y: gameViewHeight/2)
        pauseLayer.alpha = 0
        GamePauseNode.addChild(pauseLayer)
        
        
        
// Raumschiff initialisierung
        spaceshipEngineRefNode.position = CGPoint(x: size.width*0.1, y: size.height/2)
        spaceshipEngineRefNode.zPosition = 0.99
        ObjektMotherNode.addChild(spaceshipEngineRefNode)
        
        Game_Raumschiff.zPosition = 1.0
        Game_Raumschiff.position = CGPoint(x: 80, y: gameViewHeight/2) //60
        Game_Raumschiff.setMaxFlightHeight(gameViewHeight)
        RSCenterPoint = Game_Raumschiff.position
        PictureMotherNode.addChild(Game_Raumschiff)
        RSCage_X = (Game_Raumschiff.position.x - Game_Raumschiff.size.width/2)//*(5/6)

        spaceshipEngineRefNode.addChild(Game_RS_Schild_Crop)
        Game_Raumschiff.addChild(Game_RS_Schild_SoundNode)
        Game_Raumschiff_Schild.alpha = 0.55
        
        Game_Raumschiff_Schild.physicsBody = SKPhysicsBody(texture: Game_Raumschiff_Schild.texture!, size: (Game_Raumschiff_Schild.texture!.size()))
        Game_Raumschiff_Schild.physicsBody?.categoryBitMask = PhysicsCategory.PhySchild
        Game_Raumschiff_Schild.physicsBody?.contactTestBitMask = PhysicsCategory.PhyStdAst | PhysicsCategory.PhyEnemyLaser | PhysicsCategory.PhyBombBody | PhysicsCategory.PhyBombExpl
        Game_Raumschiff_Schild.physicsBody?.collisionBitMask = PhysicsCategory.None
        Game_RS_Schild_Crop.addChild(Game_Raumschiff_Schild)
        
        Game_Raumschiff_Laserkanone.zPosition = 0.1
        Game_Raumschiff_Laserkanone.anchorPoint = CGPointMake(0.4, 0.5)
        Game_Raumschiff_Laserkanone.position = CGPoint(x: 0, y: 0)
        
        Game_RS_Schild_Crop.maskNode = Game_Raumschiff_Schild
        
        Game_Raumschiff.addChild(Game_Raumschiff_Laserkanone)
        
        if getBoolOption("aiming_help") {
            Game_Raumschiff_Laserkanone.runAction(SKAction.repeatActionForever(SKAction.sequence([
                SKAction.runBlock({self.spawnZielhilfe()}),
                SKAction.waitForDuration(0.4)
            ])))
        }
        
        Game_Raumschiff_Schild.runAction(SKAction.scaleTo(0.01, duration: 0))
        
        Game_Raumschiff.physicsBody = SKPhysicsBody(texture: Game_Raumschiff.texture!, size: (Game_Raumschiff.texture!.size()))
        Game_Raumschiff.physicsBody?.categoryBitMask = PhysicsCategory.PhyRaumschiff
        Game_Raumschiff.physicsBody?.contactTestBitMask = PhysicsCategory.PhyStdAst | PhysicsCategory.PhyEnemyLaser | PhysicsCategory.PhyBombBody | PhysicsCategory.PhyBombExpl
        Game_Raumschiff.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        
        // -11    6       14 hoch
        let fireUpper = SKEmitterNode(fileNamed: "engineExhaust_2")
        fireUpper!.position = CGPoint(x: -Game_Raumschiff.size.width/2, y: 6)
        fireUpper!.targetNode = spaceshipEngineRefNode
        Game_Raumschiff.addChild(fireUpper!)
        
        let fireLower = SKEmitterNode(fileNamed: "engineExhaust_2")
        fireLower!.position = CGPoint(x: -Game_Raumschiff.size.width/2, y: -11)
        fireLower!.targetNode = spaceshipEngineRefNode
        Game_Raumschiff.addChild(fireLower!)
        
        if getBoolOption("music") {
            self.runAction(SKAction.sequence([SKAction.waitForDuration(2), SKAction.runBlock({
                let backgroundMusic = SKAudioNode(fileNamed: "themesound.mp3")
                self.addChild(backgroundMusic)
            })]))
            
        }
        
        
        if (motionManager.deviceMotionAvailable) {
            motionManager.startDeviceMotionUpdates()
        } else {
            //print("no motionsensor detected")
        }
        
        while motionManager.deviceMotion?.gravity.x == nil {
            
        }
        Game_Raumschiff.setOrientation((motionManager.deviceMotion?.gravity.x)!)
        
        Ast_Time_m = (Ast_Time_max-Ast_Time_min)/(-Ast_Time_gP)
        BG_Speed_m = (BG_Speed_max-1)/Float(Ast_Time_gP)
        
        runTutorial()
    }
    
    
    
    
    override func update(currentTime: NSTimeInterval) {
        
        if System_Uptime != 0 && GamePaused == false && Tut_Active == false {
            
            Game_Runtime = Game_Runtime + (currentTime - System_Uptime)
            
        }
        System_Uptime = currentTime
        
        
        if GamePaused == false {
            if motionManager.deviceMotion?.attitude.roll != nil {
                Game_Raumschiff.moveToY((motionManager.deviceMotion?.attitude.roll )!)
                
                spaceshipEngineRefNode.runAction(SKAction.sequence([
                    SKAction.waitForDuration(0.02),
                    SKAction.moveTo(Game_Raumschiff.position, duration: 0),
                    SKAction.rotateToAngle(Game_Raumschiff.zRotation, duration: 0)]))
            }
            testForGameOver()
            testForLowEnergy()
        }
        
        waveFunction()
        
        organizeBackgroundParticles()
        
        FlyRaumschiff()
        
        tutUpdFunction()
        
    }

    
    //ErhöhungProAusführung = 100 / (Gesamtverlaufzeit / DauerZwischenZweiAusführungen)
    
    func updateBackgroundColor () {
        
        if backgroundChangeInPercent > 100 {
            
            backgroundStartColor = backgroundTargetColor
            
            backgroundTargetColor.red = random(min: 0, max: 20)
            backgroundTargetColor.green = random(min: 0, max: 10)
            backgroundTargetColor.blue = random(min: 0, max: 35)
            
            backgroundChangeInPercent = 0
            
        }
        
        let changeProgress : CGFloat = max(0, min(1, backgroundChangeInPercent/100))
        
        let momentaryColor = setRGBColor(
            red: backgroundStartColor.red + (backgroundTargetColor.red - backgroundStartColor.red)*changeProgress,
            green: backgroundStartColor.green + (backgroundTargetColor.green - backgroundStartColor.green)*changeProgress,
            blue: backgroundStartColor.blue + (backgroundTargetColor.blue - backgroundStartColor.blue)*changeProgress,
            alpha: 1)
        
        
        backgroundColor = momentaryColor
        
        backgroundChangeInPercent += 2 //=100/(5/0.1)
        
        
        let time = Ast_Time * 0.02
        
        self.runAction(SKAction.sequence([SKAction.waitForDuration(time), SKAction.runBlock({self.updateBackgroundColor()})]))
        
        
    }
    
    
    func energyAndPowerUpActions () {
        
        
        spawnNode.runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock({self.powerUpProgressBar!.addProgressInPercent(-1)}),
                SKAction.waitForDuration(2)])
            ))
        
        spawnNode.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.runBlock({self.energyProgressBar!.addProgressInPercent(-0.5)}),
            SKAction.waitForDuration(0.4)])))
        
        spawnEnergyTimeManagement()
    }
    
    
    func spawnEnergyTimeManagement () {
        let waitTime = Ast_Time * Double(random(min: 0.8, max: 1.2))
        
        spawnNode.runAction(SKAction.sequence([
            SKAction.waitForDuration(waitTime),
            SKAction.runBlock({
                self.spawnEnergy();
                self.spawnEnergyTimeManagement();
            }),
            ]))
    }
    
    
    func spawnBomb () {
        
        let bomb = BombClass(starttime: Ast_Time*Double(random(min: 0.8, max: 1.1)))
        bomb.position = CGPoint(x: size.width + bomb.size.width*0.6, y: random(min: 0, max: gameViewHeight))
        bomb.startCountdown()
        
        ObjektMotherNode.addChild(bomb)
        
        let move = SKAction.moveTo(CGPoint(x: -bomb.size.width*0.6, y: random(min: 0, max: gameViewHeight)), duration: Ast_Time)
        let turn = SKAction.rotateByAngle(random(min: -1, max: 1), duration: 1.5)
        
        bomb.runAction(SKAction.repeatActionForever(turn))
        
        bomb.runAction(SKAction.sequence([move, SKAction.removeFromParent()]))
        
    }
   
    
    func spawnEnemy () {
        let enemy = EnemyClass(Leben: 4, MovingTime: Ast_Time*2)
        
        enemy.position = CGPoint(x: size.width + enemy.size.width, y: random(min: 0, max: gameViewHeight))
        enemy.setCenterPoint(CGPoint(x: size.width - enemy.size.width, y: gameViewHeight/2))
        enemy.setCage_Y(gameViewHeight/2)
        enemy.setCage_X(size.width/10)
        
        ObjektMotherNode.addChild(enemy)
        
        enemysAlive += 1
        
        let moveInAction = SKAction.moveToX(size.width - enemy.size.width*0.7, duration: 0.6)
        moveInAction.timingMode = SKActionTimingMode.EaseOut
        let shootAction = SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock({
                    self.ObjektMotherNode.addChild(enemy.shootLaser(self.Game_Raumschiff.position, praezisionInPercent: 100-(CGFloat(self.Ast_Time)*17), gameViewHeight: self.gameViewHeight))}),
                SKAction.waitForDuration(self.Ast_Time*0.7)
            ])
        )
        
        enemy.runAction(SKAction.sequence([
            moveInAction,
            SKAction.waitForDuration(2),
            shootAction
            ]), withKey: "shootAction")
        
        
        
        enemy.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock({enemy.flyEnemy()}), SKAction.waitForDuration(0.1)])))
    }
    
    
    func spawnPowerUp () {

        let Game_PowerUp = SKSpriteNode(imageNamed: "Game_PowerUp_UP_v1")
        Game_PowerUp.physicsBody = SKPhysicsBody(rectangleOfSize: Game_PowerUp.size)
        Game_PowerUp.zPosition = 0.5
        Game_PowerUp.position = CGPoint(x: -Game_PowerUp.size.width, y: -Game_PowerUp.size.height)
        
        let lowerBorder = 0
        let upperBorder = 4
        
        let RandomPowerUp = randomInt(min: lowerBorder, max: upperBorder)
        
        if RandomPowerUp == 0 {
            
            Game_PowerUp.physicsBody?.categoryBitMask = PhysicsCategory.PhyPowerUp1UP
            
        } else if RandomPowerUp <= 2 {
            
            Game_PowerUp.texture = SKTexture(imageNamed: "Game_PowerUp_ML_v1")
            Game_PowerUp.physicsBody?.categoryBitMask = PhysicsCategory.PhyPowerUpMultiLaser
            
        } else if RandomPowerUp <= 4 {
            
            Game_PowerUp.texture = SKTexture(imageNamed: "Game_PowerUp_PL_v1")
            Game_PowerUp.physicsBody?.categoryBitMask = PhysicsCategory.PhyPowerUpPowerLaser
            
        }
        
        Game_PowerUp.physicsBody?.contactTestBitMask = PhysicsCategory.PhyLaser
        Game_PowerUp.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        PwrUp_Node.addChild(Game_PowerUp)
        
        let Game_PowerUp_Rahmen = SKSpriteNode(imageNamed: "Game_PowerUp_Rahmen_v1")
        
        Game_PowerUp_Rahmen.position = CGPoint(x: 0, y: 0)
        Game_PowerUp.addChild(Game_PowerUp_Rahmen)
        
        let possible_y_start = [-Game_PowerUp_Rahmen.size.height/2, size.height+Game_PowerUp_Rahmen.size.height/2]
        
        let arrayPos = randomInt(min: 0, max: 1)
        
        let y_start = possible_y_start[arrayPos]
        let y_end = possible_y_start[abs(arrayPos-1)]
        
        let x_start = (size.width*0.8) + random(min: 0, max: size.width*0.2)
        let x_end = (size.width*0.4) + random(min: 0, max: size.width*0.2)

        Game_PowerUp.runAction(SKAction.moveTo(CGPoint(x: x_start, y: y_start), duration: 0))
        
        let PwrUpMovement = SKAction.moveTo(CGPoint(x: x_end, y: y_end), duration: Ast_Time)
        
        let PwrUpMoveAlong = SKAction.sequence([PwrUpMovement, SKAction.runBlock({Game_PowerUp_Rahmen.removeFromParent(); Game_PowerUp.removeFromParent()})])
        
        let PowerUpRahmenRotation = SKAction.rotateByAngle(CGFloat(-M_PI/Double(2)), duration: 1.0)
        
        Game_PowerUp.runAction(PwrUpMoveAlong)
        Game_PowerUp_Rahmen.runAction(SKAction.repeatActionForever(PowerUpRahmenRotation))
    
    }
    
    
    func spawnEnergy () {
        
        let carrierNode = SKSpriteNode(color: UIColor.blueColor(), size: CGSize(width: 6, height: 6))
        carrierNode.position = CGPoint(x: size.width*1.05, y: random(min: 0, max: gameViewHeight))
        carrierNode.zPosition = 0.8
        
        carrierNode.physicsBody = SKPhysicsBody(rectangleOfSize: carrierNode.size)
        carrierNode.physicsBody?.categoryBitMask = PhysicsCategory.PhyEnergySlice
        carrierNode.physicsBody?.contactTestBitMask = PhysicsCategory.PhyRaumschiff
        carrierNode.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        ObjektMotherNode.addChild(carrierNode)
    
        let emitterNode = SKEmitterNode(fileNamed: "energySlice")
        emitterNode?.targetNode = carrierNode
        emitterNode?.position = CGPoint(x: 0, y: 0)
        emitterNode?.zPosition = 0.01
        carrierNode.addChild(emitterNode!)
    
        var duration = Ast_Time*0.8
        if duration == 0 {
            duration = 3.5
        }
        
        carrierNode.runAction(SKAction.sequence([SKAction.moveTo(CGPoint(x: -size.width*0.05, y: random(min: 0, max: gameViewHeight)), duration: duration), SKAction.runBlock({carrierNode.removeFromParent()})]))
    }

  
//-----------------------------------------------------------------------------------------------------------------------------
//-- pro controls --
//-----------------------------------------------------------------------------------------------------------------------------
    func pro_shootLaserSetup () {
    
        var Laser_Menge : CGFloat = CGFloat(PwrUp_Mlt_Lasermenge)
        let LaserStreuwinkel = DegToRad(6)
        Laser_Menge = Laser_Menge - 1
        var Oeffnungswinkel = ((Laser_Menge)/2) * LaserStreuwinkel
        
        while Laser_Menge > 0 {
            pro_shootLaserByAngle(Oeffnungswinkel)
            pro_shootLaserByAngle(-Oeffnungswinkel)
            Oeffnungswinkel = Oeffnungswinkel - LaserStreuwinkel
            Laser_Menge = Laser_Menge - 2
        }
        pro_shootLaserByAngle(0)
        
        if let sound = playSoundEffectGame(soundEffect_shoot, looped: false) {
            ObjektMotherNode.addChild(sound)
        }
        
        if !Tut_Active {
            energyProgressBar!.addProgressInPercent(-0.8)
        }
    }
    
    
    func pro_shootLaserByAngle (Schusswinkel_Offset: CGFloat) {
        
        let Schusswinkel = Game_Raumschiff.zRotation + Schusswinkel_Offset
        
        let Laser_Vektor = CGVector(dx: cos(Schusswinkel)*1000, dy: sin(Schusswinkel)*1000)
        
        let Game_Laser = LaserSprite(imageNamed: "Game_LaserRot_v2")
        Game_Laser.sisterLaserCount = PwrUp_Mlt_Lasermenge
        Game_Laser.zPosition = 1.05
        Game_Laser.anchorPoint = CGPointMake(0, 0.5)
        
        let pos = CGPoint(x: Game_Raumschiff.position.x + Game_Raumschiff_Laserkanone.position.x, y: Game_Raumschiff.position.y + Game_Raumschiff_Laserkanone.position.y)
        
        Game_Laser.position = pos
        
        if PwrUp_Pwr_Active {
            Game_Laser.texture = SKTexture(imageNamed: "Game_LaserBlau_v2")
            Game_Laser.isPowerLaser = true
        }
        
        Game_Laser.physicsBody = SKPhysicsBody(rectangleOfSize: Game_Laser.size)
        Game_Laser.physicsBody?.dynamic = true
        
        Game_Laser.physicsBody?.categoryBitMask = PhysicsCategory.PhyLaser
        
        
        Game_Laser.physicsBody?.collisionBitMask = PhysicsCategory.None
        Game_Laser.physicsBody?.usesPreciseCollisionDetection = true
   
        LaserMotherNode.addChild(Game_Laser)
        
        Game_Laser.runAction(SKAction.rotateByAngle(Schusswinkel, duration: 0.0))
        
        if Tut_Active == false {
            ShotsFired += 1
        }
        
        Game_Laser.runAction(SKAction.sequence([SKAction.moveBy(Laser_Vektor, duration: 2.0), SKAction.runBlock(removeFromParent)]))
        
    }
//-----------------------------------------------------------------------------------------------------------------------------
    
   
    func waveFunction () {
        
        let inverseValue : Double = Double(1/Ast_wave_period_length)
        
        let Intervall = Double(Ast_last_k + 1)*(M_PI/4)*inverseValue
        
        if Game_Runtime > Intervall {
            
            Ast_last_k += 1
            
            var spawnValue : Int = Int(abs(Double(Ast_wave_amplitude) * Game_Runtime * sin(Double(Ast_wave_period_length) * Game_Runtime)))+1
            //printKonsole(String("Asteroiden", Ast_to_spawn, "  k:", (Ast_last_k-1)))
            var SpawnIntervall : Double = 0
            
            if (Ast_last_k % 4) == 0 {
                Ast_last_k+=1
                let Abzug = Double(random(min: 0, max: (CGFloat(M_PI/12))))
                SpawnIntervall = ((M_PI/2)-Abzug) * inverseValue
            } else {
                let Abzug = Double(random(min: 0, max: (CGFloat(M_PI/24))))
                SpawnIntervall = ((M_PI/4)-Abzug) * inverseValue
            }
            
            //Geschwindigkeit berechnen
            
            if Game_Runtime < Double(Ast_Time_gP) {
                Ast_Time = Ast_Time_m*(Game_Runtime-Ast_Time_gP)+Ast_Time_min
            } else {
                Ast_Time = Ast_Time_min
            }
            
            struct enemyProperties {
                var chance : Float = 0
                var value : Int = 1
                var toSpawn : Int = 0
            }
        
            var enemy = enemyProperties()
                enemy.chance = 0.35
                enemy.value = 4
            
            var bomb = enemyProperties()
                bomb.chance = 0.65
                bomb.value = 2
            
            spawnValue -= (enemy.value/2) * enemysAlive
            
            let absoluteValue = spawnValue
            
            if Game_Runtime > 20 {
                while ((spawnValue > absoluteValue/3) && (spawnValue > 2)) {
                    let randomDecisionValue = random(min: 0, max: 1)
                    
                    if randomDecisionValue < 0.75 {
                        if Game_Runtime > 20 {
                            //bomb
                            bomb.toSpawn += 1
                            spawnValue -= bomb.value
                        }
                    } else {
                        if Game_Runtime > 30 {
                            //enemy
                            enemy.toSpawn += 1
                            spawnValue -= enemy.value
                        }
                    }
                }
            }
            
            
            if bomb.toSpawn > 0 {
                ObjektMotherNode.runAction(SKAction.repeatAction(SKAction.sequence([
                    SKAction.runBlock({self.spawnBomb()}),
                    SKAction.waitForDuration(SpawnIntervall/Double(bomb.toSpawn))]), count: Int(bomb.toSpawn)))
            }
            
            if enemy.toSpawn > 0 {
                ObjektMotherNode.runAction(SKAction.repeatAction(SKAction.sequence([
                    SKAction.runBlock({self.spawnEnemy()}),
                    SKAction.waitForDuration(SpawnIntervall/Double(enemy.toSpawn))]), count: Int(enemy.toSpawn)))
            }
            
            ObjektMotherNode.runAction(SKAction.repeatAction(SKAction.sequence([
                SKAction.runBlock({self.spawnStdAst(CGPoint(x: 0, y:0), useGivenStart: false, asMiniAsteroid: false)}),
                SKAction.waitForDuration(SpawnIntervall/Double(spawnValue))]), count: Int(spawnValue)))
            
        }
        
    }
    
    
    func spawnStdAst (givenStart: CGPoint, useGivenStart: Bool, asMiniAsteroid: Bool) {
        
        let ast_texture_array = ["Game_Asteroid_1", "Game_Asteroid_2", "Game_Asteroid_3"]
        
        let blendColor = ast_color_array[randomInt(min: 0, max: ast_color_array.count-1)]
        let textureName = ast_texture_array[randomInt(min: 0, max: ast_texture_array.count-1)]
        
        let Game_StdAst = AsteroidSprite(imageNamed: textureName)
        Game_StdAst.color = blendColor
        Game_StdAst.colorBlendFactor = random(min: 0, max: 0.3)
        
        if asMiniAsteroid {
            Game_StdAst.setScale(random(min: 0.4, max: 0.6))
            Game_StdAst.isMiniAst = true
        } else {
            Game_StdAst.setScale(random(min: 0.9, max: 1.1))
        }
        
        Game_StdAst.zPosition = 0.5
        
        Game_StdAst.physicsBody = SKPhysicsBody(rectangleOfSize: Game_StdAst.size)
        Game_StdAst.physicsBody?.categoryBitMask = PhysicsCategory.PhyStdAst
        Game_StdAst.physicsBody?.contactTestBitMask = PhysicsCategory.PhyLaser | PhysicsCategory.PhyBombExpl

        Game_StdAst.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let StdAstStart = CGPoint(x: size.width + Game_StdAst.size.width*1/2, y: random(min: 0 + Game_StdAst.size.height/2, max: gameViewHeight - Game_StdAst.size.height/2))
        
        //Wie viel Prozent des Views muss der Asteroid noch zurück legen?
        var PercPosInViewX : CGFloat
        
        if useGivenStart == false {
            Game_StdAst.position = StdAstStart
            PercPosInViewX = 1
        } else {
            Game_StdAst.position = givenStart
            PercPosInViewX = (Game_StdAst.position.x - Game_StdAst.size.width/2)/size.width
        }
        
        ObjektMotherNode.addChild(Game_StdAst)

        //!! Ziel-Streuung muss mit Abstand kleiner werden
        var StdAstZiel = CGPoint(x: -Game_StdAst.size.width*1/2, y: random(min: Game_StdAst.position.y-(gameViewHeight*(1/3)*PercPosInViewX), max: Game_StdAst.position.y+(gameViewHeight*(1/3)*PercPosInViewX)))
        
        if StdAstZiel.y > gameViewHeight-Game_StdAst.size.height/2 {
            StdAstZiel.y = gameViewHeight-Game_StdAst.size.height/2
        }
        
        if StdAstZiel.y < Game_StdAst.size.height/2 {
            StdAstZiel.y = Game_StdAst.size.height/2
        }
        
        let StdAstRotation = SKAction.repeatActionForever(SKAction.rotateByAngle(randomPosOrNeg() * CGFloat(M_PI/Double(2)), duration: Double(random(min: 1.5, max: 3.0))))

        var Bewegungsdauer : Double = Double(PercPosInViewX)*Ast_Time*Double(random(min: 1, max: 1.3))
        
        if useGivenStart == true {
            Bewegungsdauer = Bewegungsdauer*BigAst_Slower
        }
        
        Game_StdAst.runAction(StdAstRotation)
        Game_StdAst.runAction(SKAction.sequence([
            SKAction.moveTo(StdAstZiel, duration: Bewegungsdauer),
            SKAction.runBlock({Game_StdAst.removeFromParent()}),
            ]))
        
    }
    
    
    func testForLowEnergy () {
        if energyProgressBar!.getProgress() <= 20 && !lowEnergyWarning.isActive {
            lowEnergyWarning.isActive = true
            lowEnergyWarning.removeActionForKey("stopEnergyWarning")
            lowEnergyWarning.runAction(
                SKAction.sequence([
                    SKAction.fadeAlphaTo(0.5, duration: 0.5625),
                    SKAction.repeatActionForever(SKAction.sequence([
                        SKAction.fadeAlphaTo(0.1, duration: 0.5625),
                        SKAction.fadeAlphaTo(0.5, duration: 0.5625)
                        ]))
                    ]), withKey: "startEnergyWarning")
            
            if let sound = playSoundEffectGame(soundEffect_longAlarm, looped: true) {
                lowEnergyWarning.addChild(sound)
            }
        }
        
        if energyProgressBar!.getProgress() >= 25 && lowEnergyWarning.isActive {
            lowEnergyWarning.isActive = false
            lowEnergyWarning.removeActionForKey("startEnergyWarning")
            lowEnergyWarning.runAction(SKAction.fadeAlphaTo(0, duration: 0.5625), withKey: "stopEnergyWarning")
            
            lowEnergyWarning.removeAllChildren()
        }
        
    }
    
    
    func aktualisiereLeben (x: CGFloat) {
        if x < 0 {
            vibrate()
        }
        
        energyProgressBar?.addProgressInPercent(x)
        
        testForGameOver()
    }
    
    func energyStillZero () {
        if energyProgressBar!.barIsEmpty() && Testing_GameOverAllowed {
            
            saveStatsForGameOver()
            
            loadView("GameOver")
        }
    }
    
    func testForGameOver () {
        
        if energyProgressBar!.barIsEmpty() && Testing_GameOverAllowed {
            
            ObjektMotherNode.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock({self.energyStillZero()})]))
        }
    }
    
    
    //Bekommt zu testende Bitmasks und gibt, falls die Kollisionsobjekte den Bitmasks entsprechen, die Objekte in der Eingabereihenfolge als SKPhysicsBody zurück
    func testForContact (contact contact: SKPhysicsContact, bitmaskObject1: UInt32, bitmaskObject2: UInt32) -> (SKPhysicsBody, SKPhysicsBody)? {
        
        if contact.bodyA.node == nil || contact.bodyB.node == nil {
            return nil
        }
        
        if contact.bodyA.categoryBitMask == bitmaskObject1 && contact.bodyB.categoryBitMask == bitmaskObject2 {
            return (contact.bodyA, contact.bodyB)
        }
        
        if contact.bodyA.categoryBitMask == bitmaskObject2 && contact.bodyB.categoryBitMask == bitmaskObject1 {
            return (contact.bodyB, contact.bodyA)
        }
        
        return nil
    }
    
    
    func laserHitsSomething (laserNode: LaserSprite) {
        if laserNode.isPowerLaser {
            laserNode.targetsHit += 1
        } else {
            laserNode.removeFromParent()
        }
        
    }
    
    
    func showImpulsOnShield (contactPos: CGPoint) {
        let schildImpuls = SKSpriteNode(imageNamed: "Tutorial_Tap")
        schildImpuls.setScale(0.01)
        schildImpuls.color = setRGBColor(red: 93, green: 6, blue: 90, alpha: 1)
        schildImpuls.colorBlendFactor = 1
        schildImpuls.position = CGPoint(x: contactPos.x - spaceshipEngineRefNode.position.x, y: contactPos.y - spaceshipEngineRefNode.position.y)
        Game_RS_Schild_Crop.addChild(schildImpuls)
        
        schildImpuls.runAction(SKAction.sequence([
            SKAction.group([
                SKAction.scaleTo(1, duration: 0.35),
                SKAction.sequence([SKAction.waitForDuration(0.15), SKAction.fadeAlphaTo(0, duration: 0.2)])
                ]),
            SKAction.removeFromParent()
            ]))
        
    }
    
    
    func didBeginContact (contact: SKPhysicsContact) {
        
        
        //------------------------------------
        //  Kollision mit eigenem Laser
        
        //Kollision: eigener Laser und StdAst
        if let (laser, stdAst) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyLaser, bitmaskObject2: PhysicsCategory.PhyStdAst) {
        
            let laserNode = (laser.node as! LaserSprite)
            let stdAstNode = (stdAst.node as! SKSpriteNode)
            
            addToScoreWithPosition(2, previousHits: laserNode.targetsHit, position: stdAstNode.position)
            
            showExplosion(isPowerLaser: laserNode.isPowerLaser, pos: stdAstNode.position)
            
            AsteroidsHit += 1
            
            laserHitsSomething(laserNode)
            
            
            let neueStdAstPos = stdAstNode.position
            let BigAstWidthHalf = stdAstNode.size.width/2
            
            if random(min: 0, max: 1) > 0.8 && Game_Runtime > 15 && stdAstNode.xScale > 0.75 {
                let neueStdAstMenge = randomInt(min: 2, max: 4)
            
                for _ in 1...neueStdAstMenge {
                    let ChildAstPos = CGPoint(x: neueStdAstPos.x+random(min: -BigAstWidthHalf, max: BigAstWidthHalf), y: neueStdAstPos.y+random(min: -BigAstWidthHalf, max: BigAstWidthHalf))
                    spawnStdAst(ChildAstPos, useGivenStart: true, asMiniAsteroid: true)
                }
            }
            
            stdAstNode.removeFromParent()
            
            return
        }
        
        //Kollision: eigener Laser und Enemy
        if let (laser, enemy) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyLaser, bitmaskObject2: PhysicsCategory.PhyEnemy) {
            
            let laserNode = (laser.node as! LaserSprite)
            let enemyNode = (enemy.node as! EnemyClass)
            
            addToScoreWithPosition(2, previousHits: laserNode.targetsHit, position: enemyNode.position)
            showExplosion(isPowerLaser: laserNode.isPowerLaser, pos: laserNode.position)
            
            let finalHit = enemyNode.gotHitAndIsExploding(laserNode.isPowerLaser)
            
            if finalHit {
                enemysKilled += 1
                enemysAlive -= 1
                enemyNode.removeActionForKey("shootAction")
            }
            
            laserHitsSomething(laserNode)
            
            return
        }
        
        //Kollision: Laser und BombBody
        if let (laser, bombBody) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyLaser, bitmaskObject2: PhysicsCategory.PhyBombBody) {
            
            let laserNode = (laser.node as! LaserSprite)
            let bombBodyNode = (bombBody.node as! BombClass)
            
            addToScoreWithPosition(2, previousHits: laserNode.targetsHit, position: bombBodyNode.position)
            laserHitsSomething(laserNode)
            
            bombBodyNode.explode()
            return
        }
        
        //Kollision: eigener Laser und Power Up 1Up
        if let (laser, pwrUp) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyLaser, bitmaskObject2: PhysicsCategory.PhyPowerUp1UP) {
            
            let laserNode = (laser.node as! LaserSprite)
            let pwrUpNode = (pwrUp.node as! SKSpriteNode)
            
            aktualisiereLeben(100)
            collectedPowerUps += 1
            addToScoreWithPosition(4, previousHits: laserNode.targetsHit, position: pwrUpNode.position)
            Game_Raumschiff.gotEnergy()
            showExplosion(isPowerLaser: laserNode.isPowerLaser, pos: pwrUpNode.position)
            
            pwrUpNode.removeFromParent()
            laserHitsSomething(laserNode)
            
            powerUpSound()
            
            return
        }
        
        //Kollision: eigener Laser und Power Up Multilaser
        if let (laser, pwrUp) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyLaser, bitmaskObject2: PhysicsCategory.PhyPowerUpMultiLaser) {
            
            let laserNode = (laser.node as! LaserSprite)
            let pwrUpNode = (pwrUp.node as! SKSpriteNode)
            
            collectedPowerUps += 1
            addToScoreWithPosition(4, previousHits: laserNode.targetsHit, position: pwrUpNode.position)
            
            PwrUp_Mlt_Lasermenge = 3
            
            ObjektMotherNode.removeActionForKey("reduceLasers")
            ObjektMotherNode.runAction(SKAction.sequence([SKAction.waitForDuration(10), SKAction.runBlock({self.PwrUp_Mlt_Lasermenge = 1})]), withKey: "reduceLasers")
            
            showExplosion(isPowerLaser: laserNode.isPowerLaser, pos: pwrUpNode.position)
            
            pwrUpNode.removeFromParent()
            laserHitsSomething(laserNode)
            
            powerUpSound()
            
            return
        }
        
        //Kollision: eigener Laser und Power Up Powerlaser
        if let (laser, pwrUp) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyLaser, bitmaskObject2: PhysicsCategory.PhyPowerUpPowerLaser) {
            
            let laserNode = (laser.node as! LaserSprite)
            let pwrUpNode = (pwrUp.node as! SKSpriteNode)
            
            collectedPowerUps += 1
            addToScoreWithPosition(4, previousHits: laserNode.targetsHit, position: pwrUpNode.position)
            
            PwrUp_Pwr_Active = true
            showExplosion(isPowerLaser: laserNode.isPowerLaser, pos: pwrUpNode.position)
            
            ObjektMotherNode.removeActionForKey("depowerLaser")
            ObjektMotherNode.runAction(SKAction.sequence([SKAction.waitForDuration(10), SKAction.runBlock({self.PwrUp_Pwr_Active = false})]), withKey: "depowerLaser")
            
            pwrUpNode.removeFromParent()
            laserHitsSomething(laserNode)
            
            powerUpSound()
            
            return
        }
        
        //Kollision: eigener Laser und Tutorial-Exit-Asteroid
        if let (laser, _) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyLaser, bitmaskObject2: PhysicsCategory.PhyTutExitAst) {
            
            let laserNode = (laser.node as! LaserSprite)
            
            laserNode.removeFromParent()
            showExplosion(isPowerLaser: false, pos: contact.contactPoint)
            
            TutorialSteps.runAction(SKAction.sequence([
                SKAction.waitForDuration(0.5),
                SKAction.fadeAlphaTo(0, duration: 0.5),
                SKAction.runBlock({
                    self.exitTutorial()
                })
                ]))
            
            
            
            return
        }
        
        
        
        //------------------------------------
        //  Kollision mit Raumschiff
        
        //Kollision: Raumschiff und StdAst
        if let (spaceship, stdAst) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyRaumschiff, bitmaskObject2: PhysicsCategory.PhyStdAst) {
            //print("Raumschiff getroffen")
            let stdAstNode = (stdAst.node as! AsteroidSprite)
            let spaceshipNode = (spaceship.node as! SpaceshipNode)
            
            showExplosion(isPowerLaser: false, pos: stdAstNode.position)
            
            if stdAstNode.isMiniAst {
                aktualisiereLeben(-8)
            } else {
                aktualisiereLeben(-25)
            }
            
            stdAstNode.removeFromParent()
            spaceshipNode.gotHit()
            
            return
        }
        
        //Kollision: Raumschiff und feindlicher Laser
        if let (spaceship, enemyLaser) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyRaumschiff, bitmaskObject2: PhysicsCategory.PhyEnemyLaser) {
            let enemyLaserNode = (enemyLaser.node as! SKSpriteNode)
            let spaceshipNode = (spaceship.node as! SpaceshipNode)
            
            let fileName = "explosion_green"
            
            let EmitterNode = SKEmitterNode(fileNamed: fileName)
            
            EmitterNode?.position = enemyLaserNode.position
            EmitterNode?.zPosition = 0.6
            EmitterNode?.setScale(0.5)
            ObjektMotherNode.addChild(EmitterNode!)
            EmitterNode?.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock({EmitterNode?.removeFromParent()})]))
            
            if let sound = playSoundEffectGame(soundEffect_explosion, looped: false) {
                spaceshipNode.addChild(sound)
            }
            
            enemyLaserNode.removeFromParent()
            
            aktualisiereLeben(-10)
            spaceshipNode.gotHit()
            
            return
        }
        
        //Kollision: Raumschiff und BombBody
        if let (_, bomb) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyRaumschiff, bitmaskObject2: PhysicsCategory.PhyBombBody) {
            
            let bombNode = (bomb.node as! BombClass)
            bombNode.explode()
            
            return
        }
        
        //Kollision: Raumschiff und BombExpl
        if let (spaceship, expl) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyRaumschiff, bitmaskObject2: PhysicsCategory.PhyBombExpl) {
            
            let explNode = (expl.node as! BombExplNode)
            
            if !explNode.hitSpaceship {
            
                let spaceshipNode = (spaceship.node as! SpaceshipNode)
                aktualisiereLeben(-15)
                spaceshipNode.gotHit()
                explNode.hitSpaceship = true
           
            }
            
            return
        }
        
        //Kollision: Raumschiff und Energie
        if let (spaceship, energy) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyRaumschiff, bitmaskObject2: PhysicsCategory.PhyEnergySlice) {
            
            let energyNode = (energy.node as! SKSpriteNode)
            let spaceshipNode = (spaceship.node as! SpaceshipNode)
            
            energyNode.removeFromParent()
            spaceshipNode.gotEnergy()
            
            collectedEnergy += 1
            aktualisiereLeben(10)
            return
        }
        
        
        //------------------------------------
        //  Kollision mit Schild
        
        //Kollision: Schild und StdAst
        if let (_, stdAst) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhySchild, bitmaskObject2: PhysicsCategory.PhyStdAst) {
            
            let stdAstNode = (stdAst.node as! SKSpriteNode)
            
            showExplosion(isPowerLaser: false, pos: stdAstNode.position)
            stdAstNode.removeFromParent()
            
            showImpulsOnShield(contact.contactPoint)
            
            if let sound = playSoundEffectGame(soundEffect_explosion, looped: false) {
                Game_Raumschiff.addChild(sound)
            }
            
            return
        }
        
        //Kollision: Schild und feindlicher Laser
        if let (_, enemyLaser) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhySchild, bitmaskObject2: PhysicsCategory.PhyEnemyLaser) {
            let enemyLaserNode = (enemyLaser.node as! SKSpriteNode)
            
            let fileName = "explosion_green"
            
            let EmitterNode = SKEmitterNode(fileNamed: fileName)
            
            EmitterNode?.position = enemyLaserNode.position
            EmitterNode?.zPosition = 0.6
            EmitterNode?.setScale(0.5)
            ObjektMotherNode.addChild(EmitterNode!)
            EmitterNode?.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.removeFromParent()]))
            
            enemyLaserNode.removeFromParent()
            
            showImpulsOnShield(contact.contactPoint)
            
            if let sound = playSoundEffectGame(soundEffect_explosion, looped: false) {
                Game_Raumschiff.addChild(sound)
            }
            
            return
        }
        
        //Kollision: Schild und BombBody
        if let (_, bomb) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhySchild, bitmaskObject2: PhysicsCategory.PhyBombBody) {
            
            let bombNode = (bomb.node as! BombClass)
            bombNode.explode()
            
            return
        }
        
        //Kollision: Schild und BobyExpl
        if let (_, expl) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhySchild, bitmaskObject2: PhysicsCategory.PhyBombExpl) {
            
            let explNode = (expl.node as! BombExplNode)
            
            if !explNode.hitSpaceship {
                
                showImpulsOnShield(contact.contactPoint)
                explNode.hitSpaceship = true
                
            }
            return
        }
        
        
        //------------------------------------
        //  Kollision mit Explosion
        
        //Kollision: BombExpl und Enemy
        if let (_, enemy) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyBombExpl, bitmaskObject2: PhysicsCategory.PhyEnemy) {
            
            let enemyNode = (enemy.node as! EnemyClass)
            
            addToScoreWithPosition(2, previousHits: 1, position: contact.contactPoint)
            
            let finalHit = enemyNode.gotHitAndIsExploding(true)
           
            if finalHit {
                enemysKilled += 1
                enemysAlive -= 1
                enemyNode.removeActionForKey("shootAction")
            }
            
            return
        }
        
        //Kollision: BombExpl und StdAst
        if let (_, stdAst) = testForContact(contact: contact, bitmaskObject1: PhysicsCategory.PhyBombExpl, bitmaskObject2: PhysicsCategory.PhyStdAst) {
            
            let stdAstNode = (stdAst.node as! SKSpriteNode)
            
            addToScoreWithPosition(2, previousHits: 1, position: contact.contactPoint)
            
            showExplosion(isPowerLaser: false, pos: stdAstNode.position)
            stdAstNode.removeFromParent()
            
            AsteroidsHit += 1
            
            return
        }
        
    }
    
    
    func powerUpSound () {
        if let sound = playSoundEffectGame(soundEffect_powerUp, looped: false) {
            ObjektMotherNode.addChild(sound)
        }
    }
    
    
    func addToScoreWithPosition (rawValue: Int, previousHits: Int, position: CGPoint) {
        
        let value = addToScore(rawValue, previousHits: previousHits)
        
        let text = SKLabelNode(fontNamed: "Arial-MT")
        text.fontSize = 50
        text.fontColor = whiteFont
        text.setScale(0)
        text.text = "+" + String(value)
        text.position = position
        text.zPosition = 2.8
        
        ObjektMotherNode.addChild(text)
        
        let scaleToOne = SKAction.scaleTo(1, duration: 0.5)
        
        let fadeOut = SKAction.sequence([SKAction.waitForDuration(0.2), SKAction.fadeOutWithDuration(0.2)])
        
        let action = SKAction.sequence([
            SKAction.group([scaleToOne, fadeOut]),
            SKAction.runBlock({self.removeFromParent()})
            ])
        
        text.runAction(action)
    }
    
    
    func addToScore (rawValue: Int, previousHits: Int) -> Int {
        
        var value = rawValue
        
        value = potenziereInt(value, hoch: previousHits+1)
        
        Score += value
        powerUpProgressBar!.addProgressInPercent(CGFloat(value))
        if powerUpProgressBar!.barIsFull() && !willSpawnPowerUp {
            willSpawnPowerUp = true
            prepareForSpawnPowerUp()
        }
        ScoreLabel.text = "score: " + String(Score)
        
        return value
    }
    
    
    func prepareForSpawnPowerUp () {
        
        let powerUpText = SKLabelNode(fontNamed: "Arial-MT")
        powerUpText.text = "power up"
        powerUpText.fontColor = UIColor.whiteColor()
        powerUpText.fontSize = 40
        powerUpText.alpha = 0.4
        powerUpText.setScale(0.3)
        powerUpText.position = CGPoint(x: Game_Statusbar.position.x + powerUpProgressBar!.position.x, y: Game_Statusbar.position.y + powerUpProgressBar!.position.y)
        ObjektMotherNode.addChild(powerUpText)
        
        let moveAction = SKAction.moveTo(CGPoint(x: size.width/2, y: gameViewHeight/2), duration: 0.8)
        moveAction.timingMode = SKActionTimingMode.EaseInEaseOut
        let scaleAction = SKAction.scaleTo(1, duration: 0.8)
        let fadeInAction = SKAction.fadeAlphaTo(0.8, duration: 0.8)
        let fadeOutAction = SKAction.fadeAlphaTo(0, duration: 0.2)
        
        let animateAction = SKAction.group([
            moveAction,
            scaleAction,
            SKAction.sequence([fadeInAction, fadeOutAction])
            ])
        
        powerUpText.runAction(SKAction.sequence([animateAction, SKAction.removeFromParent()]))
        ObjektMotherNode.runAction(SKAction.sequence([
            SKAction.waitForDuration(0.8),
            SKAction.runBlock({
                self.powerUpProgressBar!.setProgressInPercent(0)
                self.spawnPowerUp()
                self.willSpawnPowerUp = false
            })
            ]))
        
    }
    
    
    func touchInPlayPauseButton (location: CGPoint) -> Bool {
        
        if location.x >= size.width-Game_Statusbar.size.height && location.y >= size.height-Game_Statusbar.size.height {
            return true
            
        }
        return false
    }
    
    override func touchesBegan (touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let Touch_location = touch.locationInNode(self)
    
            if touchInPlayPauseButton(Touch_location) {
                Pause_Brick_1.colorBlendFactor = 0.55
                Pause_Brick_2.colorBlendFactor = 0.55
                Pause_Brick_3.colorBlendFactor = 0.55
                if let sound = playSoundEffect(soundEffect_buttonKlick, looped: false) {
                    self.addChild(sound)
                }
            }
            
            
            if GamePaused == false {
                
                if Touch_location.y <= gameViewHeight {
                    if Touch_location.x >= size.width/2 {
                        touchesBegan_shoot()
                    } else {
                        touchesBegan_shield()
                    }
                    
                }
            }
        }
    }

    
    override func touchesMoved (touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    
    override func touchesEnded (touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let Touch_location = touch.locationInNode(self)
            
            if touchInPlayPauseButton(Touch_location) {
                //Pause Button gedrückt
                buttonPressed_StatBar_PlayPause()
            }
            
            if GamePaused == false {
                //Spiel läuft
                touchesEnded_shoot()
                touchesEnded_shield()
            }
        }
        Pause_Brick_1.colorBlendFactor = 0
        Pause_Brick_2.colorBlendFactor = 0
        Pause_Brick_3.colorBlendFactor = 0
    }
    
    
    func FlyRaumschiff () {
        //wird in update aufgerufen
        
        //X
        if RSMovement_X_Active == false {
            
            //Bewegungsspielraum
            var maxMove_X : CGFloat = 0
            var minMove_X : CGFloat = 0
            
            maxMove_X = maxAbs( (RSCenterPoint.x-RSCage_X) - Game_Raumschiff.position.x , b: (RSCenterPoint.x+RSCage_X) - Game_Raumschiff.position.x)
            minMove_X = (1/3)*maxMove_X
           
            var MoveDistanceX = random(min: abs(minMove_X), max: abs(maxMove_X))
            if maxMove_X < 0 {
                MoveDistanceX = MoveDistanceX * (-1)
            }
            
            RSMovement_X_Active = true
            
            let move_X_action = SKAction.moveToX(Game_Raumschiff.position.x + MoveDistanceX , duration: 2.5)
            move_X_action.timingMode = SKActionTimingMode.EaseInEaseOut
            Game_Raumschiff.runAction(SKAction.sequence([move_X_action, SKAction.runBlock({self.RSMovement_X_Active = false})]))
            
        }
        
    }
    
    
    func runTutorial () {
        
        Tut_Active = getBoolOption("show_tutorial")
        
        if !Tut_Active {
            spawnNode.runAction(SKAction.sequence([
                SKAction.waitForDuration(2),
                SKAction.runBlock({
                    self.energyAndPowerUpActions()
                })]))
            return
        }
        
        addChild(TutorialNode)
        TutorialNode.zPosition = 2.5
        TutorialNode.addChild(TutorialSteps)
    
        tutorial_stepOne_setup()
        
        tutUpdFunction = tutorial_stepOne_update
        
    }
    
    
    func tutorial_stepOne_setup () {
        
        tutUpdFunction = tutorial_stepOne_update
        
        let tutStep1Instance = stepOneClass(gameViewHeight: gameViewHeight, gameViewWidth: size.width, endFunction: tutorial_stepOne_finish)
        tutStep1Instance.position = CGPoint(x: 0, y: 0)
        TutorialSteps.addChild(tutStep1Instance)
        
        TutorialSteps.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.runBlock({tutStep1Instance.deliverSpaceshipPos(self.Game_Raumschiff.position.y)}),
            SKAction.waitForDuration(0.05)
        ])))
    }
    
    func tutorial_stepOne_update () {
        return
    }
    
    func tutorial_stepOne_finish () {
        
        TutorialSteps.runAction(SKAction.sequence([
            SKAction.waitForDuration(0.5),
            SKAction.fadeAlphaTo(0, duration: 0.5),
            SKAction.runBlock({
                self.TutorialSteps.removeAllChildren()
                self.tutorial_stepTwo_setup()
            })
        ]))
    }

    
    func tutorial_stepTwo_setup () {
        
        TutorialSteps.removeAllActions()
        
        tutUpdFunction = tutorial_stepTwo_update
        
        let tutStep2Instance = stepTwoClass(gameViewHeight: gameViewHeight, gameViewWidth: size.width, leftTouchBegan: touchesBegan_shield, leftTouchEnded: touchesEnded_shield, rightTouchBegan: touchesBegan_shoot, rightTouchEnded: touchesEnded_shoot, endFunction: tutorial_stepTwo_finish)
        tutStep2Instance.position = CGPoint(x: 0, y: 0)
        TutorialSteps.addChild(tutStep2Instance)
        TutorialSteps.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
    }

    
    func tutorial_stepTwo_update () {
        return
    }
    
    func tutorial_stepTwo_finish () {
        TutorialSteps.runAction(SKAction.sequence([
            SKAction.waitForDuration(0.5),
            SKAction.fadeAlphaTo(0, duration: 0.5),
            SKAction.runBlock({
                self.TutorialSteps.removeAllChildren()
                self.tutorial_stepThree_setup()
            })
        ]))
    
    }
    
    
    func tutorial_stepThree_setup () {
        tutUpdFunction = tutorial_stepThree_update
        
        let title = SKLabelNode(fontNamed: "Arial-MT")
        title.text = "collect energy to keep on flying"
        title.verticalAlignmentMode = .Center
        title.horizontalAlignmentMode = .Center
        title.fontColor = whiteFont
        title.fontSize = 20
        title.position = CGPoint(x: size.width/2, y: gameViewHeight*0.9)
        TutorialSteps.addChild(title)
        
        TutorialSteps.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        
        spawnNode.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.runBlock({
                self.spawnEnergy()
            }),
            SKAction.waitForDuration(2)
        ])))
    }

    
    var tut_s3_transitionStarted : Bool = false
    func tutorial_stepThree_update () {
        
        if collectedEnergy >= 2 {
            if !tut_s3_transitionStarted {
                tut_s3_transitionStarted = true
                TutorialSteps.runAction(SKAction.sequence([
                    SKAction.waitForDuration(0.5),
                    SKAction.fadeAlphaTo(0, duration: 0.5),
                    SKAction.runBlock({
                        self.TutorialSteps.removeAllChildren()
                        self.collectedEnergy = 0
                        self.tutorial_stepFour_setup()
                    })
                ]))
            }
        }
    }
    
    
    func tutorial_stepFour_setup () {
        spawnNode.removeAllActions()
        tutUpdFunction = tutorial_stepFour_update
        
        let tutExitAst = SKSpriteNode(imageNamed: "Menu_Asteroid")
        tutExitAst.position = CGPoint(x: size.width*0.8, y: gameViewHeight/2)
        tutExitAst.color = UIColor.whiteColor()
        tutExitAst.colorBlendFactor = 0.25
        
        tutExitAst.physicsBody = SKPhysicsBody(texture: tutExitAst.texture!, size: (tutExitAst.texture?.size())!)
        tutExitAst.physicsBody?.categoryBitMask = PhysicsCategory.PhyTutExitAst
        tutExitAst.physicsBody?.contactTestBitMask = PhysicsCategory.PhyLaser
        tutExitAst.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        TutorialSteps.addChild(tutExitAst)
        
        let title = SKLabelNode(fontNamed: "Arial-BoldMT")
        title.text = "let's go!"
        title.alpha = 0.8
        title.verticalAlignmentMode = .Center
        title.horizontalAlignmentMode = .Center
        title.fontColor = whiteFont
        title.fontSize = 25
        title.position = CGPoint(x: 0, y: 0)
        title.zPosition = 0.1
        tutExitAst.addChild(title)
        
        TutorialSteps.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        
        tutExitAst.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(1, duration: 7)))
    }
    
    func tutorial_stepFour_update () {
        return
    }
    
    
    func organizeBackgroundParticles () {
        
        StarEmitter?.particleLifetime = (size.width / ((StarEmitter?.particleSpeed)! - (StarEmitter?.particleSpeedRange)!)) + (StarEmitter?.particleLifetimeRange)!
        StarEmitter?.particleSpeed = backgroundStdSpeed*CGFloat(BG_Speed)*backgroundSpeedMultiplier
        
        if Game_Runtime > Ast_Time_gP {
            BG_Speed = BG_Speed_max
        } else {
            BG_Speed = (BG_Speed_m*Float(Game_Runtime))+1
        }
        
    }

    
    func loadView (SzeneString: String) {
        
        extSoundNode.removeFromParent()
        
        runAction(SKAction.sequence([
            SKAction.runBlock({
                
                switch SzeneString {
                case "GameArea":
                    let transition = SKTransition.revealWithDirection(.Right, duration: 0.75)
                    self.view?.presentScene(MainGame(size: self.size), transition: transition)
                case "GameOver":
                    let transition = SKTransition.revealWithDirection(.Left, duration: 0.75)
                    self.view?.presentScene(GameOver(size: self.size), transition: transition)
                default:
                    let transition = SKTransition.revealWithDirection(.Right, duration: 0.75)
                    self.view?.presentScene(MainMenu(size: self.size), transition: transition)
                }
            })
            ]))
        
    }
    
    
    func showExplosion (isPowerLaser isPowerLaser: Bool, pos: CGPoint) {
        
        if let sound = playSoundEffectGame(soundEffect_explosion, looped: false) {
            ObjektMotherNode.addChild(sound)
        }
        
        var fileName = "explosion_red"
        
        if isPowerLaser {
            fileName = "explosion_blue"
        }
        
        let EmitterNode = SKEmitterNode(fileNamed: fileName)
        
        EmitterNode?.position = pos
        EmitterNode?.zPosition = 0.6
        EmitterNode?.setScale(0.5)
        ObjektMotherNode.addChild(EmitterNode!)
        EmitterNode?.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock({EmitterNode?.removeFromParent()})]))
    }
    
    
    func myAppMovedToBackground () {
        
        switchToPlayIcon(true)
        ButtonState_ShowPause = false
            
        ActivatePauseLayer(true)
    }
    
    
    func ActivatePauseLayer (Activate: Bool) {
        
        if Activate {
            
            GamePaused = true
        
            self.removeActionForKey("StartWorld")
            worldNode.speed = 0
            StarEmitter!.paused = true
            GamePauseNode.alpha = 1
            self.runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock({self.StarEmitter!.paused = true}), SKAction.waitForDuration(0.1)])), withKey: "StayPaused")
            
            pauseLayer.runAction(SKAction.fadeAlphaTo(0.6, duration: 0.7))
           
            Pause_QuitButton!.animationAppear()
            Pause_CaliButton!.animationAppear()
            let duration = Pause_QuitButton!.getAnimationDuration()
            
            let fontWidth = PauseTitle_right.frame.width*1.07 + PauseTitle_left.frame.width //Breite der Schrift + Leerzeichen
            
            let moveInLeft = SKAction.moveToX(size.width/2 - fontWidth/2, duration: duration)
            moveInLeft.timingMode = SKActionTimingMode.EaseOut
            let moveInRight = SKAction.moveToX(size.width/2 + fontWidth/2, duration: duration)
            moveInRight.timingMode = SKActionTimingMode.EaseOut
            PauseTitle_left.runAction(moveInLeft)
            PauseTitle_right.runAction(moveInRight)
            
            if Tut_Active {
                TutorialSteps.runAction(SKAction.fadeAlphaTo(0.1, duration: duration))
            }
           
            
        } else {
            
            Pause_QuitButton!.animationDisappear()
            Pause_CaliButton!.animationDisappear()
            let duration = Pause_QuitButton!.getAnimationDuration()
            let moveOutLeft = SKAction.moveToX(-PauseTitle_left.frame.width, duration: duration)
            moveOutLeft.timingMode = SKActionTimingMode.EaseIn
            let moveOutRight = SKAction.moveToX(size.width+PauseTitle_right.frame.width, duration: duration)
            moveOutRight.timingMode = SKActionTimingMode.EaseIn
            PauseTitle_right.runAction(moveOutRight)
            PauseTitle_left.runAction(moveOutLeft)
            
            GamePauseNode.runAction(SKAction.fadeAlphaTo(0, duration: 0.6))
            self.removeActionForKey("StayPaused")
            self.runAction(SKAction.sequence([SKAction.waitForDuration(duration),
                SKAction.runBlock({
                    self.worldNode.speed = 1;
                    self.StarEmitter!.paused = false;
                    self.GamePaused = false})
                ]), withKey: "StartWorld")
            
            pauseLayer.runAction(SKAction.fadeAlphaTo(0, duration: duration/2))
            
            if Tut_Active {
                TutorialSteps.runAction(SKAction.fadeAlphaTo(1, duration: duration))
            }
            if motionManager.deviceMotion?.gravity.x != nil {
                Game_Raumschiff.setOrientation((motionManager.deviceMotion?.gravity.x)!)
            }
            
        }
    }
    
    
    func spawnZielhilfe () {
        
        let Zielhilfe = SKSpriteNode(imageNamed: "Game_Zielhilfe")
        Zielhilfe.zPosition = -0.05
        Zielhilfe.alpha = 0.9
        
        let move = SKAction.moveBy(CGVector(dx: size.width/2.5, dy: 0), duration: 2)
        let fadeOut = SKAction.fadeOutWithDuration(2)
        
        Game_Raumschiff_Laserkanone.addChild(Zielhilfe)
        
        Zielhilfe.runAction(SKAction.sequence([SKAction.group([move, fadeOut]), SKAction.runBlock({Zielhilfe.removeFromParent()})]))
    }
    
    
    func touchesBegan_shoot () {
    
        pro_shootLaserSetup()
    
    }
    
    
    func touchesEnded_shoot () {
       //return
    }
    
    
    func touchesBegan_shield () {
        Game_Raumschiff_Schild.removeActionForKey("minimizeShield")
        Game_Raumschiff_Schild.runAction(
            SKAction.sequence([
                SKAction.scaleTo(1, duration: 0.7),
                SKAction.repeatActionForever(SKAction.sequence([
                    SKAction.scaleTo(0.9, duration: 1),
                    SKAction.scaleTo(1, duration: 1)
                ]))
        ]), withKey: "dynamicShield")
        
        if !Tut_Active {
            spawnNode.runAction(SKAction.repeatActionForever(SKAction.sequence([
                SKAction.runBlock({self.energyProgressBar!.addProgressInPercent(-0.7)}),
                SKAction.waitForDuration(0.1)])), withKey: "shieldActive")
        }
        
        
        if let sound = playSoundEffectGame(soundEffect_shieldSound, looped: true) {
            Game_RS_Schild_SoundNode.removeAllChildren()

            sound.runAction(SKAction.changeVolumeTo(0, duration: 0))
            sound.runAction(SKAction.changeVolumeTo(soundEffect_shieldSound.volume, duration: 0.7))
            Game_RS_Schild_SoundNode.addChild(sound)
        }
       
 
    }

    
    func touchesEnded_shield () {
        Game_Raumschiff_Schild.removeActionForKey("dynamicShield")
        Game_Raumschiff_Schild.runAction(SKAction.scaleTo(0.01, duration: 0.7), withKey: "minimizeShield")
        spawnNode.removeActionForKey("shieldActive")
        
        if let sound = playSoundEffectGame(soundEffect_shieldSound, looped: true) {
            Game_RS_Schild_SoundNode.removeAllChildren()
            sound.runAction(SKAction.sequence([
                SKAction.changeVolumeTo(0, duration: 0.7),
                SKAction.removeFromParent()]))
            Game_RS_Schild_SoundNode.addChild(sound)
        }
        
    }
    
    
    func saveStatsForGameOver () {
        //["highscore", "asteriods destroyed", "shots per hit", "lasers fired", "collected powerups"]
        
        thisStats["asteriods destroyed"]! = Float(AsteroidsHit)
        thisStats["highscore"]! = Float(Score)
        thisStats["lasers fired"]! = Float(ShotsFired)
        thisStats["collected powerups"]! = Float(collectedPowerUps)
        thisStats["enemys killed"] = Float(enemysKilled)
        
        
        if thisStats["highscore"] > bestStats["highscore"] {
            globalNewHighscore = true
            for key in thisStats.keys {
                bestStats[key] = thisStats[key]
            }
        }
        
        SaveStatistics()
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
    
    func switchToPlayIcon (instant: Bool) {
        
        var duration = Play_Pause_AnimationDuration
        
        if instant { duration = 0 }
        
        let h : CGFloat = sqrt(3) * Pause_Brick_2.size.width/2
        
        Pause_Brick_1.runAction(SKAction.group([
            SKAction.moveTo(CGPoint(x: -h/2, y: 0), duration: duration),
            SKAction.rotateToAngle(CGFloat(-M_PI/2), duration: duration)
            ]))
        Pause_Brick_2.runAction(SKAction.group([
            SKAction.moveTo(CGPoint(x: 0, y: Pause_Brick_2.size.width/4), duration: duration),
            SKAction.rotateToAngle(CGFloat((-M_PI/6)+M_PI), duration: duration)
            ]))
        Pause_Brick_3.runAction(SKAction.group([
            SKAction.moveTo(CGPoint(x: 0, y: -Pause_Brick_3.size.width/4), duration: duration),
            SKAction.rotateToAngle(CGFloat(M_PI/6), duration: duration)
            ]))
    }
    
    
    func buttonPressed_StatBar_PlayPause () {
        
        if ButtonState_ShowPause {
            switchToPlayIcon(false)
        } else {
            switchToPauseIcon()
        }
        ActivatePauseLayer(ButtonState_ShowPause)
        ButtonState_ShowPause = !ButtonState_ShowPause
        
    }
    
    
    func buttonPressed_PauseQuit () {
        loadView("GameMenu")
    }
    
    func buttonPressed_calibrateControls () {
        Game_Raumschiff.resetReference()
    }
    
    
    func exitTutorial () {
        self.Tut_Active = false
        setBoolOption("show_tutorial", value: false)
        self.TutorialNode.removeFromParent()
        spawnNode.runAction(SKAction.sequence([
            SKAction.waitForDuration(2),
            SKAction.runBlock({
                self.energyAndPowerUpActions()
            })]))
        
        
    }
    

}







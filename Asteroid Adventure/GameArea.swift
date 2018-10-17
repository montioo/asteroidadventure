//
//  GameScene.swift
//  SpielMitNinjas
//
//  Created by Marius Montebaur on 16.03.16.
//  Copyright (c) 2016 Marius Montebaur. All rights reserved.
//

/*
Zukünftige Funktionen:

Power Ups: Bonus für das Zerstören einer bestimmten Anzahl von Asteroiden
/- mehrfach-Laser
/- Langsame Asteroiden
/- Durchschlagende Projektile
/- 1UP -> Lebensanzeige durch Lichter auf dem Raumschiff

Funktionen:
/- Trefferrate am Ende: Treffer/Schüsse
/- Pause-Knopf -> self.runAction(SKAction.speedTo(0.0, duration: 2.0))

Animationen:
- Zerstörungsanimation bei Treffer

Hintergrund bewegt sich:
- Flug durchs Weltall
- Drehende Planeten

Schwierigkeit:
- Schnellere Asteroiden nach einiger Zeit

Design:
- Verschiedene Texturen für Asteroiden

Combos um Powerups zu bekommen
- Bestimmte Asteroidenanzahl in vorgegebener Zeit treffen


Während SlowMo muss Spawnrate der Asteroiden sinken!!!
Während Pause keine Asteroiden spawnen!!!

*/


/*
Höhe auf der Z-Achse:
    Text des Pause-Menüs: 4.0
    Icons und Pause Button: 3.6
    Statusbar: 3.5
    Statusbar Verlauf: 3.4
    Buttons und Text Pause-Menü: 3.1
    Pause-Menü: 3.0
    Tut Border: 2.9
    Tut Tap und Arrow: 2.9
    Eis-Layer: 1.5
    Lebensanzeige: 1.3
    Raumschiffteile: 1.2
    Laser: 1.1
    Raumschiff: 1.0
    Laser, Asteroiden, PowerUps: 0.5
    Hintergrund: 0.0


*/


import SpriteKit
import Foundation


class PwrUpIconSpriteNode: SKSpriteNode {
    var endTime : Double = 0
    var displayPosition : Int = 0
    var activeTime : Double = 0
    var active : Bool = false
    var posInHUD : Int = 0
    var justEnded : Bool = false
    let TimeDisplay = SKLabelNode(fontNamed: "Arial Bold")
    
    func updateTimeDisplay (aktuelleZeit: Double) {
        if active == true && endTime != 0 {
            let displayedTime = round((endTime - aktuelleZeit)*10)/10
            
            if displayedTime < 0 {
                self.setInactive()
                
            } else {
                TimeDisplay.text = String(abs(displayedTime))
            }
            
        }
    }
    
    func setNewEndTime (aktuelleZeit: Double) {
        endTime = aktuelleZeit + activeTime
        active = true
    }
    
    func setInactive () {
        active = false
        justEnded = true
        TimeDisplay.text = ""
    }

}

class Tut_TouchField: SKSpriteNode {
    var touchCound : Int = 0
    let Titel = SKLabelNode(fontNamed: "ArialMT")
}


class GameArea: SKScene, SKPhysicsContactDelegate {
    
    
    struct PhysicsCategory {
        static let None             : UInt32 = 0
        static let All              : UInt32 = UInt32.max
        
        static let PhyNormLaser     : UInt32 = 0b0001 //1
        static let PhyPowerLaser    : UInt32 = 0b0010 //2
        
        static let PhyRaumschiff        : UInt32 = 0b0011 //3
        
        static let PhyStdAst        : UInt32 = 0b0100 //4
        static let PhyBigAst        : UInt32 = 0b0101 //5
        static let PhyMegAst        : UInt32 = 0b0110 //6
        
        static let PhyPowerUpMultiLaser : UInt32 = 0b1000 //8
        static let PhyPowerUpPowerLaser : UInt32 = 0b1001 //9
        static let PhyPowerUpSlowMo     : UInt32 = 0b1010 //10
        static let PhyPowerUp1UP        : UInt32 = 0b1011 //11
    
    }
    
    
    var Tut_Active : Bool = true
    
    let MaxLeben = 3
    var Leben = 3
    var GamePaused = false
    var GameOver = false
    
    var GameViewHeigth : CGFloat = 0
    
    
    var RSMovement_X_Active : Bool = false
    var RSMovement_Y_Active : Bool = false
    var RSCenterPoint : CGPoint = CGPoint(x: 0, y: 0)
    var RSCage_X : CGFloat = 0
    var RSCage_Y : CGFloat = 0
    
    var AimFingerValue : CGFloat = 0
    var AimLaserAngle : CGFloat = 0
    var AimReferencePoint : CGPoint = CGPoint(x: 0, y: 0)
    var AimVorzeichen : CGFloat = -1
    var FingerMoveSpace : CGFloat = 0
    
    var PwrUp_Mlt_Lasermenge = 1
   
    let PwrUp_Slw_SceneSpeed : CGFloat = 0.3
    let PwrUp_Slw_FadeTime : Double = 1
    
    var PwrUp_IconArray = [PwrUpIconSpriteNode(), PwrUpIconSpriteNode(), PwrUpIconSpriteNode()]
    
    var PwrUp_HUD_IconStorePoint = CGPoint(x: 0.0, y: 0.0)
    var PwrUp_HUD_IconDistance : CGFloat = 0
    
    var Ast_last_k : Int = 0
    let Ast_wave_amplitude : Float = 0.035 //a
    let Ast_wave_period_length : Float = 0.7 //b
    
    var Ast_Time : Double = 0
    let Ast_Time_gP : Double = 120
    let Ast_Time_max : Double = 5
    let Ast_Time_min : Double = 2.4
    var Ast_Time_m : Double = 0
    let BigAst_Slower : Double = 1.5
    
    var BG_Speed : Float = 0
    var BG_Speed_m : Float = 0
    let BG_Speed_max : Float = 3
    
    var AsteroidsHit : Int = 0
    var ShotsFired : Int = 0
    
    var System_Uptime : Double = 0
    var Ingame_Time : Double = 0
    var Game_Runtime : Double = 0
    
    let blurNode = SKEffectNode()
    
    let worldNode = SKSpriteNode()
    
    let TutorialNode = SKSpriteNode()
    let ObjektMotherNode = SKSpriteNode()
    let LaserMotherNode = SKSpriteNode()
    let PictureMotherNode = SKSpriteNode()
    let HUD_Node = SKSpriteNode()
    let PwrUp_Node = SKSpriteNode()
    
    let Game_Slow_Layer = SKSpriteNode(imageNamed: "Game_SlowMoRahmen_v1")
    
    let Game_Pause_Layer = SKSpriteNode(imageNamed: "Game_Pause_Layer_v1")
    let Pause_Verlauf = SKSpriteNode(imageNamed: "Pause_Verlauf")
    let Pause_Play_Button = SKSpriteNode(imageNamed: "Pause_Play_Button_v2")
    let Pause_Quit_Button = SKSpriteNode(imageNamed: "Pause_Quit_Button_v2")
    let Pause_Titel = SKLabelNode(fontNamed: "Arial-BoldMT")
    let Pause_Hits = SKLabelNode(fontNamed: "ArialMT")
    
    
    let Game_Raumschiff = SKSpriteNode(imageNamed: "Game_Raumschiff_v1")
    let Game_Raumschiff_Triebwerk = SKSpriteNode(imageNamed: "Game_Raumschiff_Triebwerk_v1")
    let Game_Raumschiff_Laserkanone = SKSpriteNode(imageNamed: "Game_Raumschiff_Laserkanone_v1")
    
    let Game_Statusbar = SKSpriteNode(imageNamed: "Game_Statusbar_v1")
    let Game_Pause_Button = SKSpriteNode(imageNamed: "Game_PauseButton_v2")
    let PwrUp_Mlt_Icon = PwrUpIconSpriteNode(imageNamed: "Game_PwrUpIcon-M_v2")
    let PwrUp_Pwr_Icon = PwrUpIconSpriteNode(imageNamed: "Game_PwrUpIcon-P_v2")
    let PwrUp_Slw_Icon = PwrUpIconSpriteNode(imageNamed: "Game_PwrUpIcon-S_v2")

    let Game_Lebensanzeige = SKLabelNode(fontNamed: "ArialMT")
    
    let Label_GameUserTime = SKLabelNode(fontNamed: "ArialMT")
    
    let bg1 = SKSpriteNode(imageNamed: "Universe_1")
    let bg2 = SKSpriteNode(imageNamed: "Universe_2")
    
    let bg_array = [SKTexture(imageNamed: "Universe_1"),
                    SKTexture(imageNamed: "Universe_2"),
                    SKTexture(imageNamed: "Universe_3"),
                    SKTexture(imageNamed: "Universe_5"),
                    SKTexture(imageNamed: "Universe_6"),
                    SKTexture(imageNamed: "Universe_6")]
    
    
    let LeftFieldBorder = Tut_TouchField(imageNamed: "Tutorial_Touchborder")
    let RightFieldBorder = Tut_TouchField(imageNamed: "Tutorial_Touchborder")
    let Arrows = SKSpriteNode(imageNamed: "Tutorial_Arrows")
    let TutorialSign = SKSpriteNode(imageNamed: "Game_Pause_Layer_v1")

    
    
    
     override func didMoveToView(view: SKView) {
        
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(GameArea.appMovedToBackground), name: UIApplicationWillResignActiveNotification, object: nil)

        addChild(worldNode)
        addChild(HUD_Node)
        
        worldNode.addChild(PictureMotherNode)
        worldNode.addChild(LaserMotherNode)
        worldNode.addChild(ObjektMotherNode)
        worldNode.addChild(PwrUp_Node)
      
//Statusbar Initialisierung:
        //Game_Statusbar.setScale(CGFloat(MainScreenScale))
        Game_Statusbar.anchorPoint = CGPointMake(0.5, 1.0)
        Game_Statusbar.position = CGPoint(x: size.width/2, y: size.height)
        Game_Statusbar.zPosition = 3.5
        HUD_Node.addChild(Game_Statusbar)
        
        
        Pause_Verlauf.anchorPoint = CGPointMake(0.5, 1)
        //Pause_Verlauf.setScale(CGFloat(MainScreenScale))
        Pause_Verlauf.size.height = Pause_Verlauf.size.height/4
        Pause_Verlauf.zPosition = 1
        Pause_Verlauf.position = CGPoint(x: 0, y: -Game_Statusbar.size.height)
        Game_Statusbar.addChild(Pause_Verlauf)
            
        //Game_Pause_Button.setScale(CGFloat(MainScreenScale))
        
        let Icon_Borderspace = (Game_Statusbar.size.height-Game_Pause_Button.size.height)/2
        
        PwrUp_HUD_IconStorePoint = CGPoint(x: -((Game_Pause_Button.size.width/2)+Icon_Borderspace), y: size.height-((Game_Pause_Button.size.height/2)+Icon_Borderspace))
        PwrUp_HUD_IconDistance = Game_Pause_Button.size.width+Icon_Borderspace
        
        Game_Pause_Button.position = CGPoint(x: size.width - Game_Pause_Button.size.width/2 - Icon_Borderspace, y: PwrUp_HUD_IconStorePoint.y)
        Game_Pause_Button.zPosition = 3.6
        Game_Pause_Button.color = UIColor.blackColor()
        HUD_Node.addChild(Game_Pause_Button)
    
        PwrUp_Mlt_Icon.activeTime = 6
        PwrUp_Pwr_Icon.activeTime = 6
        PwrUp_Slw_Icon.activeTime = 5
        
        initialisierePowerUpNodes(PwrUp_Mlt_Icon, i: 0)
        initialisierePowerUpNodes(PwrUp_Pwr_Icon, i: 1)
        initialisierePowerUpNodes(PwrUp_Slw_Icon, i: 2)
        
        
//Hintergrund initialisierung
        GameViewHeigth = size.height-Game_Statusbar.size.height
        FingerMoveSpace = (GameViewHeigth/4) * Option_FingerMoveSpace
        
        bg1.anchorPoint = CGPointZero
        bg1.position = CGPoint(x: 0,y: 0)
        ObjektMotherNode.addChild(bg1)
        
        bg2.anchorPoint = CGPointZero
        bg2.position = CGPoint(x: bg1.size.width,y: 0)
        ObjektMotherNode.addChild(bg2)
        
        bg1.runAction(SKAction.repeatActionForever(SKAction.moveBy(CGVector(dx: -size.width, dy: 0), duration: 30)))
        bg2.runAction(SKAction.repeatActionForever(SKAction.moveBy(CGVector(dx: -size.width, dy: 0), duration: 30)))
        
        
        
        Game_Slow_Layer.position = CGPoint(x: size.width/2, y: size.height/2)
        Game_Slow_Layer.alpha = 0.0
        Game_Slow_Layer.zPosition = 1.7
        PictureMotherNode.addChild(Game_Slow_Layer)
        
        backgroundColor = SKColor.blackColor()
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        
//Pause Layer initialisierung
        //Game_Pause_Layer.setScale(CGFloat(MainScreenScale))
        Game_Pause_Layer.position = CGPoint(x: size.width/2, y: size.height - Game_Statusbar.size.height + Game_Pause_Layer.size.height/2)
        Game_Pause_Layer.zPosition = 3.0
        HUD_Node.addChild(Game_Pause_Layer)
        
        //Pause_Play_Button.setScale(CGFloat(MainScreenScale))
        //Pause_Quit_Button.setScale(CGFloat(MainScreenScale))
        
        let Abstand_Buttons = (Game_Pause_Layer.size.width-(2*Pause_Play_Button.size.width))/3
        
        Pause_Play_Button.position = CGPoint(x: -Pause_Play_Button.size.width/2 - Abstand_Buttons/2, y: -Game_Pause_Layer.size.height/2 + Pause_Play_Button.size.height/2 + Abstand_Buttons/2)
        Pause_Quit_Button.position = CGPoint(x: -Pause_Play_Button.position.x, y: Pause_Play_Button.position.y)
        //Pause_Quit_Button.position = CGPoint(x: 0, y: 0)
        
        Pause_Quit_Button.color = UIColor.blackColor()
        Pause_Play_Button.color = UIColor.blackColor()
        
        Game_Pause_Layer.addChild(Pause_Play_Button)
        Game_Pause_Layer.addChild(Pause_Quit_Button)
        
        Pause_Play_Button.zPosition = 0.1
        Pause_Quit_Button.zPosition = 0.1
        
        Pause_Titel.text = "Pause"
        Pause_Titel.fontSize = 35
        Pause_Titel.horizontalAlignmentMode = .Center
        Pause_Titel.verticalAlignmentMode = .Center
        Pause_Titel.zPosition = 0.1
        //Pause_Titel.setScale(CGFloat(MainScreenScale))
        Pause_Titel.position = CGPoint(x: 0, y: Game_Pause_Layer.size.height/2 - Abstand_Buttons*1)
        Game_Pause_Layer.addChild(Pause_Titel)
        
        
        Pause_Hits.text = ""
        Pause_Hits.fontSize = 18
        Pause_Hits.horizontalAlignmentMode = .Center
        Pause_Hits.verticalAlignmentMode = .Center
        Pause_Hits.zPosition = 0.1
        //Pause_Hits.setScale(CGFloat(MainScreenScale))
        Pause_Hits.position = CGPoint(x: 0, y: 0)
        Game_Pause_Layer.addChild(Pause_Hits)
        
// Raumschiff initialisierung
        Game_Raumschiff.zPosition = 1.0
        //Game_Raumschiff.setScale(CGFloat(MainScreenScale))
        Game_Raumschiff.position = CGPoint(x: 60, y: GameViewHeigth/2)
        RSCenterPoint = Game_Raumschiff.position
        PictureMotherNode.addChild(Game_Raumschiff)
        RSCage_X = (Game_Raumschiff.position.x - Game_Raumschiff.size.width/2)*(5/6)
        RSCage_Y = RSCage_X * 1.5
        
        Game_Raumschiff_Triebwerk.zPosition = 0.1
        Game_Raumschiff_Triebwerk.anchorPoint = CGPointMake(0, 0.5)
        //Game_Raumschiff_Triebwerk.setScale(CGFloat(MainScreenScale))
        Game_Raumschiff_Triebwerk.position = CGPoint(x: Game_Raumschiff.size.width*0.056 - Game_Raumschiff.size.width/2, y: -Game_Raumschiff.size.height/2)
        Game_Raumschiff.addChild(Game_Raumschiff_Triebwerk)
        
        Game_Raumschiff_Laserkanone.zPosition = 0.1
        Game_Raumschiff_Laserkanone.anchorPoint = CGPointMake(0.4, 0.5)
        //Game_Raumschiff_Laserkanone.setScale(CGFloat(MainScreenScale))
        Game_Raumschiff_Laserkanone.position = CGPoint(x: 0, y: 0)
        Game_Raumschiff.addChild(Game_Raumschiff_Laserkanone)
        
        Game_Raumschiff_Laserkanone.runAction(SKAction.repeatActionForever(SKAction.sequence([
            SKAction.runBlock({self.spawnZielhilfe()}),
            SKAction.waitForDuration(0.4)
        ])))
        
        
        Game_Lebensanzeige.text = String(Leben)
        Game_Lebensanzeige.fontSize = 20
        Game_Lebensanzeige.horizontalAlignmentMode = .Center
        Game_Lebensanzeige.verticalAlignmentMode = .Center
        Game_Lebensanzeige.zPosition = 0.1
        //Game_Lebensanzeige.setScale(CGFloat(MainScreenScale))
        Game_Lebensanzeige.position = CGPoint(x: -Game_Raumschiff.size.width*0.25, y: -Game_Raumschiff.size.height*0.1) //Ausgehend von der Mitte der Mothernode
        Game_Raumschiff.addChild(Game_Lebensanzeige)
        
        
        Game_Raumschiff.physicsBody = SKPhysicsBody(rectangleOfSize: Game_Raumschiff.size)
        Game_Raumschiff.physicsBody?.categoryBitMask = PhysicsCategory.PhyRaumschiff
        Game_Raumschiff.physicsBody?.contactTestBitMask = PhysicsCategory.PhyStdAst | PhysicsCategory.PhyBigAst
        Game_Raumschiff.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        
        addChild(blurNode)
        
        if Testing_ShowIngameTime == true {
            Label_GameUserTime.fontColor = UIColor.blackColor()
            Label_GameUserTime.fontSize = 10
            Label_GameUserTime.position = CGPoint(x: 0, y: -Game_Statusbar.size.height/2)
            Label_GameUserTime.zPosition = 6
            Game_Statusbar.addChild(Label_GameUserTime)
        }
    
        
        Ast_Time_m = (Ast_Time_max-Ast_Time_min)/(-Ast_Time_gP)
        BG_Speed_m = (BG_Speed_max-1)/Float(Ast_Time_gP)
        
        //runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(spawnBigAst), SKAction.waitForDuration(3)])))
        
        //Steurungssetup:
        if Option_InvertControls == false {AimVorzeichen = 1}
        
        
        runTutorial()
        
    }
    
    
    override func update(currentTime: NSTimeInterval) {
        
        if System_Uptime != 0 && GamePaused == false && GameOver == false && Tut_Active == false {
            
            if PwrUp_Slw_Icon.active == true {
                Ingame_Time = Ingame_Time + (currentTime - System_Uptime)*Double(PwrUp_Slw_SceneSpeed)
            } else {
                Ingame_Time = Ingame_Time + (currentTime - System_Uptime)
            }
            Game_Runtime = Game_Runtime + (currentTime - System_Uptime)
            
        }
        System_Uptime = currentTime
        
        
        for i in 0...PwrUp_IconArray.count-1 {
            PwrUp_IconArray[i].updateTimeDisplay(Game_Runtime)
            
            if PwrUp_IconArray[i].justEnded == true && PwrUp_IconArray[i].active == false {
                
                PwrUp_remove(PwrUp_IconArray[i])
                
            }
        }
       
        if PwrUp_Mlt_Icon.justEnded == true && PwrUp_Mlt_Icon.active == false {
            PwrUp_Mlt_Lasermenge = 1
            PwrUp_Mlt_Icon.justEnded = false
        }
        
        if PwrUp_Pwr_Icon.justEnded == true && PwrUp_Pwr_Icon.active == false {
            PwrUp_Pwr_Icon.justEnded = false
        }
        
        if PwrUp_Slw_Icon.justEnded == true && PwrUp_Slw_Icon.active == false {
            ObjektMotherNode.runAction(SKAction.speedTo(1.0, duration: PwrUp_Slw_FadeTime))
            Game_Slow_Layer.runAction(SKAction.fadeOutWithDuration(PwrUp_Slw_FadeTime))
            bg1.runAction(SKAction.speedTo(CGFloat(BG_Speed), duration: PwrUp_Slw_FadeTime))
            bg2.runAction(SKAction.speedTo(CGFloat(BG_Speed), duration: PwrUp_Slw_FadeTime))
            PwrUp_Slw_Icon.justEnded = false
        }
        
        AsteroidWave()
        
        if Testing_ShowIngameTime == true {
            Label_GameUserTime.text = String(floor(Ingame_Time*10)/10)
        }
        
        
        OrganizeBackground()
        
        FlyRaumschiff()
        
        
    }
    
    
    
    
    
    func spawnPowerUp() {

        let Game_PowerUp = SKSpriteNode(imageNamed: "Game_PowerUp_UP_v1")
        Game_PowerUp.physicsBody = SKPhysicsBody(rectangleOfSize: Game_PowerUp.size)
        Game_PowerUp.zPosition = 0.5
        
        var lowerBorder = 0
        var upperBorder = 2
        if Leben >= MaxLeben {
            lowerBorder = 1     //Im Moment keine 1UpPwrUps spawnen
        }
        if Game_Runtime > 75 {
            upperBorder = 3     //Jetzt dürfen SlowPwrUps spawnen
        }
        
        let RandomPowerUp = randomInt(min: lowerBorder, max: upperBorder)
        
        if RandomPowerUp == 0 {
            
            Game_PowerUp.physicsBody?.categoryBitMask = PhysicsCategory.PhyPowerUp1UP
            
        } else if RandomPowerUp == 1 {
            
            Game_PowerUp.texture = SKTexture(imageNamed: "Game_PowerUp_ML_v1")
            Game_PowerUp.physicsBody?.categoryBitMask = PhysicsCategory.PhyPowerUpMultiLaser
            
        } else if RandomPowerUp == 2 {
            
            Game_PowerUp.texture = SKTexture(imageNamed: "Game_PowerUp_PL_v1")
            Game_PowerUp.physicsBody?.categoryBitMask = PhysicsCategory.PhyPowerUpPowerLaser
            
        } else {
            
            Game_PowerUp.texture = SKTexture(imageNamed: "Game_PowerUp_SL_v1")
            Game_PowerUp.physicsBody?.categoryBitMask = PhysicsCategory.PhyPowerUpSlowMo
            
        }
        
        Game_PowerUp.physicsBody?.contactTestBitMask = PhysicsCategory.PhyNormLaser | PhysicsCategory.PhyPowerLaser
        Game_PowerUp.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        PwrUp_Node.addChild(Game_PowerUp)
        
        let Game_PowerUp_Rahmen = SKSpriteNode(imageNamed: "Game_PowerUp_Rahmen_v1")
        
        Game_PowerUp_Rahmen.position = CGPoint(x: 0, y: 0)
        Game_PowerUp.addChild(Game_PowerUp_Rahmen)
      
        /*
        Startposition: Im letzten 5tel des Bildschirms. Oben oder unten ebenfalls zufällig
        Endposition: Im mittleren 5tel des Bildschirms.
        */
        
        
        let possible_y_start = [-Game_PowerUp_Rahmen.size.height/2, GameViewHeigth+Game_PowerUp_Rahmen.size.height/2]
        
        let arrayPos = randomInt(min: 0, max: 1)
        
        let y_start = possible_y_start[arrayPos]
        let y_end = possible_y_start[abs(arrayPos-1)]
        
        let x_start = (size.width*0.8) + random(min: 0, max: size.width*0.2)
        let x_end = (size.width*0.4) + random(min: 0, max: size.width*0.2)

        Game_PowerUp.runAction(SKAction.moveTo(CGPoint(x: x_start, y: y_start), duration: 0))
        
        let PwrUpMovement = SKAction.moveTo(CGPoint(x: x_end, y: y_end), duration: Ast_Time*0.75)
        
        let PwrUpMoveAlong = SKAction.sequence([PwrUpMovement, SKAction.runBlock({Game_PowerUp_Rahmen.removeFromParent(); Game_PowerUp.removeFromParent()})])
        
        let PowerUpRahmenRotation = SKAction.rotateByAngle(CGFloat(-M_PI/Double(2)), duration: 1.0)
        
        Game_PowerUp.runAction(PwrUpMoveAlong)
        Game_PowerUp_Rahmen.runAction(SKAction.repeatActionForever(PowerUpRahmenRotation))
    
    }

    
    
    func shootLaserSetup() {
    
        // a = atan( G / A )
        
        var Laser_Menge : CGFloat = CGFloat(PwrUp_Mlt_Lasermenge)
        
        let LaserStreuwinkel = 6 * CGFloat(M_PI / 180) //Umwandlung von Deg in Rad
        
        Laser_Menge = Laser_Menge - 1
        var Oeffnungswinkel = ((Laser_Menge)/2) * LaserStreuwinkel
        
        
        while Laser_Menge > 0 {
            shootLaserByAngle(Oeffnungswinkel)
            shootLaserByAngle(-Oeffnungswinkel)
            Oeffnungswinkel = Oeffnungswinkel - LaserStreuwinkel
            Laser_Menge = Laser_Menge - 2
        }
        shootLaserByAngle(0)
        
    }
    
    
    func shootLaserByAngle(Schusswinkel_Offset: CGFloat) {
        
        // sin a * H = G
        // cos a * H = A
        // H = 1
        
        let Schusswinkel = Game_Raumschiff.zRotation + Game_Raumschiff_Laserkanone.zRotation + Schusswinkel_Offset
        
        let Laser_Vektor = CGVector(dx: cos(Schusswinkel)*1000, dy: sin(Schusswinkel)*1000)
        
        //if Laser_Vektor.dx >= 0 {
            
            let Game_Laser = SKSpriteNode(imageNamed: "Game_LaserRot_v2")
            Game_Laser.zPosition = 1.05
            Game_Laser.anchorPoint = CGPointMake(0, 0.5)
            //Game_Laser.setScale(CGFloat(MainScreenScale))
            
            let pos = CGPoint(x: Game_Raumschiff.position.x + Game_Raumschiff_Laserkanone.position.x, y: Game_Raumschiff.position.y + Game_Raumschiff_Laserkanone.position.y)
            
            Game_Laser.position = pos
            
            if PwrUp_Pwr_Icon.active == true {
                Game_Laser.texture = SKTexture(imageNamed: "Game_LaserBlau_v2")
            }
            
            Game_Laser.physicsBody = SKPhysicsBody(rectangleOfSize: Game_Laser.size)
            Game_Laser.physicsBody?.dynamic = true
            
            if PwrUp_Pwr_Icon.active == true {
                Game_Laser.physicsBody?.categoryBitMask = PhysicsCategory.PhyPowerLaser
            } else {
                Game_Laser.physicsBody?.categoryBitMask = PhysicsCategory.PhyNormLaser
            }
            
            Game_Laser.physicsBody?.collisionBitMask = PhysicsCategory.None
            Game_Laser.physicsBody?.usesPreciseCollisionDetection = true
            
            LaserMotherNode.addChild(Game_Laser)
            
            Game_Laser.runAction(SKAction.rotateByAngle(Schusswinkel, duration: 0.0))
            
            if Tut_Active == false {
                ShotsFired += 1
            }
            
            Game_Laser.runAction(SKAction.sequence([SKAction.moveBy(Laser_Vektor, duration: 2.0), SKAction.runBlock(removeFromParent)]))
        //}
    }
    
    
 

    
    func AsteroidWave () {
        
        let inverseValue : Double = Double(1/Ast_wave_period_length)
        
        let Intervall = Double(Ast_last_k + 1)*(M_PI/4)*inverseValue
        
        if Ingame_Time > Intervall {
            
            Ast_last_k += 1
            
            var Ast_to_spawn : Int = Int(abs(Double(Ast_wave_amplitude) * Ingame_Time * sin(Double(Ast_wave_period_length) * Ingame_Time)))+1
            //printKonsole(String("Asteroiden", Ast_to_spawn, "  k:", (Ast_last_k-1)))
            var SpawnIntervall : Double = 0
            
            if (Ast_last_k % 4) == 0 {
                Ast_last_k+=1
                let Abzug = Double(random(min: 0, max: (CGFloat(M_PI/8))))
                SpawnIntervall = ((M_PI/2)-Abzug) * inverseValue
            } else {
                let Abzug = Double(random(min: 0, max: (CGFloat(M_PI/16))))
                SpawnIntervall = ((M_PI/4)-Abzug) * inverseValue
            }
            
            //Geschwindigkeit berechnen
            
            if Ingame_Time < Double(Ast_Time_gP) {
                Ast_Time = Ast_Time_m*(Ingame_Time-Ast_Time_gP)+Ast_Time_min
            } else {
                Ast_Time = Ast_Time_min
            }
            
            
            let possible_BigAst : Int = Ast_to_spawn/3
            
            if possible_BigAst > 0 {
                //possible_BigAst -= 1
                let BigAst_to_spawn = randomInt(min: 0, max: possible_BigAst)
                
                if BigAst_to_spawn > 0 {
                    for _ in 0..<BigAst_to_spawn {
                        Ast_to_spawn -= randomInt(min: 1, max: 3)
                    }
                
                    ObjektMotherNode.runAction(SKAction.repeatAction(SKAction.sequence([
                        SKAction.runBlock({self.spawnBigAst()}),
                        SKAction.waitForDuration(SpawnIntervall/Double(BigAst_to_spawn))]), count: Int(BigAst_to_spawn)))
                }
                print(" ")
            }
            
            
            /*
             !!! An dieser Stelle evtl großen Asteroiden spawnen
             Ast_to_spawn um rand(2, 4) verringern
             
             Nicht immer große Asteroiden spawnen
             Zufällig, wie viele große Asteroiden spawnen könne.
            
             Im Spawnintervall eine Menge x von großen Asteroiden spawnen
                Da kann der folgende Code einfach leicht abgewandelt werden.
             
             Überlegungen: 
                Wie viele StdAst ein BigAst optimalerweise spawnt muss getestet werden.
                Auch die Häufigkeit von BigAst muss getestet und ggf. angepasst werden.
             
             
             Praxis:
                Theoretisch mögliche Menge großer Asteroiden berechnen
                Davon eig schon mal einen abziehen um die Wahrscheinlichkeit zu verringern
                Oder: Bei der Berechnung der theoretischen Menge von 4 StdAst pro BigAst ausgehen
             
                Dann zufällig entscheiden, wie viele BigAst gespawnt werden sollen.
                Im Rumpf einer for-Schleife auf eine Variable einen Zufalls-Int von 1 bis 3 (oder so)
                    addieren und zwar so oft, wie neue BigAst gespawnt werden sollen.
                Diese berechnete Zahl von Ast_to_spawen abziehen und wie gewohnt fortfahren
             
            */
            
            ObjektMotherNode.runAction(SKAction.repeatAction(SKAction.sequence([
                SKAction.runBlock({self.spawnStdAst(CGPoint(x: 0, y:0), useGivenStart: false)}),
                SKAction.waitForDuration(SpawnIntervall/Double(Ast_to_spawn))]), count: Int(Ast_to_spawn)))
            
        }
        
    }
    
    
    func spawnStdAst (givenStart: CGPoint, useGivenStart: Bool) {
        
        let Game_StdAst = SKSpriteNode(imageNamed: "Game_Asteroid_v1")
        Game_StdAst.zPosition = 0.5
        
        Game_StdAst.physicsBody = SKPhysicsBody(rectangleOfSize: Game_StdAst.size)
        Game_StdAst.physicsBody?.categoryBitMask = PhysicsCategory.PhyStdAst
        Game_StdAst.physicsBody?.contactTestBitMask = PhysicsCategory.PhyNormLaser | PhysicsCategory.PhyPowerLaser

        Game_StdAst.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let ScaleRandomize = random(min: 0.8, max: 1.2)
        
        Game_StdAst.setScale(CGFloat(MainScreenScale)*ScaleRandomize)
        
        let StdAstStart = CGPoint(x: size.width + Game_StdAst.size.width*1/2, y: random(min: 0 + Game_StdAst.size.height/2, max: GameViewHeigth - Game_StdAst.size.height/2))
        
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
        var StdAstZiel = CGPoint(x: -Game_StdAst.size.width*1/2, y: random(min: Game_StdAst.position.y-(GameViewHeigth*(1/3)*PercPosInViewX), max: Game_StdAst.position.y+(GameViewHeigth*(1/3)*PercPosInViewX)))
        
        if StdAstZiel.y > GameViewHeigth-Game_StdAst.size.height/2 {
            StdAstZiel.y = GameViewHeigth-Game_StdAst.size.height/2
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
            SKAction.runBlock({self.aktualisiereLeben(-1); Game_StdAst.removeFromParent()}),
            ]))
        
    }
    
    func spawnBigAst () {
        
        let Game_BigAst = SKSpriteNode(imageNamed: "Game_Asteroid_v1")
        Game_BigAst.zPosition = 0.5
        
        Game_BigAst.physicsBody = SKPhysicsBody(rectangleOfSize: Game_BigAst.size)
        Game_BigAst.physicsBody?.categoryBitMask = PhysicsCategory.PhyBigAst
        Game_BigAst.physicsBody?.contactTestBitMask = PhysicsCategory.PhyNormLaser | PhysicsCategory.PhyPowerLaser
        
        Game_BigAst.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let ScaleRandomize = random(min: 0.8, max: 1.2)
        
        Game_BigAst.setScale(ScaleRandomize*2.2)
        
        let BigAstStart = CGPoint(x: size.width + Game_BigAst.size.width*1/2, y: random(min: 0 + Game_BigAst.size.height/2, max: GameViewHeigth - Game_BigAst.size.height/2))
        
        Game_BigAst.position = BigAstStart
        
        ObjektMotherNode.addChild(Game_BigAst)
        
        var BigAstZiel = CGPoint(x: -Game_BigAst.size.width*1/2, y: random(min: Game_BigAst.position.y-(GameViewHeigth*(1/6)), max: Game_BigAst.position.y+(GameViewHeigth*(1/6))))
        
        if BigAstZiel.y > GameViewHeigth-Game_BigAst.size.height/2 {
            BigAstZiel.y = GameViewHeigth-Game_BigAst.size.height/2
        }
        
        if BigAstZiel.y < Game_BigAst.size.height/2 {
            BigAstZiel.y = Game_BigAst.size.height/2
        }
        
        let BigAstRotation = SKAction.repeatActionForever(SKAction.rotateByAngle(randomPosOrNeg() * CGFloat(M_PI/Double(2)), duration: Double(random(min: 1.5, max: 3.0))))
        
        let Bewegungsdauer : Double = Ast_Time*Double(random(min: 1, max: 1.3))*BigAst_Slower
        
        Game_BigAst.runAction(BigAstRotation)
        Game_BigAst.runAction(SKAction.sequence([
            SKAction.moveTo(BigAstZiel, duration: Bewegungsdauer),
            SKAction.runBlock({self.aktualisiereLeben(-1); Game_BigAst.removeFromParent()}),
            ]))
        
    }
    
    
    func aktualisiereLeben (x: Int) {
        Leben = Leben + x
        aktualisiereLebensanzeige()
        
        
        if Leben < 0 && Testing_GameOverAllowed {
            ActivatePauseLayer(true, Modus: "Game Over")
        }
        
    }
    
    func aktualisiereLebensanzeige () {
        Game_Lebensanzeige.text = String(Leben)
        
        if Leben < 2 {
            Game_Lebensanzeige.fontColor = UIColor.redColor()
        } else {
            Game_Lebensanzeige.fontColor = UIColor.whiteColor()
        }
        
    }
    
    
    
    func laserHitsBigAst (asteroid: SKSpriteNode) {
    
        let neueStdAstMenge = randomInt(min: 1, max: 3)
    
        let neueStdAstPos = asteroid.position
        
        let BigAstWidthHalf = asteroid.size.width/2
        
        asteroid.removeFromParent()
        AsteroidsHit += 1
        
        for _ in 1...neueStdAstMenge {
            let ChildAstPos = CGPoint(x: neueStdAstPos.x+random(min: -BigAstWidthHalf, max: BigAstWidthHalf), y: neueStdAstPos.y+random(min: -BigAstWidthHalf, max: BigAstWidthHalf))
            spawnStdAst(ChildAstPos, useGivenStart: true)
        }
        
    }
    

    func laserHitsStdAst (asteroid: SKSpriteNode) {
        
        AsteroidsHit += 1
        
        asteroid.removeFromParent()
        
        if Int(AsteroidsHit)%6 == 0 {
            spawnPowerUp()
        }
        
    }
    
    
    func laserHitsPowerUp1UP (powerUp: SKSpriteNode) {
        
        powerUp.removeFromParent()
        
        aktualisiereLeben(1)
        
        if Leben > 3 {
            Leben = 3
        }
    
    }
    
    func laserHits_PwrUp_Mlt (powerUp: SKSpriteNode) {
        
        powerUp.removeFromParent()
        
        if PwrUp_Mlt_Lasermenge < 4 {
            PwrUp_Mlt_Lasermenge += 2
        }
        
        PwrUp_Mlt_Icon.setNewEndTime(Game_Runtime)
        PwrUp_add(PwrUp_Mlt_Icon)
        
    }
    
    func laserHits_PwrUp_Pwr (powerUp: SKSpriteNode) {
        
        powerUp.removeFromParent()
        
        PwrUp_Pwr_Icon.setNewEndTime(Game_Runtime)
        PwrUp_add(PwrUp_Pwr_Icon)
    }
    
    func laserHits_PwrUp_Slw (powerUp: SKSpriteNode) {
        
        powerUp.removeFromParent()
        
        Game_Slow_Layer.runAction(SKAction.fadeInWithDuration(PwrUp_Slw_FadeTime))
        
        PwrUp_Slw_Icon.setNewEndTime(Game_Runtime)
        PwrUp_add(PwrUp_Slw_Icon)
        
        ObjektMotherNode.runAction(SKAction.speedTo(PwrUp_Slw_SceneSpeed, duration: PwrUp_Slw_FadeTime))
        bg1.runAction(SKAction.speedTo(PwrUp_Slw_SceneSpeed*CGFloat(BG_Speed), duration: PwrUp_Slw_FadeTime))
        bg2.runAction(SKAction.speedTo(PwrUp_Slw_SceneSpeed*CGFloat(BG_Speed), duration: PwrUp_Slw_FadeTime))
        
    }
    
    
    func laserHitsSomething (laser: SKSpriteNode, lasertyp: Int) {
        
        if lasertyp == Int(PhysicsCategory.PhyNormLaser) {
            laser.removeFromParent()
        }
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody_Objekt : SKPhysicsBody
        var secondBody_Laser : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
            firstBody_Objekt = contact.bodyA
            secondBody_Laser = contact.bodyB
        } else {
            firstBody_Objekt = contact.bodyB
            secondBody_Laser = contact.bodyA
        }
        
        
        if ((secondBody_Laser.categoryBitMask == PhysicsCategory.PhyNormLaser || secondBody_Laser.categoryBitMask == PhysicsCategory.PhyPowerLaser)) {
            
            if (firstBody_Objekt.node != nil && secondBody_Laser.node != nil) {
            
                let lasertyp = Int(secondBody_Laser.categoryBitMask)
                showExplosion(lasertyp, pos: (firstBody_Objekt.node as! SKSpriteNode).position)
                laserHitsSomething(secondBody_Laser.node as! SKSpriteNode, lasertyp: lasertyp)
                
                //Laser trifft normalen Asteroiden
                if (firstBody_Objekt.categoryBitMask == PhysicsCategory.PhyStdAst) {
                    
                    laserHitsStdAst(firstBody_Objekt.node as! SKSpriteNode)
                } else
                
                //Laser trifft großen Asteroiden und Laser wird entfernt, egal ob normal oder power
                if (firstBody_Objekt.categoryBitMask == PhysicsCategory.PhyBigAst) {
                    
                    laserHitsBigAst(firstBody_Objekt.node as! SKSpriteNode)
                    
                    if secondBody_Laser.categoryBitMask == PhysicsCategory.PhyPowerLaser {
                        let laserNode = secondBody_Laser.node as! SKSpriteNode
                        laserNode.removeFromParent()
                    }
                    
                } else
                
                
                //Laser trifft Power Up 1UP
                if (firstBody_Objekt.categoryBitMask == PhysicsCategory.PhyPowerUp1UP) {
                    
                    laserHitsPowerUp1UP(firstBody_Objekt.node as! SKSpriteNode)
                    
                } else
                
                
                //Laser trifft Power Up Multi Laser
                if (firstBody_Objekt.categoryBitMask == PhysicsCategory.PhyPowerUpMultiLaser) {
                    
                    laserHits_PwrUp_Mlt(firstBody_Objekt.node as! SKSpriteNode)
                    
                } else
                
                //Laser trifft Power Up Power Laser
                if (firstBody_Objekt.categoryBitMask == PhysicsCategory.PhyPowerUpPowerLaser) {
                    
                    laserHits_PwrUp_Pwr(firstBody_Objekt.node as! SKSpriteNode)
                    
                } else
                
                //Laser trifft Power Up SlowMo
                if (firstBody_Objekt.categoryBitMask == PhysicsCategory.PhyPowerUpSlowMo) {
                    
                    laserHits_PwrUp_Slw(firstBody_Objekt.node as! SKSpriteNode)
                    
                }
            
            }
            
        } else if secondBody_Laser.categoryBitMask == PhysicsCategory.PhyRaumschiff {
            
            if (firstBody_Objekt.node != nil && secondBody_Laser.node != nil) {
                
                //Laser trifft normalen Asteroiden
                if (firstBody_Objekt.categoryBitMask == PhysicsCategory.PhyStdAst || firstBody_Objekt.categoryBitMask == PhysicsCategory.PhyBigAst) {
                    
                    if firstBody_Objekt.categoryBitMask == PhysicsCategory.PhyStdAst {
                        aktualisiereLeben(-1)
                    } else {
                        aktualisiereLeben(-2)
                    }
                    
                    let lasertyp = Int(PhysicsCategory.PhyNormLaser)
                    showExplosion(lasertyp, pos: (firstBody_Objekt.node as! SKSpriteNode).position)
                    
                    let Asteroid = firstBody_Objekt.node as! SKSpriteNode
                    Asteroid.removeFromParent()
                    
                }
            }
        }
        
    }
    
    
    func getAimLaserAngle (FingerLocation : CGPoint) {
        
        let DistanceFromCenterY = abs(FingerLocation.y-AimReferencePoint.y)
        let DistanceFromCenterX = abs(FingerLocation.x-AimReferencePoint.x)
        
        let YFingerValue  = min(DistanceFromCenterY, FingerMoveSpace)
        let XFingerValue  = min(DistanceFromCenterX, FingerMoveSpace)
        
        if Option_ControlVartical == true {
            
            let ProzentYAusdehnung = YFingerValue/FingerMoveSpace
            
            var t = ProzentYAusdehnung
            
            
            if FingerLocation.y-AimReferencePoint.y < 0 {
                t = -t
            }
            
            AimLaserAngle = (t)*(-90)
            
        } else {
           
            let ProzentXAusdehnung = XFingerValue/FingerMoveSpace
            
            var t = ProzentXAusdehnung
            
            
            if FingerLocation.x-AimReferencePoint.x < 0 {
                t = -t
            }
            
            AimLaserAngle = (t)*(-90)
            
        }
        
        if Option_InvertControls == true {
            AimLaserAngle = -AimLaserAngle
        }
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let Touch_location = touch.locationInNode(self)
            let Touch_location_PL = touch.locationInNode(Game_Pause_Layer)
            
            if Game_Pause_Button.containsPoint(Touch_location) {
                Game_Pause_Button.colorBlendFactor = 0.4
            }
            
            
            if GamePaused == false {
                //Spiel läuft
                
                if PointInLeftField(Touch_location) {
                    //Finger im Zielregler links

                    AimReferencePoint = Touch_location
                    AimReferencePoint.y += AimVorzeichen*(AimLaserAngle/90)*FingerMoveSpace
                    AimReferencePoint.x += AimVorzeichen*(AimLaserAngle/90)*FingerMoveSpace
                    getAimLaserAngle(Touch_location)
                    
                    Game_Raumschiff_Laserkanone.zRotation = (AimLaserAngle*CGFloat(M_PI / 180))-Game_Raumschiff.zRotation
                    
                    if Tut_Active == true {
                        LeftFieldBorder.removeAllActions()
                        LeftFieldBorder.colorBlendFactor = 0.5
                        Arrows.alpha = 1
                    }
                    
                } else if PointInCenterField(Touch_location) {
                    //Finger in der Mitte
                
                    if TutorialSign.containsPoint(Touch_location) {
                        TutorialSign.colorBlendFactor = 0.4
                    }
                
                } else if PointInRightField(Touch_location) {
                    //Finger im Abzug rechts
                    
                    shootLaserSetup()
                    
                    if Tut_Active == true {
                        RightFieldBorder.removeAllActions()
                        RightFieldBorder.colorBlendFactor = 0.5
                        
                        let Tap = SKSpriteNode(imageNamed: "Tutorial_Tap")
                        Tap.position = Touch_location
                        Tap.alpha = 0.8
                        Tap.zPosition = 2.8
                        Tap.setScale(0.1)
                        TutorialNode.addChild(Tap)
                        Tap.runAction(SKAction.sequence([SKAction.group([SKAction.scaleTo(1, duration: 0.3), SKAction.fadeOutWithDuration(0.3)]), SKAction.runBlock({self.removeFromParent()})]))
                    }
                    
                } else {
                    
                    
                }
                
                
            } else {
                //Pause-Menü
                if Pause_Play_Button.containsPoint(Touch_location_PL) {
                    Pause_Play_Button.colorBlendFactor = 0.4
                }
                
                if Pause_Quit_Button.containsPoint(Touch_location_PL) {
                    Pause_Quit_Button.colorBlendFactor = 0.4
                }
                
            }
            
           
        }
    }

    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            let Touch_location = touch.locationInNode(self)
            
            if GamePaused == false {
                
                if PointInLeftField(Touch_location) {
                    //Finger im Zielregler links
                    
                    getAimLaserAngle(Touch_location)
                    
                    Game_Raumschiff_Laserkanone.zRotation = (AimLaserAngle*CGFloat(M_PI / 180))-Game_Raumschiff.zRotation
                    
                } else if PointInCenterField(Touch_location) {
                    //Finger in der Mitte
                    
                    
                } else {
                    //Finger im Abzug rechts
                }
                
            }
        }
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let Touch_location = touch.locationInNode(self)
            let Touch_location_PL = touch.locationInNode(Game_Pause_Layer)
            
            if GamePaused == false {
                //Spiel läuft
                
                if PointInLeftField(Touch_location) {
                    //Finger im Zielregler links
                    
                    if Tut_Active == true {
                        LeftFieldBorder.runAction(SKAction.colorizeWithColorBlendFactor(0, duration: 0.2))
                        Arrows.alpha = 0.5
                    }
                    
                } else if PointInCenterField(Touch_location) {
                    //Finger in der Mitte
                    if Tut_Active == true {
                        Arrows.alpha = 0.5
                        
                        if TutorialSign.containsPoint(Touch_location) {
                            TutorialSign.colorBlendFactor = 0
                            TutorialNode.runAction(SKAction.sequence([SKAction.fadeOutWithDuration(1), SKAction.runBlock({
                                self.TutorialNode.removeFromParent()
                                self.Tut_Active = false
                            })]))
                        }
                    }
                    
                } else if PointInRightField(Touch_location) {
                    //Finger im Abzug rechts
                    if Tut_Active == true {
                        RightFieldBorder.runAction(SKAction.colorizeWithColorBlendFactor(0, duration: 0.2))
                    }
                    
                } else if Game_Pause_Button.containsPoint(Touch_location) {
                    //Pause Button gedrückt
                    ActivatePauseLayer(true, Modus: "Pause")
                }
                
                
                
            } else {
                //Spiel pausiert
                
                if Pause_Quit_Button.containsPoint(Touch_location_PL) {
                    
                    loadView("GameMenu")
                    
                }
                
                if Pause_Play_Button.containsPoint(Touch_location_PL) || Game_Pause_Button.containsPoint(Touch_location) {
                    //Spiel fortsetzen
                    
                    
                    if GameOver == false {
                        //Bei Pause das Spiel fortsetzen
                        ActivatePauseLayer(false, Modus: "Pause")
                        
                    } else {
                        //Bei Game Over Spiel neu starten
                        
                        loadView("GameArea")
                        
                    }
                    
                }

            }
            
        }
        Game_Pause_Button.colorBlendFactor = 0.0
        Pause_Play_Button.colorBlendFactor = 0.0
        Pause_Quit_Button.colorBlendFactor = 0.0
    }
    
    
    
    
    
    func blurWorld (EnableBlur: Bool, blurMax: CGFloat) {
        
        if Testing_EffectsAllowed == true {
            
            if EnableBlur == true {
                
                worldNode.removeFromParent()
                blurNode.addChild(worldNode)
                
                let blur = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": 1.0])
                blurNode.filter = blur
                
                
                let blurDuration = 1.0
                
                let blurAction = SKAction.customActionWithDuration(blurDuration, actionBlock: { (node:SKNode!, elapsed: CGFloat) -> Void in
                    blur!.setValue((CGFloat(elapsed) / CGFloat(blurDuration))*blurMax, forKey: "inputRadius")
                })
                
                blurNode.runAction(blurAction)
                
            } else {
                
                let blur = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius": 1.0])
                blurNode.filter = blur
                
                //y= -x+1
                
                let blurDuration = 1.0
                
                let blurAction = SKAction.customActionWithDuration(blurDuration, actionBlock: { (node:SKNode!, elapsed: CGFloat) -> Void in
                    blur!.setValue((CGFloat(-elapsed+CGFloat(blurDuration)))*blurMax, forKey: "inputRadius")
                })
                
                blurNode.runAction(blurAction)
                
                worldNode.removeFromParent()
                addChild(worldNode)
                
            }
        }
        
    }
    
    
    func appMovedToBackground() {
        
        Game_Pause_Layer.position = CGPoint(x: size.width/2, y: size.height - Game_Statusbar.size.height - Game_Pause_Layer.size.height/2)
        GamePaused = true
        
        ActivatePauseLayer(true, Modus: "Pause")
    }
    
    
    func initialisierePowerUpNodes (Node: PwrUpIconSpriteNode, i: Int) {
        
        Node.TimeDisplay.text = ""
        Node.TimeDisplay.fontSize = 10
        Node.TimeDisplay.fontColor = UIColor.whiteColor()
        Node.TimeDisplay.position = CGPoint(x: 0, y: -Node.size.height * 0.75)
        Node.TimeDisplay.zPosition = 2.0
        Node.addChild(Node.TimeDisplay)
        
        Node.name = "PowerUpIcon"
        Node.position = PwrUp_HUD_IconStorePoint
        //Node.setScale(MainScreenScale)
        HUD_Node.addChild(Node)
        Node.zPosition = 3.6
        
        PwrUp_IconArray[i] = Node
    }
    
    
    func PwrUp_add (Node: PwrUpIconSpriteNode) {
        
        if Node.posInHUD == 0 {
            for i in 0...PwrUp_IconArray.count-1 {
                if PwrUp_IconArray[i].posInHUD != 0 {
                    PwrUp_IconArray[i].posInHUD += 1
                }
            }
            Node.posInHUD = 1
            PwrUp_updateHUD()
        }
        
    }
    
    
    func PwrUp_remove (Node: PwrUpIconSpriteNode) {
        
        let Ausblenden = SKAction.fadeOutWithDuration(1.0)
        let MoveToStorepoint = SKAction.moveTo(PwrUp_HUD_IconStorePoint, duration: 0.0)
        let Einblenden = SKAction.fadeInWithDuration(0.0)
        Node.removeAllActions()
        Node.runAction(SKAction.sequence([Ausblenden, MoveToStorepoint, Einblenden]))
        
        let pos = Node.posInHUD
        Node.posInHUD = 0
        
        for i in 0...PwrUp_IconArray.count-1 {
            if PwrUp_IconArray[i].posInHUD > pos {
                PwrUp_IconArray[i].posInHUD -= 1
            }
        }
        PwrUp_updateHUD()
    }
    
    
    func PwrUp_updateHUD () {
        
        for i in 0...PwrUp_IconArray.count-1 {
            if PwrUp_IconArray[i].posInHUD != 0 {
                let moveToPos = SKAction.moveTo(CGPoint(x: -PwrUp_HUD_IconStorePoint.x + (PwrUp_HUD_IconDistance * CGFloat(PwrUp_IconArray[i].posInHUD - 1)), y: PwrUp_HUD_IconStorePoint.y), duration: 1.5)
                moveToPos.timingMode = SKActionTimingMode.EaseInEaseOut
                PwrUp_IconArray[i].removeAllActions()
                PwrUp_IconArray[i].alpha = 1
                PwrUp_IconArray[i].runAction(moveToPos)
            }
        }
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
        
        
        //Y
        if RSMovement_Y_Active == false {
            
            //Bewegungsspielraum
            var maxMove_Y : CGFloat = 0
            var minMove_Y : CGFloat = 0
            
            maxMove_Y = maxAbs( (RSCenterPoint.y-RSCage_Y) - Game_Raumschiff.position.y , b: (RSCenterPoint.y+RSCage_Y) - Game_Raumschiff.position.y)
            minMove_Y = (1/3)*maxMove_Y
            
            var MoveDistanceY = random(min: abs(minMove_Y), max: abs(maxMove_Y))
            if maxMove_Y < 0 {
                MoveDistanceY = MoveDistanceY * (-1)
            }
            
            let Drehung_1_0 = MoveDistanceY/(2*RSCage_Y)
            let Winkel_Rad = Drehung_1_0*CGFloat(M_PI/20)
            RSMovement_Y_Active = true
            
            let move_Y_action = SKAction.moveToY(Game_Raumschiff.position.y + MoveDistanceY , duration: 3)
            move_Y_action.timingMode = SKActionTimingMode.EaseInEaseOut
            
            let rotate_Z_action_first = SKAction.rotateToAngle(Winkel_Rad, duration: 1.5)
            rotate_Z_action_first.timingMode = SKActionTimingMode.EaseInEaseOut
            
            let rotate_Z_action_second = SKAction.rotateToAngle(0, duration: 1.5)
            rotate_Z_action_second.timingMode = SKActionTimingMode.EaseInEaseOut
            
            Game_Raumschiff.runAction(SKAction.sequence([SKAction.group([move_Y_action, SKAction.sequence([rotate_Z_action_first, rotate_Z_action_second])]), SKAction.runBlock({self.RSMovement_Y_Active = false})]))
            
        }
        
    }
    
    
    func runTutorial () {
        
        Tut_Active = Option_ShowTutorial
        
        if Tut_Active == true {
            
            addChild(TutorialNode)
            //TutorialSign.setScale(CGFloat(MainScreenScale))
            TutorialSign.size.width = size.width/5
            TutorialSign.size.height = TutorialSign.size.width/4 ///5
            TutorialSign.zPosition = 2.9
            TutorialSign.position = CGPoint(x: size.width/2, y: GameViewHeigth-TutorialSign.size.height/2)
            TutorialSign.color = UIColor.blackColor()
            TutorialNode.addChild(TutorialSign)
            
            let TutorialTitel = SKLabelNode(fontNamed: "ArialMT")
            //TutorialTitel.setScale(CGFloat(MainScreenScale))
            TutorialTitel.text = "Exit tutorial"
            TutorialTitel.zPosition = 0.01
            TutorialTitel.fontSize = 15 // 20, Tutorial
            TutorialTitel.fontColor = UIColor.whiteColor()
            TutorialTitel.horizontalAlignmentMode = .Center
            TutorialTitel.verticalAlignmentMode = .Center
            TutorialTitel.position = CGPoint(x: 0, y: 0)
            
            
            TutorialSign.addChild(TutorialTitel)
            
            
            LeftFieldBorder.position = CGPoint(x: size.width/5, y: GameViewHeigth/2)
            RightFieldBorder.position = CGPoint(x: size.width - size.width/5, y: GameViewHeigth/2)
            
            RightFieldBorder.Titel.text = "Tap to shoot"
            LeftFieldBorder.Titel.text = "Move to aim"
            
            let Fields = [LeftFieldBorder, RightFieldBorder]
            
            for i in 0...1 {
                //Fields[i].setScale(CGFloat(MainScreenScale))
                Fields[i].alpha = 0.5
                Fields[i].color = UIColor.redColor()
                Fields[i].zPosition = 2.9
                Fields[i].size.height = GameViewHeigth
                Fields[i].size.width = size.width*(2/5)
                TutorialNode.addChild(Fields[i])
                
                Fields[i].Titel.color = UIColor.whiteColor()
                //Fields[i].Titel.setScale(CGFloat(MainScreenScale))
                Fields[i].Titel.fontSize = 30 //Std = 32
                Fields[i].Titel.horizontalAlignmentMode = .Center
                Fields[i].Titel.verticalAlignmentMode = .Top
                Fields[i].Titel.position = CGPoint(x: 0, y: Fields[i].size.height*(4/5)/2)
                Fields[i].addChild(Fields[i].Titel)
            }
            
            Arrows.color = UIColor.whiteColor()
            Arrows.zPosition = 2.9
            Arrows.alpha = 0.5
            
            if Option_ControlVartical == true {
                Arrows.zRotation = CGFloat(M_PI/2)
                Arrows.position = CGPoint(x: LeftFieldBorder.position.x + LeftFieldBorder.size.width/4, y: LeftFieldBorder.position.y - LeftFieldBorder.size.height/12)
            } else {
                Arrows.position = CGPoint(x: LeftFieldBorder.position.x + 0, y: LeftFieldBorder.position.y + LeftFieldBorder.size.height/5)
            }
            
            TutorialNode.addChild(Arrows)
            
            let HinweisPfeil = SKSpriteNode(imageNamed: "Tutorial_Arrow")
            //HinweisPfeil.setScale(CGFloat(MainScreenScale))
            HinweisPfeil.zRotation = CGFloat(-M_PI/2)
            HinweisPfeil.position = CGPoint(x: size.width/2, y: GameViewHeigth - TutorialSign.size.height - HinweisPfeil.size.width/5)
            HinweisPfeil.anchorPoint = CGPointMake(0, 0.5) //umdenken, weil Pfeil gedreht
            HinweisPfeil.zPosition = 2.9
            HinweisPfeil.alpha = 0
            TutorialNode.addChild(HinweisPfeil)
            
            let GoTitel = SKLabelNode(fontNamed: "ArialMT")
            GoTitel.text = "Tap to play"
            GoTitel.zPosition = 0.01
            GoTitel.fontSize = 15
            GoTitel.fontColor = UIColor.whiteColor()
            GoTitel.horizontalAlignmentMode = .Center
            GoTitel.verticalAlignmentMode = .Center
            GoTitel.position = CGPoint(x: size.width/2, y: size.height/2)
            GoTitel.alpha = 0
            TutorialNode.addChild(GoTitel)
            
            
            let warten = SKAction.waitForDuration(4)
            let fadeIn = SKAction.fadeInWithDuration(1)
            
            let MoveUp = SKAction.moveBy(CGVector(dx: 0, dy: HinweisPfeil.size.width/10), duration: 0.5)
            MoveUp.timingMode = SKActionTimingMode.EaseInEaseOut
            let MoveDown = SKAction.moveBy(CGVector(dx: 0, dy: -HinweisPfeil.size.width/10), duration: 0.5)
            MoveDown.timingMode = SKActionTimingMode.EaseInEaseOut
            
            HinweisPfeil.runAction(SKAction.repeatActionForever(SKAction.sequence([MoveDown, MoveUp])))
            
            HinweisPfeil.runAction(SKAction.sequence([warten, fadeIn]))
            GoTitel.runAction(SKAction.sequence([warten, fadeIn]))
            
        }
        
        
    }
    
    
    func OrganizeBackground () {
        
        if bg1.position.x < -bg1.size.width {
            
            let newTexture = randomInt(min: 0, max: bg_array.count-1)
            
            bg1.texture = bg_array[newTexture]
            bg1.size = bg_array[newTexture].size()
            
            bg1.position.x = bg2.position.x+bg2.size.width
            
        }
        
        if bg2.position.x < -bg2.size.width {
            
            let newTexture = randomInt(min: 0, max: bg_array.count-1)
        
            bg2.texture = bg_array[newTexture]
            bg2.size = bg_array[newTexture].size()
            
            bg2.position.x = bg1.position.x+bg1.size.width
            
        }
        
        if Ingame_Time > Ast_Time_gP {
            BG_Speed = BG_Speed_max
        } else {
            BG_Speed = (BG_Speed_m*Float(Ingame_Time))+1
        }
            
        bg1.speed = CGFloat(BG_Speed)
        bg2.speed = CGFloat(BG_Speed)
        
    }
    
    
    func loadView (SzeneString: String) {
        
        runAction(SKAction.sequence([
            SKAction.runBlock({
                let reveal = SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 1.0)
                
                switch SzeneString {
                case "GameArea":
                    self.view?.presentScene(GameArea(size: self.size), transition:reveal)
                default:
                    self.view?.presentScene(GameMenu(size: self.size), transition:reveal)
                }
            })
            ]))
        
    }
    
    
    func showExplosion (lasertyp: Int, pos: CGPoint) {
        
        var fileName = "explosion_red"
        
        if lasertyp == Int(PhysicsCategory.PhyPowerLaser) {
            fileName = "explosion_blue"
        }
        
        let EmitterNode = SKEmitterNode(fileNamed: fileName)
        
        EmitterNode?.position = pos
        EmitterNode?.zPosition = 0.6
        EmitterNode?.setScale(0.4)
        ObjektMotherNode.addChild(EmitterNode!)
        EmitterNode?.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock({EmitterNode?.removeFromParent()})]))
    }
    
    
    
    func ActivatePauseLayer (Activate: Bool, Modus: String) {
        
        if Activate == true && Modus == "Game Over" {
            GameOver = true
            SaveScore(AsteroidsHit)
        }
        
        GamePaused = Activate
        blurWorld(Activate, blurMax: 10.0)
        
        if Activate == true {
            
            Pause_Titel.text = Modus
            let shots : Float = Float(ShotsFired)
            let hits : Float = Float(AsteroidsHit)
            var ShotsPerHit : String
            
            if hits != 0 {
                ShotsPerHit = String(floor((shots/hits)*10)/10)
            } else {
                ShotsPerHit = "0"
            }
            
            Pause_Hits.text = "Hits: "+String(AsteroidsHit)+" | Shots per Hit: "+ShotsPerHit
            
            let alphaLow = SKAction.fadeAlphaTo(0.1, duration: 0.8)
            let alphaHigh = SKAction.fadeAlphaTo(1, duration: 0.8)
            
            Pause_Titel.runAction(SKAction.repeatActionForever(SKAction.sequence([alphaLow, alphaHigh])))
            
            
            let moveIn = SKAction.moveToY(size.height - Game_Statusbar.size.height - Game_Pause_Layer.size.height/2, duration: 0.6)
            moveIn.timingMode = SKActionTimingMode.EaseOut
            
            Game_Pause_Layer.runAction(moveIn)
            
            worldNode.removeActionForKey("SlowStartWorld")
            worldNode.runAction(SKAction.speedTo(0.0, duration: 0.0))
            
            
        } else {
            
            let moveOut = SKAction.moveToY(size.height + Game_Pause_Layer.size.height/2 - Game_Statusbar.size.height, duration: 0.6)
            moveOut.timingMode = SKActionTimingMode.EaseIn
            
            Game_Pause_Layer.runAction(SKAction.sequence([moveOut, SKAction.runBlock({self.Pause_Titel.removeAllActions()})]))
            
            worldNode.runAction(SKAction.speedTo(1.0, duration: 1.0), withKey: "SlowStartWorld")
            
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
    
    
    func PointInLeftField (Point : CGPoint) -> Bool {
        
        if Point.x <= (2/5)*size.width && Point.y <= GameViewHeigth {
            return true
        }
        
        return false
        
    }
    
    func PointInCenterField (Point : CGPoint) -> Bool {
        
        if PointInLeftField(Point) == false && PointInRightField(Point) == false && Point.y <= GameViewHeigth {
            return true
        }
        
        return false
        
    }
    
    func PointInRightField (Point : CGPoint) -> Bool {
        
        if Point.x >= (3/5)*size.width && Point.y <= GameViewHeigth {
            return true
        }
        
        return false
        
    }
    
    

    
}





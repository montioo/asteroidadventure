//
//  MainMenu.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 23.02.16.
//  Copyright (c) 2016 Marius Montebaur. All rights reserved.
//



import SpriteKit
import Foundation

var isIPhone4s : Bool = false
var isIPhone5 : Bool = false

class MainMenu: SKScene {
    
    
    var ImpressumVisible : Bool = false
    //var PreferencesVisible : Bool = false
    
    var BannerMovement_X_Active : Bool = true
    var BannerMovement_Y_Active : Bool = true
    var BannerCenterPoint : CGPoint = CGPoint(x: 0, y: 0)
    var BannerCage_X : CGFloat = 0
    var BannerCage_Y : CGFloat = 0
    let Banneranimationtime : Double = 4
    
    let Banner_Fire_Rechts = SKEmitterNode(fileNamed: "engineExhaust_1.sks")
    let Banner_Fire_Links = SKEmitterNode(fileNamed: "engineExhaust_1.sks")
    
    let MainScreen = SKSpriteNode()
    let ImpressumScreen = SKSpriteNode()
    let PreferencesScreen = SKSpriteNode()
    
    let Menu_Universe = SKSpriteNode(imageNamed: "Menu_Universum_v3")
    let Menu_Asteroid = SKSpriteNode(imageNamed: "Menu_Asteroid")
    let Menu_Banner = SKSpriteNode(imageNamed: "Banner_Schriftzug")
    let Menu_MusicNode = SKSpriteNode()
    
    let transitionDuration : Double = 0.75
    
    var musicActive : Bool = false
    
    override func didMoveToView(view: SKView) {
        
        if size.width == 480 {
            isIPhone4s = true
        }
        if size.width == 568 {
            isIPhone5 = true
        }
        
        calcScaleMode()
        
        addChild(MainScreen)
        addChild(Menu_MusicNode)
        
        Menu_Universe.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(Menu_Universe)
        
        let starEmitter = SKEmitterNode(fileNamed: "spaceStars")
        starEmitter?.zPosition = 0.01
        starEmitter?.position = CGPoint(x: 0, y: 0)
        starEmitter?.particlePositionRange = CGVector(dx: Menu_Universe.size.width, dy: Menu_Universe.size.height)
        Menu_Universe.addChild(starEmitter!)
        
        Menu_setup()
        Impressum_setup()
        Preferences_setup()
        
        
        if getBoolOption("music") {
            musicActive = true
            self.runAction(SKAction.sequence([SKAction.waitForDuration(2), SKAction.runBlock({
                let backgroundMusic = SKAudioNode(fileNamed: "themesound.mp3")
                self.Menu_MusicNode.addChild(backgroundMusic)
            })]))
        }
        
        //print(size.width)
        //4s: 480
        //5s: 568
        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        FlyBanner()
        
        
        
        if !musicActive && getBoolOption("music") {
            musicActive = true
            self.runAction(SKAction.sequence([SKAction.waitForDuration(0), SKAction.runBlock({
                let backgroundMusic = SKAudioNode(fileNamed: "themesound.mp3")
                self.Menu_MusicNode.addChild(backgroundMusic)
            })]))
            
        } else if musicActive && !getBoolOption("music") {
            musicActive = false
            Menu_MusicNode.removeAllChildren()
        }
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if ImpressumVisible {
            if let sound = playSoundEffect(soundEffect_buttonKlick, looped: false) {
                ImpressumScreen.addChild(sound)
            }
        }
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if ImpressumVisible {
            
            let backToMain = SKAction.moveToY(0.0, duration: transitionDuration)
            backToMain.timingMode = SKActionTimingMode.EaseInEaseOut
            let universeMove = SKAction.moveToY(size.height/2, duration: transitionDuration)
            universeMove.timingMode = SKActionTimingMode.EaseInEaseOut
            
            MainScreen.runAction(backToMain)
            Menu_Universe.runAction(universeMove)
            
            ImpressumVisible = false
                
        }
        
    }
    
    
    func FlyBanner () {
        //wird in update aufgerufen
        
        //Y
        if BannerMovement_Y_Active == false {
            
            //Bewegungsspielraum
            var maxMove_Y : CGFloat = 0
            var minMove_Y : CGFloat = 0
            
            maxMove_Y = maxAbs( (BannerCenterPoint.y-BannerCage_Y) - Menu_Banner.position.y , b: (BannerCenterPoint.y+BannerCage_Y) - Menu_Banner.position.y)
            minMove_Y = (1/3)*maxMove_Y
            
            var MoveDistanceY = random(min: abs(minMove_Y), max: abs(maxMove_Y))
            if maxMove_Y < 0 {
                MoveDistanceY = MoveDistanceY * (-1)
            }
            
            BannerMovement_Y_Active = true
            
            let exhaustBirthrate = max(40, (80 + ((MoveDistanceY / BannerCage_Y)*60)))
            
            Banner_Fire_Rechts?.particleBirthRate = exhaustBirthrate
            Banner_Fire_Links?.particleBirthRate = exhaustBirthrate
            
            let move_Y_action = SKAction.moveToY(Menu_Banner.position.y + MoveDistanceY , duration: Banneranimationtime)
            move_Y_action.timingMode = SKActionTimingMode.EaseInEaseOut
            Menu_Banner.runAction(SKAction.group([SKAction.sequence([SKAction.waitForDuration(0.5), move_Y_action]),
                SKAction.sequence([SKAction.waitForDuration(3.5), SKAction.runBlock({self.BannerMovement_Y_Active = false})])
            ]))
            
        }
        
        //Damit die Bewegung geschmeidiger ist, wird beim ersten Durchlauf BannerMovement_X_Active 0.5 Sekunden später auf false gesetzt.
        
        //X
        if BannerMovement_X_Active == false {
            
            //Bewegungsspielraum
            var maxMove_X : CGFloat = 0
            var minMove_X : CGFloat = 0
            
            maxMove_X = maxAbs( (BannerCenterPoint.x-BannerCage_X) - Menu_Banner.position.x , b: (BannerCenterPoint.x+BannerCage_X) - Menu_Banner.position.x)
            minMove_X = (1/3)*maxMove_X
            
            var MoveDistanceX = random(min: abs(minMove_X), max: abs(maxMove_X))
            if maxMove_X < 0 {
                MoveDistanceX = MoveDistanceX * (-1)
            }
            
            let Drehung_1_0 = MoveDistanceX/(2*BannerCage_X)
            let Winkel_Rad = Drehung_1_0*CGFloat(M_PI/32)
            BannerMovement_X_Active = true
            
            let move_X_action = SKAction.moveToX(Menu_Banner.position.x + MoveDistanceX , duration: Banneranimationtime)
            move_X_action.timingMode = SKActionTimingMode.EaseInEaseOut
            
            let rotate_Z_action_first = SKAction.rotateToAngle(-Winkel_Rad, duration: Banneranimationtime/2)
            rotate_Z_action_first.timingMode = SKActionTimingMode.EaseInEaseOut
            
            let rotate_Z_action_second = SKAction.rotateToAngle(Winkel_Rad*0.5, duration: Banneranimationtime/3)
            rotate_Z_action_second.timingMode = SKActionTimingMode.EaseInEaseOut
            
            let rotate_Z_action_third = SKAction.rotateToAngle(0, duration: Banneranimationtime/6)
            rotate_Z_action_third.timingMode = SKActionTimingMode.EaseInEaseOut
           
            Menu_Banner.runAction(SKAction.sequence([
                SKAction.group([
                    move_X_action, SKAction.sequence([rotate_Z_action_first, rotate_Z_action_second, rotate_Z_action_third])]),
                SKAction.runBlock({self.BannerMovement_X_Active = false})
                ]))
            
        }
        
    }
    
    
    func Menu_setup () {
        
        let PlayButton = ButtonClass(title: "PLAY", fontSize: 24, height: size.height*0.133, width: size.width*0.3, function: buttonPressed_Play, appearWithAnimation: true, boldFont: true)
        PlayButton.position = CGPoint(x: size.width/3, y: size.height/2.5)
        MainScreen.addChild(PlayButton)
        
        let SettingsButton = ButtonClass(title: "settings", fontSize: 18, height: size.height*0.093, width: size.width*0.225, function: buttonPressed_Settings, appearWithAnimation: true, boldFont: false)
        SettingsButton.position = CGPoint(x: size.width/3, y: PlayButton.position.y-PlayButton.getButtonHeight()/2-SettingsButton.getButtonHeight()*0.6)
        MainScreen.addChild(SettingsButton)
        
        let AboutButton = ButtonClass(title: "about", fontSize: 18, height: size.height*0.093, width: size.width*0.225, function: buttonPressed_About, appearWithAnimation: true, boldFont: false)
        AboutButton.position = CGPoint(x: size.width/3, y: SettingsButton.position.y-SettingsButton.getButtonHeight()/2-SettingsButton.getButtonHeight()*0.6)
        MainScreen.addChild(AboutButton)
        
        MainScreen.runAction(SKAction.sequence([
            SKAction.waitForDuration(1.4),
            SKAction.runBlock({PlayButton.animationAppear()}),
            SKAction.waitForDuration(0.25),
            SKAction.runBlock({SettingsButton.animationAppear()}),
            SKAction.waitForDuration(0.25),
            SKAction.runBlock({AboutButton.animationAppear()}),
        ]))
        
        let refNode = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(0, 0))
        refNode.position = CGPoint(x: size.width/2, y: size.height/2)
        refNode.zPosition = 1.0
        MainScreen.addChild(refNode)
        
        //Asteroiden hinzufügen
        Menu_Asteroid.position = CGPoint(x: size.width*(3/4), y: size.height/2)
        Menu_Asteroid.zPosition = 1.0
        MainScreen.addChild(Menu_Asteroid)
        Menu_Asteroid.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(1.0, duration: 10.0)))
    
        
        Menu_Banner.position = CGPoint(x: Menu_Banner.size.width/2, y: -Menu_Banner.size.height)
        BannerCenterPoint = CGPoint(x: size.width*(3/10), y: size.height*(6.2/8))
        Menu_Banner.zPosition = 1.0
        Menu_Banner.zRotation = -0.15
        MainScreen.addChild(Menu_Banner)
        BannerCage_X = (BannerCenterPoint.x - Menu_Banner.size.width/2)*(4.6/6)
        BannerCage_Y = ((size.height - BannerCenterPoint.y) - Menu_Banner.size.height/2)/2
        
        let Banner_Rakete_Links = SKSpriteNode(imageNamed: "Banner_Rakete")
        //if isIPhone4s {Banner_Rakete_Links.setScale(0.8)}
        Banner_Rakete_Links.position = CGPoint(x: -Menu_Banner.size.width/2 - Banner_Rakete_Links.size.width/2, y: Banner_Rakete_Links.size.height*0.12)
        Banner_Rakete_Links.zPosition = 0.2
        Menu_Banner.addChild(Banner_Rakete_Links)
        
        let Banner_Rakete_Rechts = SKSpriteNode(imageNamed: "Banner_Rakete")
        //if isIPhone4s {Banner_Rakete_Rechts.setScale(0.8)}
        Banner_Rakete_Rechts.position = CGPoint(x: Menu_Banner.size.width/2 + Banner_Rakete_Rechts.size.width/2, y: Banner_Rakete_Rechts.size.height*0.12)
        Banner_Rakete_Rechts.zPosition = 0.2
        Menu_Banner.addChild(Banner_Rakete_Rechts)
        
        if isIPhone4s {Menu_Banner.setScale(0.8)}
        
        Banner_Fire_Links!.position = CGPoint(x: 0, y: -Banner_Rakete_Links.size.height/2)
        if isIPhone4s {Banner_Fire_Links!.setScale(0.8)}
        Banner_Fire_Links!.zPosition = -0.1
        Banner_Fire_Links!.targetNode = refNode
        Banner_Rakete_Links.addChild(Banner_Fire_Links!)
        
        Banner_Fire_Rechts!.position = CGPoint(x: 0, y: -Banner_Rakete_Links.size.height/2)
        if isIPhone4s {Banner_Fire_Rechts!.setScale(0.8)}
        Banner_Fire_Rechts!.zPosition = -0.1
        Banner_Fire_Rechts!.targetNode = refNode
        Banner_Rakete_Rechts.addChild(Banner_Fire_Rechts!)
        
        let BannerWait = SKAction.waitForDuration(0.3)
        let BannerMoveIn = SKAction.group([
            SKAction.moveTo(BannerCenterPoint, duration: 1.4),
            SKAction.rotateToAngle(0, duration: 1.4)
            ])
        BannerMoveIn.timingMode = SKActionTimingMode.EaseOut
        Menu_Banner.runAction(SKAction.sequence([BannerWait, BannerMoveIn, SKAction.runBlock({
            self.BannerMovement_Y_Active = false}),
            SKAction.waitForDuration(0.5),
            SKAction.runBlock({
                self.BannerMovement_X_Active = false})
            ]))
        
        let HighscoreLabel = SKLabelNode(fontNamed: "Arial-MT")
        HighscoreLabel.text = "highscore: " + String(Int(bestStats["highscore"]!))
        HighscoreLabel.fontSize = 16
        HighscoreLabel.fontColor = UIColor.whiteColor()
        HighscoreLabel.position = CGPoint(x: size.width - HighscoreLabel.frame.size.width/2 - HighscoreLabel.frame.size.height*0.5, y: size.height - HighscoreLabel.frame.size.height*1.0)
        HighscoreLabel.horizontalAlignmentMode = .Center
        HighscoreLabel.verticalAlignmentMode = .Center
        HighscoreLabel.zPosition = 5
        MainScreen.addChild(HighscoreLabel)

        
    }
    
    
    func Impressum_setup () {
        
        ImpressumScreen.position = CGPoint(x: 0, y: size.height)
        ImpressumScreen.zPosition = 2
        MainScreen.addChild(ImpressumScreen)
        
        let title = SKSpriteNode(imageNamed: "AstAdv_Logo")
        title.position = CGPoint(x: size.width/2, y: size.height*0.8)
        ImpressumScreen.addChild(title)
        
        let thanks = SKLabelNode(fontNamed: "Arial-MT")
        thanks.fontSize = 18
        thanks.fontColor = whiteFont
        thanks.text = "special thanks go to the community of stackoverflow.com"
        thanks.position = CGPoint(x: size.width/2, y: size.height*0.60)
        ImpressumScreen.addChild(thanks)
        
        let myName = SKLabelNode(fontNamed: "Arial-MT")
        myName.fontSize = 18
        myName.fontColor = whiteFont
        myName.text = "© 2016 Marius Montebaur"
        myName.position = CGPoint(x: size.width/2, y: size.height*0.3)
        ImpressumScreen.addChild(myName)
        
        if let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] {
            if let versionNumber = nsObject as? String {
                
                let version = SKLabelNode(fontNamed: "Arial-MT")
                version.fontColor = whiteFont
                version.fontSize = 12
                version.text = "version: " + versionNumber
                version.verticalAlignmentMode = .Center
                version.horizontalAlignmentMode = .Center
                version.position = CGPoint(x: size.width - version.frame.size.width/2 - version.frame.size.height*0.2, y: size.height - version.frame.size.height*0.7)
                ImpressumScreen.addChild(version)
            }
        }
        
        let feedbackButton = ButtonClass(title: "send a feedback email", fontSize: 15, height: size.height*0.1, width: size.width*0.4, function: buttonPressed_SendFeedback, appearWithAnimation: false, boldFont: false)
        feedbackButton.position = CGPoint(x: size.width/2, y: size.height*0.175)
        ImpressumScreen.addChild(feedbackButton)
        
        let themesongLabel1 = SKLabelNode(fontNamed: "Arial-MT")
        themesongLabel1.text = "themesong: I dunno by grapes (c)"
        themesongLabel1.fontSize = 12
        themesongLabel1.fontColor = whiteFont
        themesongLabel1.horizontalAlignmentMode = .Center
        themesongLabel1.verticalAlignmentMode = .Baseline
        themesongLabel1.position = CGPoint(x: size.width/2, y: size.height*0.52)
        ImpressumScreen.addChild(themesongLabel1)
        
        let themesongLabel2 = SKLabelNode(fontNamed: "Arial-MT")
        themesongLabel2.text = "copyright 2008 Licensed under a Creative Commons Attribution (3.0) license."
        themesongLabel2.fontSize = 12
        themesongLabel2.fontColor = whiteFont
        themesongLabel2.horizontalAlignmentMode = .Center
        themesongLabel2.verticalAlignmentMode = .Baseline
        themesongLabel2.position = CGPoint(x: size.width/2, y: themesongLabel1.position.y - themesongLabel1.frame.size.height*1.3)
        ImpressumScreen.addChild(themesongLabel2)
        
        let themesongLabel3 = SKLabelNode(fontNamed: "Arial-MT")
        themesongLabel3.text = "http://dig.ccmixter.org/files/grapes/16626 Ft: J Lang, Morusque"
        themesongLabel3.fontSize = 12
        themesongLabel3.fontColor = whiteFont
        themesongLabel3.horizontalAlignmentMode = .Center
        themesongLabel3.verticalAlignmentMode = .Baseline
        themesongLabel3.position = CGPoint(x: size.width/2, y: themesongLabel2.position.y - themesongLabel2.frame.size.height*1.3)
        ImpressumScreen.addChild(themesongLabel3)
    }
    
    
    func Preferences_setup () {
        
        PreferencesScreen.position = CGPoint(x: 0, y: -size.height)
        PreferencesScreen.zPosition = 2
        MainScreen.addChild(PreferencesScreen)
        
        let PrefEnt_ShwTut = Preferences_Entry(dict_pref_key: "show_tutorial")
        let PrefEnt_AimHlp = Preferences_Entry(dict_pref_key: "aiming_help")
        
        let PrefTable_Left = Preferences_Table(title: "controls", shown_entrys: [PrefEnt_ShwTut, PrefEnt_AimHlp])
    
        let PrefEnt_EnaMus = Preferences_Entry(dict_pref_key: "music")
        let PrefEnt_EnaSou = Preferences_Entry(dict_pref_key: "sound_effects")
        let PrefEnt_EnaVib = Preferences_Entry(dict_pref_key: "vibration")
        
        let PrefTable_Right = Preferences_Table(title: "feedback", shown_entrys: [PrefEnt_EnaMus, PrefEnt_EnaSou, PrefEnt_EnaVib])
        
        let distanceBetweenTables = (size.width-2*PrefTable_Left.size.width)/3
        
        
        let backToMenuButton = ButtonClass(title: "back", fontSize: 16, height: size.height*0.085, width: 120, function: buttonPressed_SettingsBack, appearWithAnimation: false, boldFont: false)
        backToMenuButton.position = CGPoint(x: backToMenuButton.getButtonWidth()/2+distanceBetweenTables, y: size.height-backToMenuButton.getButtonHeight()/2-distanceBetweenTables)
        PreferencesScreen.addChild(backToMenuButton)
        
        let SettingsTitle = SKLabelNode(fontNamed: "Arial-BoldMT")
        SettingsTitle.text = "settings"
        SettingsTitle.fontSize = 32
        SettingsTitle.fontColor = UIColor.whiteColor()
        SettingsTitle.position = CGPoint(x: size.width/2, y: backToMenuButton.position.y-backToMenuButton.getButtonHeight()/2)
        SettingsTitle.horizontalAlignmentMode = .Center
        SettingsTitle.verticalAlignmentMode = .Baseline
        PreferencesScreen.addChild(SettingsTitle)
        
        /*
        let HighscoreLabel = SKLabelNode(fontNamed: "Arial-MT")
        HighscoreLabel.text = "highscore: " + String(Int(bestStats["highscore"]!))
        HighscoreLabel.fontSize = 18
        HighscoreLabel.fontColor = UIColor.whiteColor()
        HighscoreLabel.position = CGPoint(x: size.width-distanceBetweenTables, y: backToMenuButton.position.y-backToMenuButton.getButtonHeight()/2)
        HighscoreLabel.horizontalAlignmentMode = .Right
        HighscoreLabel.verticalAlignmentMode = .Baseline
        PreferencesScreen.addChild(HighscoreLabel)
        */
        
        PrefTable_Left.position = CGPoint(x: PrefTable_Left.size.width/2+distanceBetweenTables, y: size.height*0.8)
        PreferencesScreen.addChild(PrefTable_Left)
        
        PrefTable_Right.position = CGPoint(x: PrefTable_Right.size.width*1.5+2*distanceBetweenTables, y: size.height*0.8)
        PreferencesScreen.addChild(PrefTable_Right)
    }
    
    
    func calcScaleMode () {
        
        var parentScreenWidth = 1334
        
        if UIScreen.mainScreen().scale == 3 {
            parentScreenWidth = 1472
        }
        
        MainScreenScale = CGFloat(Float(size.width*2) / Float(parentScreenWidth))
    }
 
    
    func buttonPressed_Play () {
        if Menu_MusicNode.children.count != 0 {
            Menu_MusicNode.removeAllChildren()
        }
        runAction(SKAction.sequence([
            SKAction.runBlock() {
                let transition = SKTransition.moveInWithDirection(.Right, duration: 0.75)
                let scene = MainGame(size: self.size)
                self.view?.presentScene(scene, transition: transition)
            }
            ]))
    }
    
    
    func buttonPressed_About () {
        let universeMove = SKAction.moveToY(0, duration: transitionDuration)
        universeMove.timingMode = SKActionTimingMode.EaseInEaseOut
        let aboutMove = SKAction.moveToY(-size.height, duration: transitionDuration)
        aboutMove.timingMode = SKActionTimingMode.EaseInEaseOut
        
        MainScreen.runAction(aboutMove)
        Menu_Universe.runAction(universeMove)
        
        ImpressumVisible = true
    }
    
    
    func buttonPressed_Settings () {
        let universeMove = SKAction.moveToY(size.height, duration: transitionDuration)
        universeMove.timingMode = SKActionTimingMode.EaseInEaseOut
        let settingsMove = SKAction.moveToY(size.height, duration: transitionDuration)
        settingsMove.timingMode = SKActionTimingMode.EaseInEaseOut
        
        MainScreen.runAction(settingsMove)
        Menu_Universe.runAction(universeMove)
    }
    
    
    func buttonPressed_SettingsBack () {
        let backToMain = SKAction.moveToY(0.0, duration: transitionDuration)
        backToMain.timingMode = SKActionTimingMode.EaseInEaseOut
        let universeMove = SKAction.moveToY(size.height/2, duration: transitionDuration)
        universeMove.timingMode = SKActionTimingMode.EaseInEaseOut
        
        MainScreen.runAction(backToMain)
        Menu_Universe.runAction(universeMove)
    }
    
    func buttonPressed_SendFeedback () {
        let email = "asteroidadventure@gmail.com"
        let url = NSURL(string: "mailto:\(email)")
        UIApplication.sharedApplication().openURL(url!)
    }
    
}


//
//  GameScene.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 23.02.16.
//  Copyright (c) 2016 Marius Montebaur. All rights reserved.
//

/*

Komplettes Spiel für iPhone 4s anpassen

Feuer-Atlas bekommt gleiche Pixelbreite wie Raketen
ODER:
Glas des Banners und Raketen teilen

*/

/*
Position auf Z-Achse
- Buttons, Impressum: 2.0
- Asteroid, Banner: 1.0
- Flammen: 0.9
- Hintergrund: 0.0

*/


import SpriteKit
import Foundation




class PreferencesEntry_Checkbox: SKSpriteNode {
    
    private var checkBoxEnabled : Bool = false
    private var pref_Key : String = "default"
    private var pref_VisibleTitle : String = ""
    
    private let Titlelabel = SKLabelNode(fontNamed: "Arial-MT")
    private let Explainlabel = SKLabelNode(fontNamed: "Arial-MT")
    
    private let CheckBox = SKSpriteNode()
    private let InfoBox = SKSpriteNode(imageNamed: "Menu_Pref_Info_v1")
    
    private let LeftBorder = SKSpriteNode(imageNamed: "Menu_Pref_Border_v1")
    private let RightBorder = SKSpriteNode(imageNamed: "Menu_Pref_Border_v1")
    
    private var BordersExtendet : Bool = false
    
    private let background_alpha : CGFloat = 0.1
    private let child_alpha : CGFloat = 10 //child_alpha * background_alpha = 1
    
    private var enableExpl : Bool = true
    
    
    init(dict_pref_key: String, hasExplanation: Bool) {
        enableExpl = hasExplanation
        //checkbox, secure, range
        
        let texture = SKTexture(imageNamed: "Menu_Pref_Border_v1")
        super.init(texture: texture, color: UIColor.blackColor(), size: texture.size())
        self.alpha = background_alpha
        
        self.pref_Key = dict_pref_key
        self.checkBoxEnabled = getBoolOption(pref_Key)
        
       
        self.intiTitlelabel()
        self.initCheckbox()
        self.initBorders()
        self.initInfobox()
        
        self.userInteractionEnabled = true
        self.zPosition = 2.0
        
    }
    

    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initBorders() {
        
        LeftBorder.anchorPoint = CGPointMake(0, 0.5)
        LeftBorder.size.width = 5
        LeftBorder.position = CGPoint(x: -self.size.width/2, y: 0)
        LeftBorder.zPosition = 0.2
        LeftBorder.alpha = child_alpha
        self.addChild(LeftBorder)
        
        RightBorder.anchorPoint = CGPointMake(1, 0.5)
        RightBorder.size.width = 5
        RightBorder.position = CGPoint(x: self.size.width/2, y: 0)
        RightBorder.zPosition = 0.2
        RightBorder.alpha = child_alpha
        self.addChild(RightBorder)
        
        
    }
    
    func initCheckbox() {
        let checkbox_texture = SKTexture(imageNamed: "Menu_Checkbox_"+String(checkBoxEnabled)+"_v1")
        CheckBox.texture = checkbox_texture
        CheckBox.size = checkbox_texture.size()
        CheckBox.position = CGPoint(x: -self.size.width/2+CheckBox.size.width, y: 0)
        CheckBox.zPosition = 0.1
        CheckBox.color = UIColor.blackColor()
        CheckBox.alpha = child_alpha
        self.addChild(CheckBox)
        
    }
    
    func initInfobox() {
        
        if enableExpl {
            InfoBox.position = CGPoint(x: self.size.width/2-InfoBox.size.width, y: 0)
            InfoBox.color = UIColor.blackColor()
            InfoBox.alpha = child_alpha
            InfoBox.zPosition = 0.1
            self.addChild(InfoBox)
            initExplainlabel()
        }
        
    }
    
    func initExplainlabel() {
        
        Explainlabel.zPosition = 0.3
        Explainlabel.text = ExplainDict[self.pref_Key]
        Explainlabel.fontSize = 20
        Explainlabel.fontColor = UIColor.blackColor()
        Explainlabel.position = CGPoint(x: 0, y: 0)
        Explainlabel.horizontalAlignmentMode = .Center
        Explainlabel.verticalAlignmentMode = .Center
        Explainlabel.alpha = child_alpha*0.8
        Explainlabel.hidden = true
        self.addChild(Explainlabel)
        
    }
    
    func intiTitlelabel() {
        
        for i in pref_Key.characters {
            if i != "_" {
                pref_VisibleTitle += String(i)
            } else {
                pref_VisibleTitle += " "
            }
        }
        
        Titlelabel.zPosition = 0.1
        Titlelabel.text = pref_VisibleTitle
        Titlelabel.fontSize = 25
        Titlelabel.fontColor = UIColor.whiteColor()
        Titlelabel.position = CGPoint(x: 0, y: 0)
        Titlelabel.horizontalAlignmentMode = .Center
        Titlelabel.verticalAlignmentMode = .Center
        Titlelabel.alpha = child_alpha
        self.addChild(Titlelabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            if BordersExtendet {
                
                
                
            } else {
                
                if InfoBox.containsPoint(location) {
                    InfoBox.colorBlendFactor = 0.4
                } else {
                    CheckBox.colorBlendFactor = 0.4
                }
                
            }
        }
    }
    
    func showExplainLabel () {
        if enableExpl {
            BordersExtendet = true
            let newSize = self.size.width/2
            
            let Resize = SKAction.resizeToWidth(newSize, duration: 0.25)
            
            LeftBorder.runAction(Resize)
            RightBorder.runAction(Resize)
            
            Explainlabel.runAction(SKAction.sequence([SKAction.waitForDuration(0.3), SKAction.runBlock({
                if self.LeftBorder.size.width == newSize {
                    self.Explainlabel.hidden = false
                }
            })]))
        }
    }
    
    func hideExplainLabel () {
        BordersExtendet = false
        
        Explainlabel.hidden = true
        
        let Resize = SKAction.resizeToWidth(5, duration: 0.25)
        
        LeftBorder.runAction(Resize)
        RightBorder.runAction(Resize)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        CheckBox.colorBlendFactor = 0.0
        InfoBox.colorBlendFactor = 0.0
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            if BordersExtendet {
               
                hideExplainLabel()
                
            } else {
                
                if InfoBox.containsPoint(location) {
                    
                    showExplainLabel()
                    
                } else {
                    
                    checkBoxEnabled = !checkBoxEnabled
                    print(pref_VisibleTitle, ": ", checkBoxEnabled, " saved")
                    setBoolOption(pref_Key, value: checkBoxEnabled)
                    updateTexture()
                }
            }
            
        
            
        }
    }
    
    func updateTexture () {
        CheckBox.texture = SKTexture(imageNamed: "Menu_Checkbox_"+String(checkBoxEnabled)+"_v1")
    }
    
    
}



class GameMenu: SKScene {
    
    var ImpressumVisible : Bool = false
    var PreferencesVisible : Bool = false
    
    var BannerIntro = true
    var BannerMovement_X_Active : Bool = true
    var BannerMovement_Y_Active : Bool = true
    var BannerCenterPoint : CGPoint = CGPoint(x: 0, y: 0)
    var BannerCage_X : CGFloat = 0
    var BannerCage_Y : CGFloat = 0
    let Banneranimationtime : Double = 4
    
    var fireRight : SKSpriteNode!
    var fireLeft : SKSpriteNode!
    var fireCycleFrames : [SKTexture]!
    
    
    let MainScreen = SKSpriteNode()
    let ImpressumScreen = SKSpriteNode()
    let PreferencesScreen = SKSpriteNode()
    
    let Menu_Universe = SKSpriteNode(imageNamed: "Menu_Universum_v3")
    let Menu_Asteroid = SKSpriteNode(imageNamed: "Menu_Asteroid_v4")
    let Menu_Banner = SKSpriteNode(imageNamed: "Menu_Banner_v3")
    let Menu_Music_Button = SKSpriteNode(imageNamed: "Menu_Music_En_Button")
    let Menu_Sound_Button = SKSpriteNode(imageNamed: "Menu_Sound_En_Button")
    let Menu_About_Button = SKSpriteNode(imageNamed: "Menu_About_Button")
    let Menu_Play_Button = SKSpriteNode(imageNamed: "Menu_Play_Button_v2")
    let Menu_Preferences_Button = SKSpriteNode(imageNamed: "Menu_About_Button")

    let Impressum_Text = SKSpriteNode(imageNamed: "Menu_Impressum_Text")

    let PrefEnt_VerCon = PreferencesEntry_Checkbox(dict_pref_key: "vertical_control", hasExplanation: true)
    let PrefEnt_InvCon = PreferencesEntry_Checkbox(dict_pref_key: "invert_controls", hasExplanation: true)
    let PrefEnt_ProCon = PreferencesEntry_Checkbox(dict_pref_key: "pro_controls", hasExplanation: true)
    let PrefEnt_ShwTut = PreferencesEntry_Checkbox(dict_pref_key: "show_tutorial", hasExplanation: true)
    
    
    override func didMoveToView(view: SKView) {
        
        calcScaleMode()
        
        addChild(MainScreen)
        
        Menu_Universe.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(Menu_Universe)
        
        Menu_setup()
        Impressum_setup()
        Preferences_setup()
        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        FlyBanner()
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
        if ImpressumVisible == true {
            
        } else {
            
            for touch in touches {
                let location = touch.locationInNode(self)
                
                if Menu_About_Button.containsPoint(location) {
                    Menu_About_Button.colorBlendFactor = 0.4
                }
                
                if Menu_Preferences_Button.containsPoint(location) {
                    Menu_Preferences_Button.colorBlendFactor = 0.4
                }
                
                if Menu_Music_Button.containsPoint(location) {
                    Menu_Music_Button.colorBlendFactor = 0.4
                }
                
                if Menu_Sound_Button.containsPoint(location) {
                    Menu_Sound_Button.colorBlendFactor = 0.4
                }
                
                if Menu_Play_Button.containsPoint(location) {
                    Menu_Play_Button.colorBlendFactor = 0.4
                }
            }
        }
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let transitionDuration : Double = 0.75
        
        for touch in touches {
            let location = touch.locationInNode(self)
        
            if ImpressumVisible == true {
                //Impressum eingeblendet
                
                MainScreen.runAction(SKAction.moveToY(0.0, duration: transitionDuration))
                Menu_Universe.runAction(SKAction.moveToY(size.height/2, duration: transitionDuration))
                
                ImpressumVisible = false
                
            } else if PreferencesVisible == true {
                //Einstellungen eingeblendet
                
                if location.x < size.width/5 {
                    MainScreen.runAction(SKAction.moveToY(0.0, duration: transitionDuration))
                    Menu_Universe.runAction(SKAction.moveToY(size.height/2, duration: transitionDuration))
                
                    PreferencesVisible = false
                }
                    
            } else {
        
                if Menu_About_Button.containsPoint(location) {
    
                    MainScreen.runAction(SKAction.moveToY(-size.height, duration: transitionDuration))
                    Menu_Universe.runAction(SKAction.moveToY(0, duration: transitionDuration))
                    
                    ImpressumVisible = true
                } else
                
                if Menu_Preferences_Button.containsPoint(location) {
                    
                    MainScreen.runAction(SKAction.moveToY(size.height, duration: transitionDuration))
                    Menu_Universe.runAction(SKAction.moveToY(size.height, duration: transitionDuration))
                    
                    PreferencesVisible = true
                } else
                
                if Menu_Music_Button.containsPoint(location) {
                    if MusicEnabled == true {
                        Menu_Music_Button.texture = SKTexture(imageNamed: "Menu_Music_Dis_Button")
                        MusicEnabled = false
                    } else {
                        Menu_Music_Button.texture = SKTexture(imageNamed: "Menu_Music_En_Button")
                        MusicEnabled = true
                    }
                } else
                
                if Menu_Sound_Button.containsPoint(location) {
                    if SoundEnabled == true {
                        Menu_Sound_Button.texture = SKTexture(imageNamed: "Menu_Sound_Dis_Button")
                        SoundEnabled = false
                    } else {
                        Menu_Sound_Button.texture = SKTexture(imageNamed: "Menu_Sound_En_Button")
                        SoundEnabled = true
                    }
                } else
                
                
                if Menu_Play_Button.containsPoint(location) {
                  
                    runAction(SKAction.sequence([
                        SKAction.runBlock() {
                            let reveal = SKTransition.fadeWithColor(UIColor.whiteColor(), duration: 1.5)
                            let scene = GameArea(size: self.size)
                            self.view?.presentScene(scene, transition:reveal)
                        }
                        ]))
                }
            }
            
        }
        
        Menu_About_Button.colorBlendFactor = 0.0
        Menu_Play_Button.colorBlendFactor = 0.0
        Menu_Sound_Button.colorBlendFactor = 0.0
        Menu_Music_Button.colorBlendFactor = 0.0
        Menu_Preferences_Button.colorBlendFactor = 0.0
        
        
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
            
            let move_Y_action = SKAction.moveToY(Menu_Banner.position.y + MoveDistanceY , duration: Banneranimationtime)
            move_Y_action.timingMode = SKActionTimingMode.EaseInEaseOut
            Menu_Banner.runAction(SKAction.sequence([move_Y_action, SKAction.runBlock({self.BannerMovement_Y_Active = false})]))
            
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
    
        //Buttons hinzufügen
        Menu_Music_Button.position = CGPoint(x: 0.084*size.width, y: 0.027*size.width)
        Menu_Music_Button.setScale(CGFloat(MainScreenScale))
        Menu_Music_Button.alpha = 0.0
        Menu_Music_Button.zPosition = 2.0
        Menu_Music_Button.color = UIColor.blackColor()
        MainScreen.addChild(Menu_Music_Button)
        
        Menu_Sound_Button.position = CGPoint(x: 0.246*size.width, y: 0.027*size.width)
        Menu_Sound_Button.setScale(CGFloat(MainScreenScale))
        Menu_Sound_Button.alpha = 0.0
        Menu_Sound_Button.zPosition = 2.0
        Menu_Sound_Button.color = UIColor.blackColor()
        MainScreen.addChild(Menu_Sound_Button)
        
        Menu_About_Button.position = CGPoint(x: 0.408*size.width, y: 0.027*size.width)
        Menu_About_Button.setScale(CGFloat(MainScreenScale))
        Menu_About_Button.alpha = 0.0
        Menu_About_Button.zPosition = 2.0
        Menu_About_Button.color = UIColor.blackColor()
        MainScreen.addChild(Menu_About_Button)
        
        Menu_Preferences_Button.position = CGPoint(x: size.width - 0.084*size.width, y: 0.027*size.width)
        Menu_Preferences_Button.setScale(CGFloat(MainScreenScale))
        Menu_Preferences_Button.alpha = 0.0
        Menu_Preferences_Button.zPosition = 2.0
        Menu_Preferences_Button.color = UIColor.blackColor()
        MainScreen.addChild(Menu_Preferences_Button)
        
        //Asteroiden hinzufügen
        Menu_Asteroid.position = CGPoint(x: size.width*(3/4), y: size.height/2)
        Menu_Asteroid.setScale(CGFloat(MainScreenScale))
        Menu_Asteroid.zPosition = 1.0
        MainScreen.addChild(Menu_Asteroid)
        Menu_Asteroid.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(1.0, duration: 10.0)))
        
        
        Menu_Play_Button.position = CGPoint(x: 0.246*size.width, y: size.height/3)
        Menu_Play_Button.setScale(CGFloat(MainScreenScale))
        Menu_Play_Button.alpha = 0.0
        Menu_Play_Button.zPosition = 2.0
        Menu_Play_Button.color = UIColor.blackColor()
        MainScreen.addChild(Menu_Play_Button)
        
        let ButtonsEinblenden = SKAction.fadeInWithDuration(1.0)
        
        Menu_Music_Button.runAction(SKAction.sequence([SKAction.waitForDuration(3.0), ButtonsEinblenden]))
        Menu_Sound_Button.runAction(SKAction.sequence([SKAction.waitForDuration(3.0), ButtonsEinblenden]))
        Menu_About_Button.runAction(SKAction.sequence([SKAction.waitForDuration(3.0), ButtonsEinblenden]))
        Menu_Play_Button.runAction(SKAction.sequence([SKAction.waitForDuration(3.0), ButtonsEinblenden]))
        Menu_Preferences_Button.runAction(SKAction.sequence([SKAction.waitForDuration(3.0), ButtonsEinblenden]))
        
        
        //Feueranimation
        let fireAnimationAtlas = SKTextureAtlas(named: "menu_feuer")
        var fireFrames = [SKTexture]()
        let mengeBilder = fireAnimationAtlas.textureNames.count
        for i in 1...mengeBilder/2 {
            let fireTextureName = "menu_feuer\(i)"
            fireFrames.append(fireAnimationAtlas.textureNamed(fireTextureName))
        }
        fireCycleFrames = fireFrames
        
        let ersterFrame = fireCycleFrames[0]
        fireRight = SKSpriteNode(texture: ersterFrame)
        fireLeft = SKSpriteNode(texture: ersterFrame)
        fireLeft.zPosition = 0.9
        fireRight.zPosition = 0.9
        
        //Banner hinzufügen
        Menu_Banner.setScale(CGFloat(MainScreenScale))
        Menu_Banner.position = CGPoint(x: 200, y: -200)
        BannerCenterPoint = CGPoint(x: size.width*(3/10), y: size.height*(6.2/8))
        Menu_Banner.zPosition = 1.0
        Menu_Banner.zRotation = -0.3
        MainScreen.addChild(Menu_Banner)
        BannerCage_X = (BannerCenterPoint.x - Menu_Banner.size.width/2)*(4.6/6)
        BannerCage_Y = ((size.height - BannerCenterPoint.y) - Menu_Banner.size.height/2)/2
        
        fireLeft.size.width = 20.0
        fireRight.anchorPoint = CGPointMake(0.5, 1.0)
        fireLeft.anchorPoint = CGPointMake(0.5, 1.0)
        fireRight.position = CGPoint(x: (Menu_Banner.size.width/2 - fireRight.size.width/2)/MainScreenScale, y: (-Menu_Banner.size.height/2)/MainScreenScale)
        fireLeft.position = CGPoint(x: -(Menu_Banner.size.width/2 - fireRight.size.width/2)/MainScreenScale, y: (-Menu_Banner.size.height/2)/MainScreenScale)
        
        
        Menu_Banner.addChild(fireRight)
        Menu_Banner.addChild(fireLeft)
        burningFire()
        
        let BannerWait = SKAction.waitForDuration(0.0)
        let BannerMoveIn = SKAction.group([
            SKAction.moveTo(BannerCenterPoint, duration: 3.0),
            SKAction.rotateToAngle(0, duration: 3.0)
            ])
        BannerMoveIn.timingMode = SKActionTimingMode.EaseOut
        Menu_Banner.runAction(SKAction.sequence([BannerWait, BannerMoveIn, SKAction.runBlock({
            self.BannerMovement_Y_Active = false}),
            SKAction.waitForDuration(0.5),
            SKAction.runBlock({
                self.BannerMovement_X_Active = false})
            ]))
        

        
    }
    
    
    func Impressum_setup () {
        
        ImpressumScreen.position = CGPoint(x: 0, y: size.height)
        MainScreen.addChild(ImpressumScreen)
        
        
        Impressum_Text.setScale(CGFloat(MainScreenScale))
        Impressum_Text.position = CGPoint(x: size.width/2, y: size.height/2)
        Impressum_Text.zPosition = 2.0
        ImpressumScreen.addChild(Impressum_Text)
        
    }
    
    
    func Preferences_setup () {
        
        let ent_spacer = PrefEnt_InvCon.size.height*0.25
        let ent_half = PrefEnt_InvCon.size.height/2
        let ent_self = PrefEnt_InvCon.size.height
        
        PreferencesScreen.position = CGPoint(x: 0, y: -size.height)
        MainScreen.addChild(PreferencesScreen)
        
        let pos1 = CGPoint(x: size.width/2, y: size.height-ent_half-ent_spacer)
        let pos2 = CGPoint(x: size.width/2, y: size.height-ent_half-2*ent_spacer-ent_self)
        let pos3 = CGPoint(x: size.width/2, y: size.height-ent_half-3*ent_spacer-2*ent_self)
        let pos4 = CGPoint(x: size.width/2, y: size.height-ent_half-4*ent_spacer-3*ent_self)
        
        
        PrefEnt_InvCon.position = pos3
        PreferencesScreen.addChild(PrefEnt_InvCon)
        
        PrefEnt_VerCon.position = pos2
        PreferencesScreen.addChild(PrefEnt_VerCon)
        
        PrefEnt_ProCon.position = pos1
        PreferencesScreen.addChild(PrefEnt_ProCon)
        
        PrefEnt_ShwTut.position = pos4
        PreferencesScreen.addChild(PrefEnt_ShwTut)
        
        
        
    }

    
    func burningFire() {
        fireRight.runAction(SKAction.repeatActionForever(
            SKAction.animateWithTextures(fireCycleFrames,
                timePerFrame: 0.06,
                resize: false,
                restore: true)))
        
        fireLeft.runAction(SKAction.repeatActionForever(
            SKAction.animateWithTextures(fireCycleFrames,
                timePerFrame: 0.05,
                resize: false,
                restore: true)))
    }
   
   
    
    func calcScaleMode () {
        
        var parentScreenWidth = 1334
        
        if UIScreen.mainScreen().scale == 3 {
            parentScreenWidth = 1472
        }
        
        MainScreenScale = CGFloat(Float(size.width*2) / Float(parentScreenWidth))
        
    }
    
    
}







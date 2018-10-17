//
//  PreferencesMenu.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 08.06.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation
import SpriteKit



class Preferences_Table: SKSpriteNode {
    
    private var entrys : [Preferences_Entry]
    
    init(title: String, shown_entrys: [Preferences_Entry]) {
        entrys = shown_entrys
        
        let texture = SKTexture(imageNamed: "Menu_Pref_Border_v1")
        super.init(texture: texture, color: UIColor.blackColor(), size: texture.size())
        //super.init(color: UIColor.blackColor(), size: CGSize(width: 0, height: 0))
        self.zPosition = 2.0
        self.size.width = (UIScreen.mainScreen().bounds.width/2)*0.95
        self.size.height = self.size.height*0.6
        self.anchorPoint = CGPointMake(0.5, 1)
        
        initTitle(title)
        initEntrys()
        
    }
    
    func initEntrys () {
        
        let distance = self.size.height*0.25
        
        var i : CGFloat = 0;
        for entry in entrys {
            
            entry.position.x = 0
            let dist1 = (2*i + 1)*entry.size.height/2
            let dist2 = self.size.height + distance*(2+i)
            entry.position.y = -(dist1+dist2)
            self.addChild(entry)
            i += 1;
        }
        
    }
    
    func initTitle (title: String) {
        
        let TitleLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        TitleLabel.zPosition = 0.1
        TitleLabel.text = title
        TitleLabel.fontColor = UIColor.blackColor()
        TitleLabel.fontSize = 20
        TitleLabel.position = CGPoint(x: 0, y: -self.size.height*0.55)
        TitleLabel.horizontalAlignmentMode = .Center
        TitleLabel.verticalAlignmentMode = .Center
        TitleLabel.alpha = 0.8
        self.addChild(TitleLabel)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//Hilft beim Debuggen
func definetlyNOTacompletelyUselessFunction (boolean: Bool) {
    print("I'm not useless, I'm speacial")
}





class Preferences_Entry: SKSpriteNode {
    
    private enum buttonState {
        case normal
        case info
        case range
    }
    
    private var checkBoxEnabled : Bool = false
    private var pref_Key : String = "default"
    private var pref_VisibleTitle : String = ""
    
    private let Titlelabel = SKLabelNode(fontNamed: "Arial-MT")
    
    private let CheckBox = SKSpriteNode()
    
    private let LeftBorder = SKSpriteNode(imageNamed: "Menu_Pref_Border_v1")
    private let RightBorder = SKSpriteNode(imageNamed: "Menu_Pref_Border_v1")
    
    private let background_alpha : CGFloat = 0.1
    private let child_alpha : CGFloat = 10 //child_alpha * background_alpha = 1
    
    private let heightMult : CGFloat = 0.8
    
    
    init(dict_pref_key: String) {
        
        let texture = SKTexture(imageNamed: "Menu_Pref_Border_v1")
        super.init(texture: texture, color: UIColor.blackColor(), size: texture.size())
        
        self.size.width = (UIScreen.mainScreen().bounds.width/2)*0.95
        self.size.height = self.size.height*heightMult
        self.alpha = background_alpha
        
        self.pref_Key = dict_pref_key
        
        checkBoxEnabled = getBoolOption(pref_Key)
        
        self.intiTitlelabel()
        self.initCheckbox()
        self.initBorders()
        
        self.userInteractionEnabled = true
        self.zPosition = 2.0
        
        self.updateTexture()
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initBorders() {
        
        LeftBorder.anchorPoint = CGPointMake(0, 0.5)
        LeftBorder.size.width = 4
        LeftBorder.size.height = self.size.height
        LeftBorder.position = CGPoint(x: -self.size.width/2, y: 0)
        LeftBorder.zPosition = 0.2
        LeftBorder.alpha = child_alpha
        self.addChild(LeftBorder)
        
        RightBorder.anchorPoint = CGPointMake(1, 0.5)
        RightBorder.size.width = 4
        RightBorder.size.height = self.size.height
        RightBorder.position = CGPoint(x: self.size.width/2, y: 0)
        RightBorder.zPosition = 0.2
        RightBorder.alpha = child_alpha
        self.addChild(RightBorder)
        
    }
    
    
    func initCheckbox() {
        
        let checkbox_texture = SKTexture(imageNamed: "Menu_Checkbox_"+String(checkBoxEnabled)+"_v1")
        CheckBox.texture = checkbox_texture
        CheckBox.size = checkbox_texture.size()
        CheckBox.setScale(heightMult)
        CheckBox.position = CGPoint(x: -self.size.width/2+CheckBox.size.width, y: 0)
        CheckBox.zPosition = 0.1
        CheckBox.color = UIColor.blackColor()
        CheckBox.alpha = child_alpha
        self.addChild(CheckBox)
    
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
        Titlelabel.fontSize = 20
        Titlelabel.fontColor = UIColor.whiteColor()
        Titlelabel.position = CGPoint(x: 0, y: 0)
        Titlelabel.horizontalAlignmentMode = .Center
        Titlelabel.verticalAlignmentMode = .Center
        Titlelabel.alpha = child_alpha
        self.addChild(Titlelabel)
    }
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        Titlelabel.alpha = child_alpha*0.6
        CheckBox.colorBlendFactor = 0.6
        
        if let sound = playSoundEffect(soundEffect_buttonKlick, looped: false) {
            self.addChild(sound)
        }
    }
    
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        CheckBox.colorBlendFactor = 0.0
        Titlelabel.alpha = child_alpha
        
        checkBoxEnabled = !checkBoxEnabled
        //print(pref_VisibleTitle, ": ", checkBoxEnabled, " saved")
        
        updateTexture()
        
        setBoolOption(pref_Key, value: checkBoxEnabled)
        
    }

    
    func updateTexture () {
        CheckBox.texture = SKTexture(imageNamed: "Menu_Checkbox_"+String(checkBoxEnabled)+"_v1")
    }
    

}



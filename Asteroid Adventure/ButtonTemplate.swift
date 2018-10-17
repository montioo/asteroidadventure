//
//  ButtonClass.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 10.06.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation
import SpriteKit



class Button: SKCropNode {
    
    private var Title = ""
    
    private let Background = SKSpriteNode(imageNamed: "Menu_Pref_Border_v1")
    
    private let Titlelabel = SKLabelNode(fontNamed: "Arial-BoldMT")
    
    private let LeftBorder = SKSpriteNode(imageNamed: "Menu_Pref_Border_v1")
    private let RightBorder = SKSpriteNode(imageNamed: "Menu_Pref_Border_v1")
    
    private let Maske = SKSpriteNode()
    
    private let background_alpha : CGFloat = 0.1
    private var child_alpha : CGFloat
    private let borderWidth : CGFloat = 4
    
    private var touchesEndedFunction : () -> ()
    
    private var buttonWidth : CGFloat
    private var buttonHeight : CGFloat
    
    private var cropSize : CGSize = CGSizeMake(0, 0)
    
    
    init(title: String, fontSize: CGFloat, height: CGFloat, width: CGFloat, function: () -> (), appearWithAnimation: Bool, boldFont: Bool) {
        
        if !boldFont {
            Titlelabel.fontName = "Arial-MT"
        }
        
        buttonWidth = width
        buttonHeight = height
        touchesEndedFunction = function
        child_alpha = 1/background_alpha
        Titlelabel.text = title
        Titlelabel.fontSize = fontSize
        
        super.init()
        
        initMask(!appearWithAnimation)
        initBackground()
        intiTitlelabel()
        initBorders()

        self.zPosition = 0.1
        
        
    }

    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initMask(showOnSpawn: Bool) {
        
        Maske.color = UIColor.blackColor()
        Maske.colorBlendFactor = 1.0
        
        if showOnSpawn {
            Maske.size = CGSizeMake(buttonWidth, buttonHeight)
            self.userInteractionEnabled = true
        } else {
            Maske.size = CGSizeMake(2*borderWidth, 0)
            self.userInteractionEnabled = false
        }
        
        self.maskNode = Maske
        
    }
    
    func animationAppear () {
        let xAnimationDuration : Double = 0.3
        
        let yAnimationDuration : Double = Double(buttonHeight/buttonWidth)*xAnimationDuration*2
        
        LeftBorder.position.x = -borderWidth
        RightBorder.position.x = +borderWidth
        
        Maske.runAction(SKAction.sequence([SKAction.resizeToHeight(buttonHeight, duration: yAnimationDuration), SKAction.resizeToWidth(buttonWidth, duration: xAnimationDuration)]))
        
        LeftBorder.runAction(SKAction.sequence([SKAction.waitForDuration(yAnimationDuration), SKAction.moveToX(-buttonWidth/2, duration: xAnimationDuration)]))
        RightBorder.runAction(SKAction.sequence([SKAction.waitForDuration(yAnimationDuration), SKAction.moveToX(buttonWidth/2, duration: xAnimationDuration)]))
        
        
        self.userInteractionEnabled = true
    }
    
    func animationDisappear () {
        let xAnimationDuration : Double = 0.3
        
        let yAnimationDuration : Double = Double(buttonHeight/buttonWidth)*xAnimationDuration*2
        
        LeftBorder.position.x = -buttonWidth/2
        RightBorder.position.x = +buttonWidth/2
        
        Maske.runAction(SKAction.sequence([SKAction.resizeToWidth(borderWidth*2, duration: xAnimationDuration), SKAction.resizeToHeight(0, duration: yAnimationDuration), SKAction.runBlock({self.userInteractionEnabled = false})]))
        
        LeftBorder.runAction(SKAction.moveToX(-borderWidth, duration: xAnimationDuration))
        RightBorder.runAction(SKAction.moveToX(borderWidth, duration: xAnimationDuration))
       
    }
    
    
    func initBackground() {
        Background.alpha = background_alpha
        Background.size.width = buttonWidth
        Background.size.height = buttonHeight
        Background.zPosition = 0.1
        self.addChild(Background)
    }
    
    
    func initBorders() {
        
        LeftBorder.anchorPoint = CGPointMake(0, 0.5)
        LeftBorder.size.width = borderWidth
        LeftBorder.size.height = Background.size.height
        LeftBorder.position = CGPoint(x: -Background.size.width/2, y: 0)
        LeftBorder.zPosition = 0.3
        LeftBorder.color = UIColor.blackColor()
        LeftBorder.alpha = child_alpha
        Background.addChild(LeftBorder)
        
        RightBorder.anchorPoint = CGPointMake(1, 0.5)
        RightBorder.size.width = borderWidth
        RightBorder.size.height = Background.size.height
        RightBorder.position = CGPoint(x: Background.size.width/2, y: 0)
        RightBorder.zPosition = 0.3
        RightBorder.color = UIColor.blackColor()
        RightBorder.alpha = child_alpha
        Background.addChild(RightBorder)
        
        
    }
    
    
    func intiTitlelabel() {
        
        Titlelabel.zPosition = 0.2
        Titlelabel.fontColor = UIColor.whiteColor()
        Titlelabel.color = UIColor.blackColor()
        Titlelabel.position = CGPoint(x: 0, y: -Titlelabel.fontSize/2.40)
        Titlelabel.horizontalAlignmentMode = .Center
        Titlelabel.verticalAlignmentMode = .Baseline
        Titlelabel.alpha = child_alpha
        Background.addChild(Titlelabel)
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        LeftBorder.colorBlendFactor = 0.55
        RightBorder.colorBlendFactor = 0.55
        Titlelabel.fontColor = UIColor.grayColor()
    }
    
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        LeftBorder.colorBlendFactor = 0.0
        RightBorder.colorBlendFactor = 0.0
        Titlelabel.fontColor = UIColor.whiteColor()
        
        for touch in touches {
            
            let location = touch.locationInNode(self)
            
            if locationIsInButton(location) {
                touchesEndedFunction()
            }
            
        }
    }
    
    
    func locationIsInButton (location: CGPoint) -> Bool {
        if (location.y < Background.size.height/2 && location.y > -Background.size.height/2 && location.x > -Background.size.width/2 && location.x < Background.size.width/2) {
            return true
        }
        return false
    }
    
    
    func getButtonWidth () -> CGFloat {
        return buttonWidth
    }
    
    
    func getButtonHeight () -> CGFloat {
        return buttonHeight
    }
    
    func getAnimationDuration () -> Double {
        let xAnimationDuration : Double = 0.3
        
        let yAnimationDuration : Double = Double(buttonHeight/buttonWidth)*xAnimationDuration*2
        
        return xAnimationDuration+yAnimationDuration
    }
}


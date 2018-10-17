//
//  TutorialSteps.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 28.08.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation
import SpriteKit


class stepOneClass : SKSpriteNode {
    
    private let arrowUp = SKSpriteNode(imageNamed: "Tutorial_Arrow")
    private let arrowDn = SKSpriteNode(imageNamed: "Tutorial_Arrow")
    
    private let arrowLowAlpha : CGFloat = 0.4
    
    private var reachedTop : Bool = false
    private var reachedBot : Bool = false
    
    private var viewHeight : CGFloat
    private var lastSpaceshipPosX : CGFloat = -1
    
    private var finishFunction : () -> ()
    
    private var transitionStarted : Bool = false
    
    init (gameViewHeight: CGFloat, gameViewWidth: CGFloat, endFunction: () -> ()) {
        
        viewHeight = gameViewHeight
        finishFunction = endFunction
        
        super.init(texture: nil, color: UIColor.whiteColor(), size: CGSizeMake(0, 0))
        
        arrowUp.anchorPoint = CGPointMake(1, 0.5)
        arrowUp.zRotation = CGFloat(-M_PI/2)
        arrowUp.position = CGPoint(x: gameViewWidth*0.9, y: gameViewHeight*0.52)
        arrowUp.alpha = 0.4
        self.addChild(arrowUp)
        
        arrowDn.anchorPoint = CGPointMake(1, 0.5)
        arrowDn.zRotation = CGFloat(M_PI/2)
        arrowDn.position = CGPoint(x: gameViewWidth*0.9, y: gameViewHeight*0.48)
        arrowDn.alpha = 0.4
        self.addChild(arrowDn)
        
        let controlText = SKLabelNode(fontNamed: "Arial-MT")
        controlText.fontSize = 20
        controlText.text = "roll your device to controll the spaceship"
        controlText.fontColor = whiteFont
        controlText.horizontalAlignmentMode = .Center
        controlText.verticalAlignmentMode = .Center
        controlText.position = CGPoint(x: gameViewWidth/2, y: gameViewHeight*0.9)
        self.addChild(controlText)
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    func deliverSpaceshipPos (yPos: CGFloat) {
        if lastSpaceshipPosX == -1 {
            lastSpaceshipPosX = yPos
        }
        
        if yPos >= lastSpaceshipPosX {
            setTopArrowAlpha(1)
            setBotArrowAlpha(arrowLowAlpha)
        } else {
            setBotArrowAlpha(1)
            setTopArrowAlpha(arrowLowAlpha)
        }
        
        if yPos > viewHeight*0.8 && !reachedTop {
            reachedTop = true
            arrowUp.runAction(SKAction.group([
                SKAction.fadeAlphaTo(0, duration: 0.3),
                SKAction.scaleTo(1.5, duration: 0.3)
            ]))
        }
        
        if yPos < viewHeight*0.2 && !reachedBot {
            reachedBot = true
            arrowDn.runAction(SKAction.group([
                SKAction.fadeAlphaTo(0, duration: 0.3),
                SKAction.scaleTo(1.5, duration: 0.3)
                ]))
        }
        
        if reachedBot && reachedTop && !transitionStarted {
            transitionStarted = true
            finishFunction()
        }
        lastSpaceshipPosX = yPos
    }
    
    func setTopArrowAlpha (alpha: CGFloat) {
        if !reachedTop {
            arrowUp.alpha = alpha
        }
    }
    
    func setBotArrowAlpha (alpha: CGFloat) {
        if !reachedBot {
            arrowDn.alpha = alpha
        }
    }
    
}




class stepTwoClass : SKSpriteNode {
    
    
    private let leftField = SKSpriteNode(imageNamed: "Tutorial_Touchborder")
    private let rightField = SKSpriteNode(imageNamed: "Tutorial_Touchborder")
    private let holdText = SKLabelNode(fontNamed: "Arial-BoldMT")
    
    private let leftTitle = SKLabelNode(fontNamed: "Arial-MT")
    
    private var leftFuncBegan : () -> ()
    private var leftFuncEnded : () -> ()
    private var rightFuncBegan : () -> ()
    private var rightFuncEnded : () -> ()
    
    private var finishFunc : () -> ()
    
    private var viewWidth : CGFloat
    private var viewHeight : CGFloat
    
    private var rightCount : Int = 0
    private var leftFieldFinished : Bool = false
    
    private var transitionStarted : Bool = false
    
    init (gameViewHeight: CGFloat, gameViewWidth: CGFloat, leftTouchBegan: () -> (), leftTouchEnded: () -> (), rightTouchBegan: () -> (), rightTouchEnded: () -> (), endFunction: () -> ()) {
        
        leftFuncBegan = leftTouchBegan
        leftFuncEnded = leftTouchEnded
        
        rightFuncBegan = rightTouchBegan
        rightFuncEnded = rightTouchEnded
        
        finishFunc = endFunction
        
        viewWidth = gameViewWidth
        viewHeight = gameViewHeight
        
        super.init(texture: nil, color: UIColor.whiteColor(), size: CGSize(width: 0, height: 0))
        
        self.userInteractionEnabled = true
        
        initLeftField()
        
        self.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if location.x < viewWidth/2 {
                leftField.alpha = 1
                leftField.removeActionForKey("colorUnblend")
                leftFuncBegan()
                touchesBegan_holdText()
                
            }
            
            if location.x > viewWidth/2 && leftFieldFinished {
                rightField.alpha = 1
                rightField.removeActionForKey("colorUnblend")
                rightFuncBegan()
                
                let Tap = SKSpriteNode(imageNamed: "Tutorial_Tap")
                Tap.position = location
                Tap.alpha = 0.8
                Tap.zPosition = 2.8
                Tap.setScale(0.1)
                self.addChild(Tap)
                Tap.runAction(SKAction.sequence([SKAction.group([SKAction.scaleTo(1, duration: 0.3), SKAction.fadeOutWithDuration(0.3)]), SKAction.removeFromParent()]))
            }
        }
        
        if rightCount >= 1 && !transitionStarted {
            transitionStarted = true
            leftFuncEnded()
            rightFuncEnded()
            finishFunc()
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if leftFieldFinished {
            rightField.runAction(SKAction.fadeAlphaTo(0.3, duration: 0.3), withKey: "colorUnblend")
            leftFuncEnded()
        } else {
            leftField.runAction(SKAction.fadeAlphaTo(0.3, duration: 0.3), withKey: "colorUnblend")
        }
        rightFuncEnded()
        touchesEnded_holdText()
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if location.x < viewWidth/2 {
                leftFuncEnded()
            }
            
            if location.x > viewWidth/2 && leftFieldFinished {
                rightCount += 1
            }
        }
    }
    
    private func touchesBegan_holdText () {
        
        if leftFieldFinished {
            return
        }
        
        holdText.removeActionForKey("minimize")
        if !leftFieldFinished {
            holdText.text = "HOLD!"
            holdText.runAction(SKAction.sequence([
                SKAction.scaleYTo(1, duration: 0.7),
                SKAction.runBlock({
                    self.holdText.text = "ACTIVE"
                    self.leftFieldFinished = true
                    self.initRightField()
                    self.leftField.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
                    self.leftTitle.runAction(SKAction.fadeAlphaTo(0, duration: 0.5))
                })])
                , withKey: "dynamic")
        }
    }
    
    
    private func touchesEnded_holdText () {
        holdText.text = "HOLD!"
        if leftFieldFinished {
            holdText.text = "ACTIVE"
        }
        holdText.removeActionForKey("dynamic")
        holdText.runAction(SKAction.scaleYTo(0, duration: 0.7), withKey: "minimize")

    }
    
    
    private func initLeftField () {
        leftField.position = CGPoint(x: viewWidth/4, y: viewHeight/2)
        leftField.alpha = 0.3
        leftField.zPosition = 6
        leftField.centerRect = CGRectMake(30/267, 30/323.5, 207/267, 263.5/323.5)
        leftField.xScale = (viewWidth/2)/leftField.size.width
        leftField.yScale = viewHeight/leftField.size.height
        self.addChild(leftField)
        
        leftTitle.text = "hold to activate your shield"
        leftTitle.color = UIColor.whiteColor()
        leftTitle.fontSize = 20
        if isIPhone4s {leftTitle.fontSize = 17}
        leftTitle.horizontalAlignmentMode = .Center
        leftTitle.verticalAlignmentMode = .Top
        leftTitle.position = CGPoint(x: leftField.position.x, y: viewHeight*0.9)
        self.addChild(leftTitle)
        
        holdText.color = whiteFont
        holdText.fontSize = 30
        holdText.text = "HOLD!"
        holdText.horizontalAlignmentMode = .Right
        holdText.verticalAlignmentMode = .Center
        holdText.position = CGPoint(x: viewWidth*0.45, y: viewHeight/2)
        holdText.yScale = 0
        self.addChild(holdText)
    }
    
    
    private func initRightField () {
        rightField.position = CGPoint(x: viewWidth - viewWidth/4, y: viewHeight/2)
        rightField.zPosition = 6
        rightField.centerRect = CGRectMake(30/267, 30/323.5, 207/267, 263.5/323.5)
        rightField.xScale = (viewWidth/2)/rightField.size.width
        rightField.yScale = viewHeight/rightField.size.height
        rightField.alpha = 0
        self.addChild(rightField)
        
        let Titel = SKLabelNode(fontNamed: "Arial-MT")
        
        Titel.text = "tap to shoot a laser"
        Titel.color = UIColor.whiteColor()
        Titel.fontSize = 20
        Titel.horizontalAlignmentMode = .Center
        Titel.verticalAlignmentMode = .Top
        Titel.position = CGPoint(x: rightField.position.x, y: viewHeight*0.9)
        Titel.alpha = 0
        self.addChild(Titel)
        
        rightField.runAction(SKAction.fadeAlphaTo(0.3, duration: 0.5))
        Titel.runAction(SKAction.fadeAlphaTo(1, duration: 0.5))
        
    }
    
}










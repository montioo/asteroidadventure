//
//  ProgressBarClass.swift
//  Animation Playground
//
//  Created by Marius Montebaur on 22.08.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation
import SpriteKit

class progressBarClass : SKSpriteNode {
    
    private let leftBorder = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: 0, height: 0))
    private let rightBorder = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: 0, height: 0))
    
    private let leftProgressBar = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(0, 0))
    private let rightProgressBar = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(0, 0))
    
    private var progressEmitter : SKEmitterNode? = nil
    private let progressCropNode = SKCropNode()
    
    private let titleNode = SKLabelNode(fontNamed: "Arial-MT")
    
    private var borderWidth : CGFloat = 2
    
    private var barWidth : CGFloat
    private var barHeight : CGFloat
    
    private var aktProgress : CGFloat = 30
    private var maxProgress : CGFloat = 100
    
    private var displayPercent : Bool = false
    
    private var progressWidth : CGFloat
    
    private var barTitle : String
    
    private var useTwoColors : Bool
    private var lowColor : UIColor
    private var highColor : UIColor
    private var limitValue : CGFloat
    private var limitRange : CGFloat
    
    
    init(title: String, width: CGFloat, height: CGFloat, startProgressInPercent: CGFloat) {
        
        useTwoColors = true
        barWidth = width
        barHeight = height
        barTitle = title
        progressWidth = barWidth - borderWidth*2
        
        aktProgress = startProgressInPercent
        
        lowColor = setRGBColor(red: 255, green: 0, blue: 0, alpha: 0.6)
        highColor = setRGBColor(red: 0, green: 120, blue: 255, alpha: 0.6)
        limitValue = 30
        limitRange = 20
        
        
        super.init(texture: nil, color: UIColor.whiteColor(), size: CGSize(width: 0, height: 0))
        
        limitProgress()
        
        initLabel()
        initBorders()
        initBars()
    }
    
    
    func activateEmitter (effectName: String) {
        initEmitter(effectName)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func initLabel () {
        
        titleNode.fontSize = 15
        titleNode.fontColor = UIColor.whiteColor()
        titleNode.verticalAlignmentMode = .Center
        titleNode.horizontalAlignmentMode = .Center
        titleNode.zPosition = 0.02
        titleNode.position = CGPoint(x: 0, y: 0)
        addChild(titleNode)
        
    }
    
    
    private func initBorders () {
        
        leftBorder.size.width = borderWidth
        leftBorder.size.height = barHeight
        leftBorder.anchorPoint = CGPointMake(0, 0.5)
        leftBorder.position = CGPoint(x: -barWidth/2, y: 0)
        self.addChild(leftBorder)
        
        rightBorder.size.width = borderWidth
        rightBorder.size.height = barHeight
        rightBorder.anchorPoint = CGPointMake(1, 0.5)
        rightBorder.position = CGPoint(x: barWidth/2, y: 0)
        self.addChild(rightBorder)
    }
    
    
    private func initBars () {
        
        leftProgressBar.anchorPoint = CGPointMake(0, 0.5)
        leftProgressBar.position = CGPoint(x: -progressWidth/2, y: 0)
        leftProgressBar.size.height = barHeight
        leftProgressBar.color = UIColor.blackColor()
        addChild(leftProgressBar)
        
        rightProgressBar.anchorPoint = CGPointMake(1, 0.5)
        rightProgressBar.position = CGPoint(x: progressWidth/2, y: 0)
        rightProgressBar.size.height = barHeight
        rightProgressBar.alpha = 0.1
        addChild(rightProgressBar)
        
        refreshStatus()
    }
    
    
    private func initEmitter (effectName: String) {
        progressEmitter = SKEmitterNode(fileNamed: effectName)!
        
        progressEmitter!.position = CGPoint(x: progressWidth/2, y: 0)
        progressEmitter!.zPosition = 0.01
        progressEmitter!.particleLifetime = barWidth / (progressEmitter!.particleSpeed - progressEmitter!.particleSpeedRange)
        progressEmitter!.advanceSimulationTime(Double(progressEmitter!.particleLifetime))
        progressEmitter!.particlePositionRange.dy = barHeight
        progressCropNode.maskNode = leftProgressBar
        
        progressCropNode.position.x = leftProgressBar.position.x+progressWidth/2
        progressCropNode.zPosition = 0.01
        addChild(progressCropNode)
        progressCropNode.addChild(progressEmitter!)
    }
    
    
    private func refreshStatus () {
        leftProgressBar.removeActionForKey("BarResize")
        leftProgressBar.runAction(SKAction.resizeToWidth((aktProgress/maxProgress) * progressWidth, duration: 0.3), withKey: "BarResize")
        
        rightProgressBar.removeActionForKey("BarResize")
        rightProgressBar.runAction(SKAction.resizeToWidth(((maxProgress-aktProgress)/maxProgress) * progressWidth, duration: 0.3), withKey: "BarResize")
        
        refreshTitle()
        leftProgressBar.color = calcLeftBarColor()
    }
    
    
    private func calcLeftBarColor () -> UIColor {
        
        if useTwoColors {
            
            if aktProgress < limitValue-(limitRange/2) {
                return lowColor
            }
            
            if aktProgress > limitValue+(limitRange/2) {
                return highColor
            }
            
            let percentValueInLimitZone = (aktProgress - limitValue + (limitRange/2))/limitRange
            
            var redLow : CGFloat = 0
            var greenLow : CGFloat = 0
            var blueLow : CGFloat = 0
            var alphaLow : CGFloat = 0
            lowColor.getRed(&redLow, green: &greenLow, blue: &blueLow, alpha: &alphaLow)
            
            var redHigh : CGFloat = 0
            var greenHigh : CGFloat = 0
            var blueHigh : CGFloat = 0
            var alphaHigh : CGFloat = 0
            highColor.getRed(&redHigh, green: &greenHigh, blue: &blueHigh, alpha: &alphaHigh)
            
            return UIColor.init(
                red: redLow + (redHigh - redLow)*percentValueInLimitZone,
                green: greenLow + (greenHigh - greenLow)*percentValueInLimitZone,
                blue: blueLow + (blueHigh - blueLow)*percentValueInLimitZone,
                alpha: alphaLow + (alphaHigh - alphaLow)*percentValueInLimitZone)
        }
        
        return lowColor
    }
    
    func setMaxProgress (value: CGFloat) {
        maxProgress = value
    }
    
    func setLowerColor (color: UIColor) {
        lowColor = color
    }
    
    func setHigherColor (color: UIColor) {
        highColor = color
    }
    
    func enableTwoColors (enabled: Bool) {
        useTwoColors = enabled
    }
    
    func setColorChangeLimit (progressLimitValue progressLimitValue: CGFloat, progressAbsoluteRange: CGFloat) {
        limitValue = progressLimitValue
        limitRange = progressAbsoluteRange
    }
    
    
    func setProgressInPercent (value: CGFloat) {
        aktProgress = value
        limitProgress()
        refreshStatus()
    }
    
    func addProgressInPercent (value: CGFloat) {
        aktProgress += value
        limitProgress()
        refreshStatus()
    }
    
    func setProgressInPercentInstant (value: CGFloat) {
        aktProgress = value
        limitProgress()
        
        leftProgressBar.size.width = (aktProgress/maxProgress) * progressWidth
        
        rightProgressBar.size.width = ((maxProgress-aktProgress)/maxProgress) * progressWidth
        
        refreshTitle()
        leftProgressBar.color = calcLeftBarColor()
    }
    
    private func refreshTitle () {
        if displayPercent {
            titleNode.text = barTitle + ": " + String(CGFloat(Int((aktProgress/maxProgress)*1000))/10) + "%"
        } else {
            titleNode.text = barTitle + ": " + String(CGFloat(Int(aktProgress*10))/10) + " / " + String(CGFloat(Int(maxProgress*10))/10)
        }
    }
    
    func barIsFull () -> Bool {
        if aktProgress == maxProgress {
            return true
        }
        return false
    }
    
    func barIsEmpty () -> Bool {
        if aktProgress == 0 {
            return true
        }
        return false
    }
    
    func getProgress () -> CGFloat {
        return aktProgress
    }
    
    private func limitProgress () {
        if aktProgress > maxProgress {
            aktProgress = maxProgress
        }
        if aktProgress < 0 {
            aktProgress = 0
        }
    }
    
    func showPercent () {
        displayPercent = true
    }
    
    func showValues () {
        displayPercent = false
    }
    
    func getBarHeight () -> CGFloat {
        return barHeight
    }
    
    func getBarWidth () -> CGFloat {
        return barWidth
    }
    
}



//
//  progressBarClass_Test.swift
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
    
    private let progressEmitter : SKEmitterNode
    private let progressCropNode = SKCropNode()
    
    private let titleNode = SKLabelNode(fontNamed: "Arial-MT")
    
    private var borderWidth : CGFloat = 4
    
    private var barWidth : CGFloat
    private var barHeight : CGFloat
    
    private var progress : CGFloat = 30
    
    private var progressWidth : CGFloat
    
    private var barTitle : String
    
    private var useTwoColors : Bool
    private var lowColor : UIColor
    private var highColor : UIColor
    private var limitValue : CGFloat
    private var limitRange : CGFloat
    
    
    init(title: String, width: CGFloat, height: CGFloat, effectName: String) {
        
        useTwoColors = true
        barWidth = width
        barHeight = height
        barTitle = title
        progressWidth = barWidth - borderWidth*2
        
        progressEmitter = SKEmitterNode(fileNamed: effectName)!
        
        lowColor = setRGBColor(red: 255, green: 0, blue: 0, alpha: 0.6)
        highColor = setRGBColor(red: 0, green: 120, blue: 255, alpha: 0.6)
        limitValue = 25
        limitRange = 20
        
        
        super.init(texture: nil, color: UIColor.whiteColor(), size: CGSize(width: 0, height: 0))
        
        initLabel()
        initBorders()
        initBars()
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initLabel () {
        
        titleNode.fontSize = 20
        titleNode.fontColor = UIColor.whiteColor()
        titleNode.verticalAlignmentMode = .Center
        titleNode.horizontalAlignmentMode = .Center
        titleNode.zPosition = 0.02
        titleNode.position = CGPoint(x: 0, y: 0)
        addChild(titleNode)
    
    }
    
    
    func initBorders () {
        
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
    
    
    func initBars () {
        
        leftProgressBar.anchorPoint = CGPointMake(0, 0.5)
        leftProgressBar.position = CGPoint(x: -progressWidth/2, y: 0)
        leftProgressBar.size.height = barHeight
        leftProgressBar.color = UIColor.blackColor()
        addChild(leftProgressBar)
        
        progressEmitter.position = CGPoint(x: progressWidth/2, y: 0)
        progressEmitter.zPosition = 0.01
        progressEmitter.particleLifetime = barWidth / (progressEmitter.particleSpeed - progressEmitter.particleSpeedRange)
        progressEmitter.advanceSimulationTime(Double(progressEmitter.particleLifetime))
        progressEmitter.particlePositionRange.dy = barHeight
        progressCropNode.maskNode = leftProgressBar
        
        progressCropNode.position.x = leftProgressBar.position.x+progressWidth/2
        progressCropNode.zPosition = 0.01
        addChild(progressCropNode)
        progressCropNode.addChild(progressEmitter)
        
        rightProgressBar.anchorPoint = CGPointMake(1, 0.5)
        rightProgressBar.position = CGPoint(x: progressWidth/2, y: 0)
        rightProgressBar.size.height = barHeight
        rightProgressBar.alpha = 0.1
        addChild(rightProgressBar)
        
        refreshStatus()
    }
    
    
    func refreshStatus () {
        leftProgressBar.size.width = (progress/100) * progressWidth
        rightProgressBar.size.width = ((100-progress)/100) * progressWidth
        titleNode.text = barTitle + ": " + String(Int(progress)) + "%"
        leftProgressBar.color = calcLeftBarColor()
    }
    
    
    private func calcLeftBarColor () -> UIColor {
        
        if useTwoColors {
        
            if progress < limitValue-(limitRange/2) {
                return lowColor
            }
            
            if progress > limitValue+(limitRange/2) {
                return highColor
            }
            
            let percentValueInLimitZone = (progress - limitValue + (limitRange/2))/limitRange
            
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
    
    
    func setLowerColor (color: UIColor) {
        lowColor = color
    }
    
    func setHighColor (color: UIColor) {
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
        progress = value
        limitProgress()
        refreshStatus()
    }
    
    func addProgressInPercent (value: CGFloat) {
        progress += value
        limitProgress()
        refreshStatus()
    }
    
    func limitProgress () {
        if progress > 100 {
            progress = 100
        }
        if progress < 0 {
            progress = 0
        }
    }
    
    func getBarHeight () -> CGFloat {
        return barHeight
    }
    
    func getBarWidth () -> CGFloat {
        return barWidth
    }
    
}



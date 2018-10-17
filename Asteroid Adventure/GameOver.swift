//
//  GameOver.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 15.06.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

 

import Foundation
import SpriteKit


class movableLine: SKSpriteNode {
    var targetPosition : CGPoint = CGPoint(x: 0, y: 0)
}


class GameOver: SKScene {
    
   
    let StarNode = SKSpriteNode()
    let ContentNode = SKSpriteNode()
    let StatNode = SKSpriteNode()
    
    let starSpawnNode = SKEmitterNode(fileNamed: "stars_gameover")
    let highscoreCarrierNode = SKSpriteNode()
    
    
    override func didMoveToView(view: SKView) {
       
        StarNode.zPosition = 0.1
        addChild(StarNode)
        
        ContentNode.zPosition = 0.5
        addChild(ContentNode);
        
        StatNode.zPosition = 1
        addChild(StatNode)
        
        let Background = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: size.width, height: size.height))
        Background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(Background)
        
        let starHole = SKSpriteNode(imageNamed: "GameOver_Starhole")
        starHole.position = CGPoint(x: size.width/2, y: size.height/2)
        starHole.zPosition = 0.1
        StarNode.addChild(starHole)
        
        starSpawnNode?.position = CGPoint(x: size.width/2, y: size.height/2)
        starSpawnNode?.zPosition = 0.05
        StarNode.addChild(starSpawnNode!)
        starSpawnNode?.advanceSimulationTime(14)
        
        animationIntro()
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
    }
    
    
    func animationIntro () {
    
        let title_Game = SKLabelNode(fontNamed: "Arial-BoldMT")
        let title_Over = SKLabelNode(fontNamed: "Arial-BoldMT")
        
        let title_GameOver = [title_Game, title_Over]
        
        title_Game.horizontalAlignmentMode = .Right
        title_Game.text = "GAME"
        
        title_Over.horizontalAlignmentMode = .Left
        title_Over.text = "OVER"
        
        for titles in title_GameOver {
            titles.verticalAlignmentMode = .Top
            titles.fontSize = 60
            titles.setScale(0)
            titles.fontColor = whiteFont
            titles.zPosition = 3
            titles.position = CGPoint(x: size.width/2, y: size.height*0.6)
            ContentNode.addChild(titles)
        }
        
        //0.18
        let Button_BackToMenu = ButtonClass(title: "main menu", fontSize: 20, height: size.height*0.08, width: size.width*0.22, function: buttonPressed_backToMenu, appearWithAnimation: true, boldFont: false)
        Button_BackToMenu.position = CGPoint(x: Button_BackToMenu.getButtonWidth()/2+Button_BackToMenu.getButtonHeight()*0.2, y: size.height-Button_BackToMenu.getButtonHeight()*0.7)
        ContentNode.addChild(Button_BackToMenu)
        
        let Button_BackToGame = ButtonClass(title: "play again", fontSize: 20, height: size.height*0.08, width: size.width*0.22, function: buttonPressed_backToGame, appearWithAnimation: true, boldFont: false)
        Button_BackToGame.position = CGPoint(x: size.width-Button_BackToMenu.getButtonWidth()/2-Button_BackToMenu.getButtonHeight()*0.2, y: size.height-Button_BackToGame.getButtonHeight()*0.7)
        ContentNode.addChild(Button_BackToGame)
        
        
        let becomeHulk = SKAction.scaleTo(1, duration: 0.15)
        let move = SKAction.moveTo(CGPoint(x: size.width/2, y: size.height-Button_BackToGame.getButtonHeight()*0.2), duration: Button_BackToMenu.getAnimationDuration())
        let moveToTop = SKAction.group([move, SKAction.scaleTo(0.5, duration: Button_BackToMenu.getAnimationDuration())])
        moveToTop.timingMode = SKActionTimingMode.EaseInEaseOut
        
        if !globalNewHighscore {
        ContentNode.runAction(SKAction.sequence([
            SKAction.waitForDuration(0.8),
            SKAction.runBlock({title_Game.runAction(becomeHulk)}),
            SKAction.waitForDuration(0.8),
            SKAction.runBlock({title_Over.runAction(becomeHulk)}),
            SKAction.waitForDuration(1),
            SKAction.runBlock({
                title_Over.runAction(moveToTop)
                title_Game.runAction(moveToTop)
            }),
            //SKAction.waitForDuration(1),
            SKAction.runBlock({
                Button_BackToGame.animationAppear()
                Button_BackToMenu.animationAppear()
            }),
            SKAction.runBlock({self.createStatView(Button_BackToMenu.getAnimationDuration())})
            ]))
        } else {
            ContentNode.runAction(SKAction.sequence([
                SKAction.waitForDuration(0.8),
                SKAction.runBlock({title_Game.runAction(becomeHulk)}),
                SKAction.waitForDuration(0.8),
                SKAction.runBlock({title_Over.runAction(becomeHulk)}),
                SKAction.waitForDuration(1),
                SKAction.runBlock({self.createNewHighscoreSign()}),
                SKAction.waitForDuration(1),
                SKAction.runBlock({
                    self.highscoreCarrierNode.runAction(SKAction.fadeAlphaTo(0, duration: Button_BackToMenu.getAnimationDuration()*0.75))
                    title_Over.runAction(moveToTop)
                    title_Game.runAction(moveToTop)
                }),
                SKAction.runBlock({
                    Button_BackToGame.animationAppear()
                    Button_BackToMenu.animationAppear()
                }),
                SKAction.runBlock({self.createStatView(Button_BackToMenu.getAnimationDuration())})
                ]))
        }
        
        
    
    }
    
    
    func createStatView (moveInDuration: Double) {
 
        
        var lineHeight : CGFloat = 0
        var zeilenPos_y : CGFloat = size.height/1.5
        
        var Zeilen : [movableLine] = []
        
        var lineWidthMult : CGFloat = 0.8
        if isIPhone4s { lineWidthMult = 1 }
        if isIPhone5 { lineWidthMult = 0.9 }
        
        //Obere Zeile der Tabelle
        let Zeile = movableLine(color: whiteFont, size: CGSize(width: size.width*0.8, height: 1))

        let content = [" ", "this game", "best game"]
        
        var i : CGFloat = 1
        for strings in content {
            
            let text = SKLabelNode(fontNamed: "Arial-MT")
            text.text = strings
            text.fontColor = whiteFont
            text.fontSize = 20
            text.horizontalAlignmentMode = .Right
            text.verticalAlignmentMode = .Baseline
            text.position = CGPoint(x: -Zeile.size.width/2 + Zeile.size.width*(i/3), y: 2)
            Zeile.addChild(text)
            
            if i == 2 {
                lineHeight = text.frame.height*2
                if isIPhone4s || isIPhone5 {lineHeight = text.frame.height*1.5}
            }
            
            i += 1
        }
        
        Zeile.targetPosition = CGPoint(x: size.width/2, y: zeilenPos_y)
        Zeile.position = CGPoint(x: size.width/2, y: -lineHeight*2)
        zeilenPos_y -= lineHeight
        StatNode.addChild(Zeile)
        
        Zeilen.append(Zeile)
        
        
        //Untere Zeilen mit den Informationen
        
        let zeileAlpha : CGFloat = 0.3
        let infoAlpha : CGFloat = 1/0.3
        
        //Array sichert die richtige Sortierung der Einträge
        for key in statsOrder {
        
            let Zeile = movableLine(color: whiteFont, size: CGSize(width: size.width*0.8, height: 1))
            
            let content = [key, String(Int(thisStats[key]!)), String(Int(bestStats[key]!))]
            
            var i : CGFloat = 1
            for strings in content {
                
                let text = SKLabelNode(fontNamed: "Arial-MT")
                text.text = strings
                text.fontColor = whiteFont
                text.fontSize = 20
                text.horizontalAlignmentMode = .Right
                text.verticalAlignmentMode = .Baseline
                text.position = CGPoint(x: -Zeile.size.width/2 + Zeile.size.width*(i/3), y: 2)
                text.alpha = infoAlpha
                Zeile.addChild(text)
                i += 1
                
            }
            Zeile.alpha = zeileAlpha
            
            
            Zeile.targetPosition = CGPoint(x: size.width/2, y: zeilenPos_y)
            
            Zeile.position = CGPoint(x: size.width/2, y: -lineHeight*2)
            zeilenPos_y -= lineHeight
            StatNode.addChild(Zeile)
            Zeilen.append(Zeile)
 
        }
        
        var wait : Double = 0
        for Entry in Zeilen {
            
            Entry.size.width = size.width*lineWidthMult
            
            let moveIn = SKAction.moveTo(Entry.targetPosition, duration: moveInDuration)
            moveIn.timingMode = SKActionTimingMode.EaseOut
            
            Entry.runAction(SKAction.sequence([SKAction.waitForDuration(wait), moveIn]))
            
           wait += 0.15
        }
        
        
    }
    
    
    func createNewHighscoreSign () {
        
        
        highscoreCarrierNode.zPosition = 1
        addChild(highscoreCarrierNode)
        
        let highscoreEmitterNode = SKEmitterNode(fileNamed: "newHighscoreParticle")
        highscoreCarrierNode.addChild(highscoreEmitterNode!)
        
        let highscoreText = SKLabelNode(fontNamed: "Arial-MT")
        highscoreText.fontColor = UIColor.whiteColor()
        highscoreText.text = "new highscore"
        highscoreText.verticalAlignmentMode = .Center
        highscoreText.horizontalAlignmentMode = .Center
        highscoreText.fontSize = 18
        highscoreText.zPosition = 0.01
        highscoreText.alpha = 0
        highscoreCarrierNode.addChild(highscoreText)
        
        highscoreEmitterNode?.particlePositionRange = CGVector(dx: highscoreText.frame.size.width, dy: highscoreText.frame.size.height)
        
        highscoreCarrierNode.position = CGPoint(x: size.width/2, y: size.height-highscoreText.frame.size.height*1.3)
        
        highscoreText.runAction(SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.fadeAlphaTo(1, duration: 0)]))
        
    }
    
    
    func buttonPressed_backToMenu () {
        runAction(SKAction.sequence([
            SKAction.runBlock({
                let transition = SKTransition.revealWithDirection(.Right, duration: 0.75)
            
                self.view?.presentScene(MainMenu(size: self.size), transition: transition)
            })
        ]))
    }
    
    func buttonPressed_backToGame () {
        runAction(SKAction.sequence([
            SKAction.runBlock({
                let transition = SKTransition.revealWithDirection(.Right, duration: 0.75)
                
                self.view?.presentScene(MainGame(size: self.size), transition: transition)
            })
        ]))
    }
    


}







//
//  GameViewController.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 23.02.16.
//  Copyright (c) 2016 Marius Montebaur. All rights reserved.
//


import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let szene = MainMenu(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = Testing_ShowFPS
        skView.showsNodeCount = Testing_ShowNodes
        skView.ignoresSiblingOrder = true
        szene.scaleMode = SKSceneScaleMode.ResizeFill
        skView.presentScene(szene)
        
    }


    override func shouldAutorotate() -> Bool {
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("memory warning")
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}

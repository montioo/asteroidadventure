//
//  Colors.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 13.06.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation
import SpriteKit


let whiteFont = UIColor.whiteColor()
let gameLayerColor = UIColor(red: 40/255, green: 40/255, blue: 44/255, alpha: 1)
let gameGlasColor = UIColor(red: 0, green: 132/255, blue: 1, alpha: 0.25)


let ast_color_black = UIColor.blackColor()
let ast_color_white = UIColor.whiteColor()
let ast_color_blue = UIColor(red: 16/255, green: 76/255, blue: 1, alpha: 1)
let ast_color_red = UIColor(red: 255, green: 55/255, blue: 45/255, alpha: 1)

let ast_color_array = [ast_color_black, ast_color_white, ast_color_red, ast_color_blue]


func setRGBColor (red red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
}
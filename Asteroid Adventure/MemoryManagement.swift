//
//  GameFunc.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 29.04.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation
import SpriteKit


let Testing_ShowFPS : Bool = true
let Testing_ShowNodes : Bool = true
let Testing_GameOverAllowed : Bool = true

var MainScreenScale : CGFloat = 0

var Global_Highscore : Int = 0

//Dictionary mit den Einstellungen
//!!!App auf Handy löschen, wenn hier Änderungen gemacht wurden!!!
var OptionsDict: [String:Float] = [
    "vertical_control"  : 1, //Vertikale oder senkrechte Steuerung
    "invert_controls"   : 1, //Richtung der Kanonenbewegung ändern
    "pro_controls"      : 0, //Steuerungstypen wechseln
    "show_tutorial"     : 1, //Tutorial anzeigen
    
    "sound"             : 0,
    "music"             : 0,
    "vibration"         : 0,
    
    "control_sensitivity"   : 1, //Empfindlichkeit der Kanonenbewegung
    
    "default"           : 0  //Wird nur geändert, wenn ein Fehler mit den Checkboxen auftritt.
]

let ExplainDict: [String:String] = [
    "vertical_control"  : "switch between vertical and horizontal finger control",
    "invert_controls"   : "change direction of cannon movement",
    "pro_controls"      : "use more precise professional controls",
    "show_tutorial"     : "show tutorial at the beginning of the first 5 games",
    
    "sound"             : "enable gamesounds like exlposions",
    "music"             : "enable gametheme",
    "vibration"         : "activate vibration warnings",
    
    "control_sensitivity"   : "adjust the cannon's rotation speed"
]


func getBoolOption (key: String) -> Bool {
    let value : Float = OptionsDict[key]!
    
    if value == 1 { return true }
    return false
}

func setBoolOption (key: String, value: Bool) {
    var s : Float = 0
    if value == true { s = 1 }
 
    OptionsDict[key] = s

    SaveOptions()
}

func getFloatOption (key: String) -> Float {
    return OptionsDict[key]!
}

func setFloatOption (key: String, value: Float) {
    OptionsDict[key] = value
    SaveOptions()
}


func LoadOptions () {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    if let tmpDict = userDefaults.valueForKey("options") {
        //Gibt schon ein Dictionary
        OptionsDict = tmpDict as! Dictionary
        print("Options Dictionary geladen")
    } else {
        //noch kein Dictionary
        print("Noch kein Dictionary angelegt")
    }
}


func SaveOptions () {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setValue(OptionsDict, forKey: "options")
    userDefaults.synchronize()
    print("Options Dictionary gespeichert")
}



func LoadUserData () {
    LoadOptions()
    LoadStatistics()
}








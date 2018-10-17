//
//  GameFunc.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 29.04.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation
import SpriteKit


let Testing_ShowFPS : Bool = false
let Testing_ShowNodes : Bool = false
let Testing_GameOverAllowed : Bool = true

var MainScreenScale : CGFloat = 0

var Global_Highscore : Int = 0

//Dictionary mit den Einstellungen
//!!!App auf Handy löschen, wenn hier Änderungen gemacht wurden!!!
var OptionsDict: [String : Bool] = [
    
    "show_tutorial"     : true, //Tutorial anzeigen
    
    "aiming_help"       : true,
    
    "sound_effects"     : true,
    "music"             : true,
    "vibration"         : true
    
]


func getBoolOption (key: String) -> Bool {
    return OptionsDict[key]!
}

func setBoolOption (key: String, value: Bool) {
    OptionsDict[key] = value

    SaveOptions()
}


func LoadOptions () {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    if let tmpDict = userDefaults.valueForKey("options") {
        //Gibt schon ein Dictionary
        OptionsDict = tmpDict as! Dictionary
        //print("Options Dictionary geladen")
    } else {
        //noch kein Dictionary
        //print("Noch kein Dictionary angelegt")
    }
}


func SaveOptions () {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setValue(OptionsDict, forKey: "options")
    userDefaults.synchronize()
    //print("Options Dictionary gespeichert")
}



func LoadUserData () {
    LoadOptions()
    LoadStatistics()
}








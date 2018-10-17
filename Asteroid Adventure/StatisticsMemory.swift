//
//  Statistics.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 16.06.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation


var globalNewHighscore : Bool = false

let statsOrder = ["highscore", "asteriods destroyed", "enemys killed", "lasers fired", "collected powerups"]

var bestStats: [String:Float] = [
    "highscore"             : 0,
    "asteriods destroyed"   : 0,
    "enemys killed"         : 0,
    "lasers fired"          : 0,
    "collected powerups"    : 0
]

var thisStats: [String:Float] = [
    "highscore"             : 0,
    "asteriods destroyed"   : 0,
    "enemys killed"         : 0,
    "lasers fired"          : 0,
    "collected powerups"    : 0
]


func reset_thisStats () {
    for key in thisStats.keys {
        thisStats[key] = 0
    }
}


func reset_bestStats () {
    for key in bestStats.keys {
        bestStats[key] = 0
    }
    SaveStatistics()
}

func SaveStatistics () {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setValue(bestStats, forKey: "bestStats")
    userDefaults.synchronize()
    //print("Statistik Dictionary gespeichert")
}


func LoadStatistics () {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    if let tmpDict = userDefaults.valueForKey("bestStats") {
        //Es gibt schon ein Dictionary
        bestStats = tmpDict as! Dictionary
        //print("Statistik Dictionary geladen")
        
        Global_Highscore = Int(tmpDict["highscore"] as! NSNumber)
        
    } else {
        //noch kein Dictionary
        //print("Noch kein Statistik Dictionary angelegt")
    }
}






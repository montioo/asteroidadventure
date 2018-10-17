//
//  Statistics.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 16.06.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation

/*
let airportCodes = [String](airports.keys)

for airportCode in airports.keys {
print("Airport code: \(airportCode)")
}
*/

let statsOrder = ["highscore", "asteriods destroyed", "shots per hit", "lasers fired", "collected powerups"]

var totalStats: [String:Float] = [
    "highscore"             : 0,
    "asteriods destroyed"   : 0,
    "shots per hit"         : 0,
    "lasers fired"          : 0,
    "collected powerups"    : 0
]

var thisStats: [String:Float] = [
    "highscore"             : 0,
    "asteriods destroyed"   : 0,
    "shots per hit"         : 0,
    "lasers fired"          : 0,
    "collected powerups"    : 0
]


func reset_thisStats () {
    
    for key in thisStats.keys {
        thisStats[key] = 0
    }
    
}


func SaveStatistics () {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setValue(totalStats, forKey: "totalStats")
    userDefaults.synchronize()
    print("Statistik Dictionary gespeichert")
}


func LoadStatistics () {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    if let tmpDict = userDefaults.valueForKey("totalStats") {
        //Es gibt schon ein Dictionary
        totalStats = tmpDict as! Dictionary
        print("Statistik Dictionary geladen")
        
        Global_Highscore = Int(tmpDict["highscore"] as! NSNumber)
        
    } else {
        //noch kein Dictionary
        print("Noch kein Statistik Dictionary angelegt")
    }
}



func SaveScore (score: Int) {
    if score > Global_Highscore {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(score, forKey: "highscore")
        userDefaults.synchronize()
        Global_Highscore = score
        print("Highscore ", score, " gepseichert")
    }
}

func ResetScore () {
    let score = 0
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setValue(score, forKey: "highscore")
    userDefaults.synchronize()
    Global_Highscore = score
    print("Highscore resettet")
    
}






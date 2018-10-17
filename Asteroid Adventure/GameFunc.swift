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
let Testing_GameOverAllowed : Bool = false
let Testing_EffectsAllowed : Bool = false
let Testing_ShowIngameTime : Bool = false

var Option_ControlVartical : Bool = true
var Option_InvertControls : Bool = true
var Option_FingerMoveSpace : CGFloat = 1 //1 ist Standart, 0.7 ist empfindlicher, 1.3 ist unempflindlicher
var Option_ShowTutorial : Bool = true

var SoundEnabled : Bool = true
var MusicEnabled : Bool = true

var MainScreenScale : CGFloat = 0


var Global_Highscore : Int = 0

//Dictionary mit den Einstellungen
    //
var OptionsDict: [String:Float] = [
    "vertical_control"   : 1, //Vertikale oder senkrechte Steuerung
    "invert_controls"    : 1, //Richtung der Kanonenbewegung ändern
    "pro_controls"       : 1, //Steuerungstypen wechseln
    "show_tutorial"      : 1, //Tutorial anzeigen
    
    "control_sensitivity"   : 1, //Empfindlichkeit der Kanonenbewegung
    
    "default"           : 0  //Wird nur geändert, wenn ein Fehler mit den Checkboxen auftritt.
]

var ExplainDict: [String:String] = [
    "vertical_control"   : "switch between vertical and horizontal finger control",
    "invert_controls"    : "change direction of cannon movement",
    "pro_controls"       : "use more precise professional controls",
    "show_tutorial"      : "show tutorial at the beginning of the first 5 games",
    
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


func LoadHighscoore () {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    if let highscore = userDefaults.valueForKey("highscore") {
        //Gibt schon einen Highscore
        print("Highscore geladen: ", highscore)
        Global_Highscore = Int(highscore as! NSNumber)
    } else {
        //noch kein Highscore
        print("Kein gespeicherter Highscore gefunden")
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


func LoadUserData () {
    LoadHighscoore()
    LoadOptions()
}



//Gibt Zahl zurück, deren Betrag größer ist.
func maxAbs (a: CGFloat, b: CGFloat) -> CGFloat {
    if abs(a) > abs(b) {
        return a
    } else {
        return b
    }
}

//Gibt zufällige CGFloat Zahl zurück
func random(min min: CGFloat, max: CGFloat) -> CGFloat {
    return (CGFloat(Float(arc4random()) / 0xFFFFFFFF)) * (max - min) + min
}

//Gibt zufällige Integer Zahl zurück
func randomInt(min min: Int, max: Int) -> Int {
    let range = max - min
    let number = Int(arc4random_uniform(UInt32(range+1)))
    //arc4random_uniform gibt Zufallsinteger von 0 bis Eingabe-1 aus
    return (number+min)
}

//Gibt zufällig 1 oder -1 als CGFloat zurück
func randomPosOrNeg () -> CGFloat {
    let wert = random(min: -1.0, max: 1.0)
    return (wert / abs(wert))
}


func quad (Zahl: CGFloat) -> CGFloat {
    return (Zahl*Zahl)
    
}


func DegToRad (Zahl: Float) -> Float {
    return Zahl*Float(M_PI/180)
}


func RadToDeg (Zahl: Float) -> Float {
    return Zahl*Float(180/M_PI)
}








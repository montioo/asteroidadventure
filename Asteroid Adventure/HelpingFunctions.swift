//
//  HelpingFunctions.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 08.06.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation
import SpriteKit


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

func potenziereInt (zahl: Int, hoch: Int) -> Int {
    if hoch == 0 { return 1 }
    var ergebnis = zahl
    for _ in 1..<hoch {
        ergebnis = ergebnis * zahl
    }
    return ergebnis
}


func DegToRad (Zahl: CGFloat) -> CGFloat {
    return Zahl*CGFloat(M_PI/180)
}


func RadToDeg (Zahl: CGFloat) -> CGFloat {
    return Zahl*CGFloat(180/M_PI)
}




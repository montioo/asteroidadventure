//
//  PhysicsCategories.swift
//  Asteroid Adventure
//
//  Created by Marius Montebaur on 10.08.16.
//  Copyright © 2016 Marius Montebaur. All rights reserved.
//

import Foundation


struct PhysicsCategory {
    static let None             : UInt32 = 0
    static let All              : UInt32 = UInt32.max
    
    static let PhyLaser         : UInt32 = 0b0001 //1
    
    static let PhyEnemy         : UInt32 = 0b0010 //2
    
    static let PhyRaumschiff    : UInt32 = 0b0011 //3
    
    static let PhyStdAst        : UInt32 = 0b0100 //4
    
    static let PhySchild        : UInt32 = 0b0101 //5
    
    static let PhyEnergySlice       : UInt32 = 0b0110 //6
    
    static let PhyBombBody          : UInt32 = 0b0111 //7
    static let PhyBombExpl          : UInt32 = 0b1000 //8
    
    static let PhyEnemyLaser        : UInt32 = 0b1001 //9
    
    static let PhyPowerUpMultiLaser : UInt32 = 0b1010 //10
    static let PhyPowerUpPowerLaser : UInt32 = 0b1011 //11
    static let PhyPowerUp1UP        : UInt32 = 0b1100 //12
    
    static let PhyTutExitAst        : UInt32 = 0b1101 //13
}
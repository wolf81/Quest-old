//
//  Energy.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 22/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class Energy {
    private var energy: UInt = 0
    
    var canTakeTurn: Bool { energy >= 50 }
    
    func increment(_ energy: UInt) {
        self.energy += energy
    }
    
    func drain() {
        self.energy = 0
    }
}

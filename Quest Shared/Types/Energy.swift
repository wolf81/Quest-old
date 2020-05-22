//
//  Energy.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 22/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class Energy {
    private(set) var amount: UInt = 0
            
    func increment(_ energy: UInt) {
        self.amount += energy
    }
    
    func drain() {
        self.amount = 0
    }
}

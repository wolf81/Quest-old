//
//  Energy.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 22/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class Energy {
    private(set) var amount: Int = 0
            
    func increment(_ energy: Int) {
        self.amount = min(self.amount + energy, 50)
    }
    
    func drain() {
        self.amount = 0
    }
    
    func drain(_ amount: Int) {
        self.amount -= max(amount, Constants.minimumEnergyCost)
    }
}

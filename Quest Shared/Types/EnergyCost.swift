//
//  EnergyCost.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 22/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class EnergyCost {
    var move: Int = 50
    var attack: Int = 50
    
    var minimumEnergyCost: Int { min(self.move, self.attack) }
    
    convenience init() {
        self.init(json: [:])
    }
    
    init(json: [String: Int]) {
        self.move = json["move"] ?? 50
        self.attack = json["attack"] ?? 50
    }
}

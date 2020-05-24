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
    var attackMelee: Int = 50
    var attackRanged: Int = 50
    
    convenience init() {
        self.init(json: [:])
    }
    
    init(json: [String: Int]) {
        self.move = json["move"] ?? 50
        self.attackMelee = json["attackMelee"] ?? 50
        self.attackRanged = json["attackRanged"] ?? 50
    }
}

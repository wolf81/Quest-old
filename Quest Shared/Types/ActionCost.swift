//
//  ActionCost.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 14/04/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

struct ActionCost: CustomStringConvertible {
    let move: Int
    let meleeAttack: Int
    let rangedAttack: Int
    
    public init() {
        self.move = Constants.timeUnitsPerTurn
        self.meleeAttack = Constants.timeUnitsPerTurn
        self.rangedAttack = Constants.timeUnitsPerTurn
    }
    
    public init(json: [String: Int]) {
        self.move = json["move"] ?? Constants.timeUnitsPerTurn
        self.meleeAttack = json["meleeAttack"] ?? Constants.timeUnitsPerTurn
        self.rangedAttack = json["rangedAttack"] ?? Constants.timeUnitsPerTurn
    }
    
    var description: String {
        return "move: \(self.move), meleeAttack: \(self.meleeAttack), rangedAttack: \(self.rangedAttack)"
    }
}

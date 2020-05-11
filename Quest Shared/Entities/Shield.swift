//
//  Shield.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 09/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class Shield: Entity & Equippable, CustomStringConvertible {
    let armorClass: Int
    
    var equipmentSlot: EquipmentSlot { .arms }
    
    required init(json: [String : Any]) {
        self.armorClass = json["AC"] as? Int ?? 0
                
        super.init(json: json)
    }
    
    static var none: Shield { return Shield(json: [:]) }
        
    var description: String {
        return "{ armorClass: \(self.armorClass) }"
    }
}

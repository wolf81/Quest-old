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
    
    var equipmentSlot: EquipmentSlot { .rightArm }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.armorClass = json["AC"] as? Int ?? 0
                
        super.init(json: json, entityFactory: entityFactory)
    }
    
    static var none: Shield { return Shield(json: [:], entityFactory: EntityFactory()) }
        
    var description: String {
        return "{ armorClass: \(self.armorClass) }"
    }
}

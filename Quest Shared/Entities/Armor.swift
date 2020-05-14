//
//  Armor.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class Armor: Entity & Equippable {
    let armorClass: Int
    
    var equipmentSlot: EquipmentSlot { .chest }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        let armorClass = json["AC"] as! Int
        self.armorClass = armorClass
        
        super.init(json: json, entityFactory: entityFactory)
    }
    
    static var none: Armor {
        get {
            return self.init(json: ["AC": 0], entityFactory: EntityFactory())
        }
    }
}

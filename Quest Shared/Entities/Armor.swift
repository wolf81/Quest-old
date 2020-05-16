//
//  Armor.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class Armor: Entity & Equippable {
    enum ArmorType: String {
        case none
        case light
        case medium
        case heavy
        
        init(rawValue: String) {
            switch rawValue {
            case "none": self = .none
            case "light": self = .light
            case "medium": self = .medium
            case "heavy": self = .heavy
            default: fatalError()
            }
        }
    }
    
    let armorClass: Int
    
    var equipmentSlot: EquipmentSlot { .chest }
    
    let type: ArmorType
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        let armorClass = json["AC"] as! Int
        self.armorClass = armorClass
        
        let armorType = json["type"] as? String ?? "none"
        self.type = ArmorType(rawValue: armorType)
        
        super.init(json: json, entityFactory: entityFactory)
    }
    
    static var none: Armor {
        get {
            return self.init(json: ["AC": 0], entityFactory: EntityFactory())
        }
    }
}

//
//  Player.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Weapon: Entity & Equippable, CustomStringConvertible {
    enum WeaponCategory {
        case light
        case medium
        case heavy
    }
    
    enum WieldStyle: String {
        case oneHanded
        case twoHanded
    }

    enum WeaponType: String {
        case unarmed
        case shortbow
        case shortsword
        case longsword
        case greataxe
        case staff
        case mace
        
        init(rawValue: String) {
            switch rawValue {
            case "unarmed": self = .unarmed
            case "shortbow": self = .shortbow
            case "shortsword": self = .shortsword
            case "longsword": self = .longsword
            case "greataxe": self = .greataxe
            case "staff": self = .staff
            case "mace": self = .mace
            default: fatalError()
            }
        }
        
        fileprivate var category: WeaponCategory {
            switch self {
            case .greataxe, .staff: return .heavy
            case .shortsword, .unarmed: return .light
            case .longsword, .mace, .shortbow: return .medium
            }
        }
        
        fileprivate var wieldStyle: WieldStyle {
            if self == .shortbow { return .twoHanded }
            
            switch self.category {
            case .heavy: return .twoHanded
            case .light, .medium: return .oneHanded
            }
        }
    }

    let attack: Int
    let damage: HitDie
    let range: Int
    let type: WeaponType
    
    var category: WeaponCategory { self.type.category }
    var style: WieldStyle { self.type.wieldStyle }
    
    var equipmentSlot: EquipmentSlot { .mainhand }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.attack = json["AT"] as? Int ?? 0
        self.range = json["range"] as? Int ?? 1

        let damage = json["damage"] as! String
        self.damage = HitDie(rawValue: damage)!
        
        let weaponType = json["type"] as! String
        self.type = WeaponType(rawValue: weaponType)
        
        super.init(json: json, entityFactory: entityFactory)
    }
        
    var description: String {
        return "{ attack: \(attack), damage: \(damage) }"
    }
}

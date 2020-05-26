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

    lazy var equipSprite: SKSpriteNode = {
        guard let spriteName = self.json["equipSprite"] as? String else { fatalError() }        
        return Entity.loadSprite(type: self, spriteName: spriteName)
    }()

    let attack: Int
    let damage: HitDie
    let range: Int
    let type: WeaponType
    
    var projectile: Projectile?
    
    var category: WeaponCategory { self.type.category }
    var style: WieldStyle { self.type.wieldStyle }
    
    var equipmentSlot: EquipmentSlot { .mainhand }
    
    var effects: [Effect] = []
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.attack = json["AT"] as? Int ?? 0
        self.range = json["range"] as? Int ?? 1

        let damage = json["damage"] as! String
        self.damage = HitDie(rawValue: damage)!
        
        let weaponType = json["type"] as! String
        self.type = WeaponType(rawValue: weaponType)!
        
        if let projectile = json["projectile"] as? String {
            self.projectile = try! entityFactory.newEntity(type: Projectile.self, name: projectile)
        }
        
        super.init(json: json, entityFactory: entityFactory)
    }
        
    var description: String {
        return "{ attack: \(attack), damage: \(damage) }"
    }
}

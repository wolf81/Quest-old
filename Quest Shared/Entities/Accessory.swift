//
//  Ring.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 24/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class Accessory: Entity & Equippable {
    enum AccessoryType: String {
        case boots
        case ring
        case belt
        case headpiece
    }

    var equipmentSlot: EquipmentSlot {
        switch self.type {
        case .ring: return .ring
        case .boots: return .feet
        case .belt: return .waist
        case .headpiece: return .head
        }
    }
    
    let effects: [Effect]
    
    let type: AccessoryType
    
    lazy var equipSprite: SKSpriteNode = {        
        guard let spriteName = (self.json["equipSprite"] ?? self.json["sprite"]) as? String else { fatalError() }        
        return Entity.loadSprite(type: self, spriteName: spriteName)
    }()

    required init(json: [String : Any], entityFactory: EntityFactory) {
        var effects: [Effect] = []
        if let effectNames = json["effects"] as? [String] {
            for effectName in effectNames {
                let effect = try! entityFactory.newEntity(type: Effect.self, name: effectName)
                effects.append(effect)
            }
        }
        self.effects = effects
        
        let accessoryType = json["type"] as! String
        self.type = AccessoryType(rawValue: accessoryType)!
        
        super.init(json: json, entityFactory: entityFactory)
    }
    
    static func none(type: AccessoryType) -> Accessory {
        return self.init(json: ["type": type.rawValue], entityFactory: EntityFactory())
    }
}

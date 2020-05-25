//
//  Armor.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit
import CoreGraphics

class Armor: Entity & Equippable {
    enum ArmorType: String {
        case none
        case light
        case medium
        case heavy
        case shield
    }
            
    let armorClass: Int
    
    var equipmentSlot: EquipmentSlot { type == .shield ? .offhand : .chest }
    
    let type: ArmorType
    
    var effects: [Effect] = []
    
    lazy var equipSprite: SKSpriteNode = {
        guard let spriteInfo = self.json["equipSprite"] else { fatalError() }
              
        switch spriteInfo {
        case let spriteName as String:
            return Entity.loadSprite(type: self, spriteName: spriteName)
        case let spriteNames as [String]:
            return Entity.loadSprite(type: self, spriteNames: spriteNames)
        default: fatalError()
        }
    }()
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        let armorClass = json["AC"] as! Int
        self.armorClass = armorClass
        
        let armorType = json["type"] as? String ?? "none"
        self.type = ArmorType(rawValue: armorType)!
        
        super.init(json: json, entityFactory: entityFactory)
        
        configureSprite()
    }
    
    static var none: Armor {
        get {
            return self.init(json: ["AC": 0], entityFactory: EntityFactory())
        }
    }
    
    private func configureSprite() {
        guard let spriteInfo = self.json["sprite"] else { return }
                
        switch spriteInfo {
        case let spriteName as String:
            self.sprite = Entity.loadSprite(type: self, spriteName: spriteName)
        case let spriteNames as [String]:
            self.sprite = Entity.loadSprite(type: self, spriteNames: spriteNames)
        default: fatalError()
        }
    }
}

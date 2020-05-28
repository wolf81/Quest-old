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
        case greatsword
        case greataxe
        case staff
        case mace
                
        fileprivate var category: WeaponCategory {
            switch self {
            case .greataxe, .greatsword, .staff: return .heavy
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
        guard let spriteName = self.json["equipSprite"] as? String else {
            return SKSpriteNode(color: .clear, size: Constants.tileSize)
        }        
        return Entity.loadSprite(type: self, spriteName: spriteName)
    }()

    private lazy var soundInfo: [SoundType: [String]] = {
        guard let soundInfo = self.json["sounds"] as? [String: [String]] else { return [:] }
            
        var result: [SoundType: [String]] = [:]
        for (typeName, soundNames) in soundInfo {
            let soundType = SoundType(rawValue: typeName)!
            result[soundType] = soundNames
        }

        return result
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
        
    func playSound(_ type: SoundType, on node: SKNode) {
        guard let sounds = self.soundInfo[type] else { return }
        
        let index = arc4random_uniform(UInt32(sounds.count))
        let sound = sounds[Int(index)]
                
        let play = SKAction.playSoundFileNamed(sound, waitForCompletion: false)
        node.run(play)
    }

    var description: String {
        return "{ attack: \(attack), damage: \(damage) }"
    }
}

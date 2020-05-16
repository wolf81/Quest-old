//
//  EntityDrawLayer.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

struct DrawLayerHelper {
    private enum EntityDrawLayer: CGFloat {
        case tile = 1_000
        case loot = 5_000
        case monster = 10_000
        case hero = 50_000
        case equipment = 100_000
        case fog = 500_000
        case overlay = 1_000_000
        case hud = 5_000_000
    }
        
    public static func zPosition(for entity: EntityProtocol) -> CGFloat {
        switch entity {
        case is Potion: return EntityDrawLayer.loot.rawValue
        case is Hero: return EntityDrawLayer.hero.rawValue
        case is Monster: return EntityDrawLayer.monster.rawValue
        case is Weapon: fallthrough
        case is Armor: return EntityDrawLayer.equipment.rawValue
        case is FogTile: return EntityDrawLayer.fog.rawValue
        case is OverlayTile: return EntityDrawLayer.overlay.rawValue
        case is Tile: return EntityDrawLayer.tile.rawValue
        default: fatalError()
        }
    }
    
    public static func zPosition(for node: SKNode) -> CGFloat {
        switch node {
        case is ActionBar: fallthrough
        case is InventoryNode: fallthrough
        case is StatusBar: return EntityDrawLayer.overlay.rawValue
        case is HealthBar: return EntityDrawLayer.equipment.rawValue
        default: fatalError()            
        }
    }
}

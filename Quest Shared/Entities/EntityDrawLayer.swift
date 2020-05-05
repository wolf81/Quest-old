//
//  EntityDrawLayer.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

struct EntityDrawLayerHelper {
    private enum EntityDrawLayer: CGFloat {
        case tile = 1_000
        case actor = 10_000
        case equipment = 100_000
        case fog = 500_000
        case overlay = 1_000_000
        case hud = 5_000_000
    }
        
    public static func zPosition(for entity: EntityProtocol) -> CGFloat {
        switch entity {
        case is Actor: return EntityDrawLayer.actor.rawValue
        case is Weapon: fallthrough
        case is Armor: fallthrough
        case is Shield: return EntityDrawLayer.equipment.rawValue
        case is FogTile: return EntityDrawLayer.fog.rawValue
        case is OverlayTile: return EntityDrawLayer.overlay.rawValue
        case is Tile: return EntityDrawLayer.tile.rawValue
        default: fatalError()
        }
    }
}

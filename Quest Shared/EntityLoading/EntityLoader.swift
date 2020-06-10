//
//  EntityLoader.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class EntityLoader {    
    static var entityCount: Int = {
        var entityCount = 0
        
        let url = Bundle.main.resourceURL!.appendingPathComponent("Data")
        var files = [URL]()
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator where fileURL.pathExtension == "json" {
                entityCount += 1
            }
        }
        
        return entityCount
    }()
    
    static func registerEntities(for entityFactory: EntityFactory) throws {
        // TODO: Should be able to create a simple loop for this, but can't figure it out right now
        
        let effects = try loadEntities(type: Effect.self, in: "Data/Effect", entityFactory: entityFactory)
        effects.forEach{ entityFactory.register(entity: $0) }
        
        let decorations = try loadEntities(type: Decoration.self, in: "Data/Decoration", entityFactory: entityFactory)
        decorations.forEach({ entityFactory.register(entity: $0 )})
        
        let potions = try loadEntities(type: Potion.self, in: "Data/Potion", entityFactory: entityFactory)
        potions.forEach{ entityFactory.register(entity: $0) }

        let projectiles = try loadEntities(type: Projectile.self, in: "Data/Projectile", entityFactory:  entityFactory)
        projectiles.forEach{ entityFactory.register(entity: $0) }
        
        let rings = try loadEntities(type: Accessory.self, in: "Data/Accessory", entityFactory: entityFactory)
        rings.forEach{ entityFactory.register(entity: $0) }
        
        let weapons = try loadEntities(type: Weapon.self, in: "Data/Weapon", entityFactory: entityFactory)
        weapons.forEach{ entityFactory.register(entity: $0) }
                
        let armor = try loadEntities(type: Armor.self, in: "Data/Armor", entityFactory: entityFactory)
        armor.forEach{ entityFactory.register(entity: $0) }
        
        let tiles = try loadEntities(type: Tile.self, in: "Data/Tile", entityFactory: entityFactory)
        tiles.forEach{ entityFactory.register(entity: $0) }
        
        let traps = try loadEntities(type: Trap.self, in: "Data/Trap", entityFactory: entityFactory)
        traps.forEach{ entityFactory.register(entity: $0) }

        let doors = try loadEntities(type: Door.self, in: "Data/Door", entityFactory: entityFactory)
        doors.forEach{ entityFactory.register(entity: $0) }
        
        let monsters = try loadEntities(type: Monster.self, in: "Data/Monster", entityFactory: entityFactory)
        monsters.forEach{ entityFactory.register(entity: $0) }
    }

    private static func loadEntities<T: EntityProtocol>(type: T.Type, in directory: String, entityFactory: EntityFactory) throws -> [T] {
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: directory)
        
        var entities: [T] = []
        
        for path in paths {
            let entity = try DataLoader.loadEntity(type: type, fromPath: path, entityFactory: entityFactory)
            entities.append(entity)
        }
        
        return entities
    }
}

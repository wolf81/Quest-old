//
//  EntityLoader.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class EntityLoader {
    static func loadEntities(for entityFactory: EntityFactory) throws {
        Entity.entityFactory = entityFactory
        
        let weapons = try loadEntities(type: Weapon.self, in: "Data/Weapons")
        weapons.forEach({ entityFactory.register(entity: $0 )})
        
        let armor = try loadEntities(type: Armor.self, in: "Data/Armor")
        armor.forEach({ entityFactory.register(entity: $0 )})

        let tiles = try loadEntities(type: Tile.self, in: "Data/Tile")
        tiles.forEach({ entityFactory.register(entity: $0 )})

        let monsters =  try loadEntities(type: Monster.self, in: "Data/Monster")
        monsters.forEach({ entityFactory.register(entity: $0 )})
    }

    private static func loadEntities<T: Entity>(type: T.Type, in directory: String) throws -> [T] {
        print("load entities from: \(directory)")
        let paths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: directory)
        
        var entities: [T] = []
        
        for path in paths {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                print("failed to load json from file: \(url)")
                continue
            }
            let tile = T(json: json)
            entities.append(tile)
        }
        
        return entities
    }
}

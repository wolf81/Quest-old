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
    
    static func loadEntities(for entityFactory: EntityFactory) throws {
        let weapons = try loadEntities(type: Weapon.self, in: "Data/Weapons", entityFactory: entityFactory)
        weapons.forEach({ entityFactory.register(entity: $0) })
        
        let shields = try loadEntities(type: Shield.self, in: "Data/Shields", entityFactory: entityFactory)
        shields.forEach({ entityFactory.register(entity: $0) })
        
        let armor = try loadEntities(type: Armor.self, in: "Data/Armor", entityFactory: entityFactory)
        armor.forEach({ entityFactory.register(entity: $0) })
        
        let tiles = try loadEntities(type: Tile.self, in: "Data/Tile", entityFactory: entityFactory)
        tiles.forEach({ entityFactory.register(entity: $0) })

        let monsters =  try loadEntities(type: Monster.self, in: "Data/Monster", entityFactory: entityFactory)
        monsters.forEach({ entityFactory.register(entity: $0) })
    }

    private static func loadEntities<T: EntityProtocol>(type: T.Type, in directory: String, entityFactory: EntityFactory) throws -> [T] {
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
            let tile = T(json: json, entityFactory: entityFactory)
            entities.append(tile)
        }
        
        return entities
    }
}

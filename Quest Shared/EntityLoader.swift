//
//  EntityLoader.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

class EntityLoader {
    func loadEntities() throws -> [Entity] {
        var entities: [Entity] = []
        
        let weapons = try loadEntities(type: Weapon.self, in: "Data/Weapons")
        entities.append(contentsOf: weapons)
        
        let armor = try loadEntities(type: Armor.self, in: "Data/Armor")
        entities.append(contentsOf: armor)
        
        let players = try loadEntities(type: Hero.self, in: "Data/Player")
        entities.append(contentsOf: players)
        
        let tiles = try loadEntities(type: Tile.self, in: "Data/Tile")
        entities.append(contentsOf: tiles)
        
        let monsters =  try loadEntities(type: Monster.self, in: "Data/Monster")
        entities.append(contentsOf: monsters)
        
        return entities
    }

    private func loadEntities<T: Entity>(type: T.Type, in directory: String) throws -> [T] {
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

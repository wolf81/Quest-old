//
//  EntityFactory.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

enum EntityFactoryError: LocalizedError {
    case notRegistered(String)
}

// TODO:
// Could consider to make a generic factory, but it'd mean we'd have to create factories for:
// - monsters
// - equipment
// - tiles
// - ...?
// Not yet sure what is better - it'd be typesafe but perhaps a bit unwieldly ...
class EntityFactory {
    private var registry: [String: EntityProtocol] = [:]
    
    func register(entity: EntityProtocol) {
        self.registry[entity.name] = entity
    }

    func newEntity(name: String, coord: vector_int2 = vector_int2(0, 0)) throws -> EntityProtocol {
        guard let entity = self.registry[name] else {
            throw EntityFactoryError.notRegistered(name)
        }
        
        return entity.copy(coord: coord)
    }
}

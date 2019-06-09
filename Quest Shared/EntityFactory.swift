//
//  EntityFactory.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

// TODO:
// Could consider to make a generic factory, but it'd mean we'd have to create factories for:
// - monsters
// - equipment
// - tiles
// - ...?
// Not yet sure what is better - it'd be typesafe but perhaps a bit unwieldly ...
class EntityFactory {
    private var registry: [String: Entity] = [:]
    
    func register(entity: Entity) {
        self.registry[entity.name] = entity
    }

    func newEntity(name: String) -> Entity? {
        if let entity = self.registry[name] {
            return entity.copy()
        }
        
        return nil
    }
}

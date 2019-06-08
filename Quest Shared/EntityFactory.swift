//
//  EntityFactory.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation

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

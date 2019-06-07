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
    
    func register<T: Entity>(entity: T) {
        self.registry[entity.name] = entity
    }

    func newEntity<T: Entity>(name: String) -> T? {
        if let entity = self.registry[name] as? T {
            return entity.copy() as T
        }
        
        return nil
    }
}

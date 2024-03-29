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

protocol EntityFactoryDelegate: class {
    func entityFactory(entityFactory: EntityFactory, didRegister entity: EntityProtocol)
}

// TODO:
// Could consider to make a generic factory, but it'd mean we'd have to create factories for:
// - monsters
// - equipment
// - tiles
// - ...?
// Not yet sure what is better - it'd be typesafe but perhaps a bit unwieldly ...
class EntityFactory {
    private var registry: [String: [String: EntityProtocol]] = [:]
    
    public var entityCount: Int { self.registry.compactMap({ $1 }).reduce([], { $0 + $1 }).count }
    
    weak var delegate: EntityFactoryDelegate?
    
    init(delegate: EntityFactoryDelegate? = nil) {
        self.delegate = delegate
    }
    
    func register<T: EntityProtocol>(entity: T) {
        let typeName = String(describing: T.self)
        if self.registry[typeName] == nil {
            self.registry[typeName] = [:]
        }
        
        self.registry[typeName]![entity.name] = entity

        self.delegate?.entityFactory(entityFactory: self, didRegister: entity)
    }

    func newEntity<T: EntityProtocol>(type: T.Type, name: String, coord: vector_int2 = vector_int2(0, 0)) throws -> T {
        let typeName = String(describing: T.self)
        
        guard let entities = self.registry[typeName] else {
            throw EntityFactoryError.notRegistered(typeName)
        }
        
        guard let entity = entities[name] else {
            throw EntityFactoryError.notRegistered(name)
        }

        return entity.copy(coord: coord, entityFactory: self) as! T
    }
    
    func newEntity(typeName: String, name: String, coord: vector_int2 = vector_int2(0, 0)) throws -> EntityProtocol {
        guard let entities = self.registry[typeName] else {
            throw EntityFactoryError.notRegistered(typeName)
        }
        
        guard let entity = entities[name] else {
            throw EntityFactoryError.notRegistered(name)
        }
        
        return entity.copy(coord: coord, entityFactory: self)
    }
    
    func entityNames<T: EntityProtocol>(of type: T.Type) -> [String] {
        let typeName = String(describing: T.self)
        let entityNames: [String: EntityProtocol] = self.registry[typeName] ?? [:]
        return Array(entityNames.keys)
    }
    
    func preload() {
        for (_, entityInfo) in self.registry {            
            _ = entityInfo.mapValues({ $0.preload() })
        }
    }
}

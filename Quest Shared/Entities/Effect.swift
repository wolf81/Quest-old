//
//  Effect.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 24/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

enum EffectType: String {
    case reduceDamage
    case restoreHealth
    case lowerMovementEnergyCost
    case raiseMovementEnergyCost
    case limitSight
    case search
}

class Effect: EntityProtocol {
    private let json: [String: Any]
    
    lazy var name: String = {
        return self.json["name"] as! String;
    }()

    lazy var sprite: SKSpriteNode = { return nil! }()
    
    lazy var coord: vector_int2 = { return nil! }()        
            
    var type: EffectType
    
    var value: Int
    
    func copy(coord: vector_int2, entityFactory: EntityFactory) -> Self {
        return copyInternal(coord: coord, entityFactory: entityFactory)
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        let typeName = json["type"] as! String
        self.type = EffectType(rawValue: typeName)!
        self.value = json["value"] as! Int
        
        self.json = json
    }
    
    required init(json: [String : Any]) {
        fatalError()
    }

    func apply(actor: Actor, userInfo: [String: Any]) {
        switch self.type {
        case .restoreHealth:
            actor.hitPoints.restore(hitPoints: self.value)
        default:
            fatalError()
        }
    }
    
    // MARK: - Private
    
    private func copyInternal<T: Effect>(coord: vector_int2, entityFactory: EntityFactory) -> T {
        let entity = T(json: self.json, entityFactory: entityFactory)
        entity.coord = coord
        return entity
    }
}

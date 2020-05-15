//
//  Potion.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 15/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

/*
 
 
 {
    "name": "Heal",
    "effects": ["heal"]
 

    "name": "Fireball"
    "effects": ["damage"]
 }
 
 
 heal1:
 {
    "restore": 6,
 }
 
 
 */

protocol Usable {
    var effects: [Effect] { get }
    
    func use(actor: Actor) 
}

class Potion: Entity & Usable & Lootable {
    let effects: [Effect]
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        var effects: [Effect] = []
        if let effectNames = json["effects"] as? [String] {
            for effectName in effectNames {
                let effect = try! entityFactory.newEntity(type: Effect.self, name: effectName)
                effects.append(effect)
            }
        }
        self.effects = effects
        
        super.init(json: json, entityFactory: entityFactory)
    }
    
    func use(actor: Actor) {
        print("use")
        
        for effect in effects {
            effect.apply(sourceActor: actor, targetActor: actor, userInfo: [:])
        }
    }
}

class Effect: EntityProtocol {
    private let json: [String: Any]
    
    lazy var name: String = {
        return self.json["name"] as! String;
    }()

    lazy var sprite: SKSpriteNode = { return nil! }()
    
    lazy var coord: vector_int2 = { return nil! }()
    
    func copy(coord: vector_int2, entityFactory: EntityFactory) -> Self {
        return copyInternal(coord: coord, entityFactory: entityFactory)
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.json = json
    }
    
    required init(json: [String : Any]) {
        self.json = json
    }

    func apply(sourceActor: Actor, targetActor: Actor, userInfo: [String: Any]) {
        if let healAmount = self.json["restore"] as? Int {
            sourceActor.hitPoints.restore(hitPoints: healAmount)
        }
    }

    // MARK: - Private
    
    private func copyInternal<T: Effect>(coord: vector_int2, entityFactory: EntityFactory) -> T {
        let entity = T(json: self.json, entityFactory: entityFactory)
        entity.coord = coord
        return entity
    }
}

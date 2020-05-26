//
//  Projectile.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 23/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class Projectile: Entity {
    required init(json: [String : Any], entityFactory: EntityFactory) {
        super.init(json: json, entityFactory: entityFactory)
    }
    
    func configureSprite(origin: vector_int2, target: vector_int2) {
        let direction = Direction.relative(from: origin, to: target)                
        let name = String(describing: direction)
        let spriteInfo = self.json["sprite"] as! [String: String]
        let spriteName = spriteInfo[name]!        
        self.sprite = Entity.loadSprite(type: self, spriteName: spriteName)
    }    
}

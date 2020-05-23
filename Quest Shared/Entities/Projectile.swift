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
        let y: Int32 = origin.y == target.y ? 0 : (origin.y > target.y ? -1 : 1)
        let x: Int32 = origin.x == target.x ? 0 : (origin.x > target.x ? -1 : 1)
        
        let direction = Direction(rawValue: vector_int2(x, y))
        let name = String(describing: direction)
        let spriteInfo = self.json["sprite"] as! [String: String]
        let spriteName = spriteInfo[name]!
        
        loadSprite(spriteName: spriteName)
    }
    
    private func loadSprite(spriteName: String) {
        let texture = SKTexture(imageNamed: spriteName)
        let sprite = SKSpriteNode(texture: texture, size: CGSize(width: 48, height: 48))
        
        sprite.zPosition = DrawLayerHelper.zPosition(for: self)

        self.sprite = sprite
    }
}

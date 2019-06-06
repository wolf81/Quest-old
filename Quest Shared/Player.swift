//
//  Player.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Player : Entity {
    override init(sprite: SKSpriteNode, coord: int2) {
        super.init(sprite: sprite, coord: coord)
        
        sprite.zPosition = 100
    }
}

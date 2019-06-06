//
//  Entity.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Entity {
    var coord: int2
    let sprite: SKSpriteNode
    
    init(sprite: SKSpriteNode, coord: int2) {
        self.sprite = sprite
        self.coord = coord
    }
}

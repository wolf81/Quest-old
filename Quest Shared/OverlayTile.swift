//
//  OverlayTile.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 10/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class OverlayTile: Entity {
    let isBlocked: Bool
    
    init(color: SKColor, coord: SIMD2<Int32>, isBlocked: Bool) {
        self.isBlocked = isBlocked
        
        let sprite = SKSpriteNode(
            color: color,
            size: CGSize(width: 64, height: 64)
        )
        sprite.zPosition = 1_000_000
                
        super.init(sprite: sprite, coord: coord)
        
        self.name = "Overlay"
    }
    
    required init(json: [String : Any]) {
        fatalError()
    }
}

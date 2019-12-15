//
//  OverlayTile.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 10/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class OverlayTile: Tile {
    let isBlocked: Bool
        
    init(color: SKColor, coord: SIMD2<Int32>, isBlocked: Bool) {
        self.isBlocked = isBlocked
        
        let sprite = SKSpriteNode(
            color: color,
            size: CGSize(width: 48, height: 48)
        )
        sprite.zPosition = 1_000_000
                
        super.init(sprite: sprite, coord: coord)
        
        self.name = "Overlay"
    }
    
    required init(json: [String : Any]) {
        fatalError()
    }
    
    required init(json: [String : Any], coord: vector_int2) {
        fatalError("init(json:coord:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

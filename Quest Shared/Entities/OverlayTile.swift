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
        
    init(color: SKColor, coord: vector_int2, isBlocked: Bool) {
        self.isBlocked = isBlocked
        
        let sprite = SKSpriteNode(
            color: color,
            size: Constants.tileSize
        )
                
        super.init(sprite: sprite, coord: coord)

        sprite.zPosition = DrawLayerHelper.zPosition(for: self)

        self.name = "Overlay"
    }
            
    required init(json: [String : Any], entityFactory: EntityFactory) {
        fatalError("init(json:entityFactory:) has not been implemented")
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory, coord: vector_int2) {
        fatalError("init(json:entityFactory:coord:) has not been implemented")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

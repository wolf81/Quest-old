//
//  Tile.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit
import GameplayKit

class Tile: Entity & TileProtocol {
    var didExplore: Bool = false;
                
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory, coord: vector_int2) {
        super.init(json: json, entityFactory: entityFactory, coord: coord)
    }
    
    init(sprite: SKSpriteNode, entityFactory: EntityFactory, coord: vector_int2) {
        super.init(json: ["name": "tile"], entityFactory: entityFactory, coord: coord)
        sprite.zPosition = DrawLayerHelper.zPosition(for: self)
        self.sprite = sprite
    }        
}

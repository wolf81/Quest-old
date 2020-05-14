//
//  FogTile.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 23/04/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class FogTile: EntityProtocol {
    var name: String = "Fog"
    
    lazy var sprite: SKSpriteNode = {
        let sprite = SKSpriteNode(color: .black, size: CGSize(width: 48, height: 48))
        sprite.zPosition = DrawLayerHelper.zPosition(for: self)
        return sprite
    }()
    
    private(set) var coord: vector_int2

    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.coord = vector_int2(0, 0)
    }
    
    required init(json: [String : Any], coord: vector_int2) {
        self.coord = coord
    }

    func copy(coord: vector_int2, entityFactory: EntityFactory) -> Self {
        return copyInternal(coord: coord, entityFactory: entityFactory)
    }
    
    private func copyInternal<T: FogTile>(coord: vector_int2, entityFactory: EntityFactory) -> T {
        return T(json: [:], coord: coord)
    }
}

//
//  Tile.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit
import GameplayKit

class Tile: GKGridGraphNode & TileProtocol {
    var coord: vector_int2 { return self.gridPosition }
    
    var didExplore: Bool = false;
    
    private(set) var json: [String: Any]

    lazy var name: String = {
        return self.json["name"] as! String;
    }()
    
    lazy var sprite: SKSpriteNode = {
        let spriteName = self.json["sprite"] as! String
        return Entity.loadSprite(type: self, spriteName: spriteName)
    }()
    
    required init(json: [String : Any], entityFactory: EntityFactory, coord: vector_int2) {
        self.json = json
        super.init(gridPosition: coord)
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.json = json
        super.init(gridPosition: vector_int2(0, 0))
    }
            
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(sprite: SKSpriteNode, coord: vector_int2) {
        self.json = [:]
        super.init(gridPosition: coord)
        sprite.zPosition = DrawLayerHelper.zPosition(for: self)
        self.sprite = sprite
    }
        
    func copy(coord: vector_int2, entityFactory: EntityFactory) -> Self {
        return copyInternal(coord: coord, entityFactory: entityFactory)
    }

    private func copyInternal<T: Tile>(coord: vector_int2, entityFactory: EntityFactory) -> T {
        return T(json: self.json, entityFactory: entityFactory, coord: coord)
    }
}

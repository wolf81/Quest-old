//
//  Decoration.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 28/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation
import SpriteKit

class Decoration: TileProtocol {
    private let json: [String: Any]
    
    lazy var name: String = { self.json["name"] as! String }()

    var sprite: SKSpriteNode = SKSpriteNode(color: .clear, size: Constants.tileSize)
        
    var coord: vector_int2 = vector_int2.zero
            
    var didExplore: Bool = false
            
    required init(json: [String : Any], entityFactory: EntityFactory, coord: vector_int2) {
        self.json = json
        self.coord = coord
    }        
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.json = json
    }
    
    func copy(coord: vector_int2, entityFactory: EntityFactory) -> Self {
        return copyInternal(coord: coord, entityFactory: entityFactory)
    }

    private func copyInternal<T: Decoration>(coord: vector_int2, entityFactory: EntityFactory) -> T {
        return T(json: self.json, entityFactory: entityFactory, coord: coord)
    }
    
    func configure(withTile tile: TileProtocol) {
        let spriteJson = self.json["sprite"]
        var spriteName: String
        
        if let spriteNames = spriteJson as? [String] {
            let spriteIdx = Int(arc4random_uniform(UInt32(spriteNames.count)))
            spriteName = spriteNames[spriteIdx]
        } else {
            spriteName = spriteJson as! String
        }
                
        let decorationSprite = Entity.loadSprite(type: self, spriteName: spriteName)
        let sprite = tile.sprite.copy() as! SKSpriteNode
        sprite.addChild(decorationSprite)
        self.sprite = sprite
        self.coord = tile.coord
    }
}

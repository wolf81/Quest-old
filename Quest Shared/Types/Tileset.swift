//
//  Tileset.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 25/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class Tileset: JSONConstructable {
    let floorTiles: [SKSpriteNode]
    let wallTiles: [SKSpriteNode]
    
    required init(json: [String : Any]) {        
        self.floorTiles = Tileset.getSprites(for: json["floorTiles"] as? [String] ?? [])
        self.wallTiles = Tileset.getSprites(for: json["wallTiles"] as? [String] ?? [])
    }
    
    // MARK: - Private
    
    private static func getSprites(for spriteNames: [String]) -> [SKSpriteNode] {
        var sprites: [SKSpriteNode] = []
        for spriteName in spriteNames {
            let texture = SKTexture(imageNamed: spriteName)
            let sprite = SKSpriteNode(texture: texture, size: Constants.tileSize)
            sprites.append(sprite)
        }
        return sprites
    }
}

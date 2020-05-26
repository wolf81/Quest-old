//
//  Tileset.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 25/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class Tileset: JSONConstructable {
    let name: String
    let floorTiles: [SKSpriteNode]
    let wallTiles: [SKSpriteNode]
    
    func getFloorTile() -> SKSpriteNode {
        let tileIdx = getRandomIndexEmphasizeZero(self.floorTiles.count)
        return self.floorTiles[tileIdx].copy() as! SKSpriteNode
    }
    
    func getWallTile() -> SKSpriteNode {
        let tileIdx = getRandomIndexEmphasizeZero(self.wallTiles.count)
        return self.wallTiles[tileIdx].copy() as! SKSpriteNode
    }
    
    required init(json: [String : Any]) {
        self.name = json["name"] as! String
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
        
    /// Retrieve a random index, but 0 will be returned most of the time
    /// - Parameter count: Amount of elements
    private func getRandomIndexEmphasizeZero(_ count: Int) -> Int {
        let tileIdx = arc4random_uniform(UInt32(count * 2))
        return tileIdx >= count ? 0 : Int(tileIdx)
    }
}

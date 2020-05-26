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
        let tileIdx = arc4random_uniform(UInt32(self.floorTiles.count))
        return self.floorTiles[Int(tileIdx)].copy() as! SKSpriteNode
    }
    
    func getWallTile() -> SKSpriteNode {
        let tileIdx = arc4random_uniform(UInt32(self.wallTiles.count))
        return self.wallTiles[Int(tileIdx)].copy() as! SKSpriteNode
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
    
    static func load(fileNamed filename: String) throws -> Tileset {
        let path = Bundle.main.path(forResource: filename, ofType: "json", inDirectory: "Data/Tileset")
        let url = URL(fileURLWithPath: path!)
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return Tileset(json: json as! [String: Any])
    }
}

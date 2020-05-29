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
    
    private let decorationNames: [String]
    
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
        
        self.decorationNames = json["decorations"] as? [String] ?? []
    }
    
    func getDecoration(coord: vector_int2, entityFactory: EntityFactory) -> Decoration? {
        guard self.decorationNames.count > 0 else { return nil }
        
        let decorationIdx = arc4random_uniform(UInt32(self.decorationNames.count))        
        let decorationName = decorationNames[Int(decorationIdx)]
                        
        let decoration = try! entityFactory.newEntity(type: Decoration.self, name: decorationName, coord: coord)
        return decoration
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

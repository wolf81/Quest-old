//
//  Tile.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit
import GameplayKit

class Tile: GKGridGraphNode, TileProtocol {
    var coord: vector_int2 { return self.gridPosition }
    
    private var json: [String: Any]

    lazy var name: String = {
        return self.json["name"] as! String;
    }()
    
    lazy var sprite: SKSpriteNode = {
        // TODO:
        // ideally we don't know the sprite size here or perhaps the textures should be of
        // appropriate size already - the game scene controls the tile size

        guard let spriteName = self.json["sprite"] as? String else {
            return SKSpriteNode(color: SKColor.lightGray, size: CGSize(width: 48, height: 48))
        }
        let texture = SKTexture(imageNamed: spriteName)
        return SKSpriteNode(texture: texture, size: CGSize(width: 48, height: 48))
    }()

    required init(json: [String : Any]) {
        self.json = json
        super.init(gridPosition: vector_int2(0, 0))
    }
    
    required init(json: [String: Any], coord: vector_int2) {
        self.json = json
        super.init(gridPosition: coord)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(sprite: SKSpriteNode, coord: vector_int2) {
        self.json = [:]
        super.init(gridPosition: coord)
        self.sprite = sprite
    }
    
    func copy(coord: vector_int2) -> Self {
        return copyInternal(coord: coord)
    }
    
    private func copyInternal<T: Tile>(coord: vector_int2) -> T {
        return T(json: self.json, coord: coord)
    }
}

//
//  Entity.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Entity: EntityProtocol & Hashable {
    static unowned var entityFactory: EntityFactory!
    
    static func == (lhs: Entity, rhs: Entity) -> Bool {
        return lhs.name == rhs.name && lhs.coord == rhs.coord
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.coord)        
    }
    
    var coord: SIMD2<Int32>
    
    private let json: [String: Any]
    
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
    
    required init(json: [String: Any]) {
        self.json = json
        self.coord = SIMD2<Int32>(0, 0)
    }
    
    func copy(coord: vector_int2) -> Self {
        return copyInternal(coord: coord)
    }
    
    private func copyInternal<T: Entity>(coord: vector_int2) -> T {
        let entity = T(json: self.json)
        entity.coord = coord
        return entity
    }
}

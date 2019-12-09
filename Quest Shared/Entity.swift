//
//  Entity.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Entity: JSONConstructable & Hashable {
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
            return SKSpriteNode(color: SKColor.lightGray, size: CGSize(width: 64, height: 64))
        }
        let texture = SKTexture(imageNamed: spriteName)        
        return SKSpriteNode(texture: texture, size: CGSize(width: 64, height: 64))
    }()
    
    required init(json: [String: Any]) {
        self.json = json
        self.coord = SIMD2<Int32>(0, 0)
    }
    
    init(sprite: SKSpriteNode, coord: SIMD2<Int32>) {
        self.json = [:]
        self.coord = coord
    }
        
    func copy() -> Self {
        return copyInternal()
    }
    
    private func copyInternal<T: Entity>() -> T {
        return T(json: self.json)
    }
}

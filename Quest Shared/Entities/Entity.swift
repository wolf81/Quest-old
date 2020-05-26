//
//  Entity.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Entity: EntityProtocol & Hashable {
    static func == (lhs: Entity, rhs: Entity) -> Bool {
        return lhs.name == rhs.name && lhs.coord == rhs.coord
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.coord)        
    }
    
    var coord: vector_int2
    
    private(set) var json: [String: Any]
    
    lazy var name: String = {
        return self.json["name"] as! String;
    }()
        
    lazy var sprite: SKSpriteNode = {
        guard let spriteName = self.json["sprite"] as? String else { fatalError() }        
        return Entity.loadSprite(type: self, spriteName: spriteName)
    }()
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.json = json
        self.coord = SIMD2<Int32>(0, 0)
    }
        
    func copy(coord: vector_int2, entityFactory: EntityFactory) -> Self {
        return copyInternal(coord: coord, entityFactory: entityFactory)
    }
    
    private func copyInternal<T: Entity>(coord: vector_int2, entityFactory: EntityFactory) -> T {
        let entity = T(json: self.json, entityFactory: entityFactory)
        entity.coord = coord
        return entity
    }
}

// MARK: - Sprite loading utilities

extension Entity {
    static func loadSprite<T: EntityProtocol>(type: T, spriteName: String) -> SKSpriteNode {
        // TODO:
        // ideally we don't know the sprite size here or perhaps the textures should be of
        // appropriate size already - the game scene controls the tile size
        
        let texture = SKTexture(imageNamed: spriteName)
        let sprite = SKSpriteNode(texture: texture, size: Constants.tileSize)
        
        sprite.zPosition = DrawLayerHelper.zPosition(for: type)

        return sprite
    }
    
    static func loadSprite<T: EntityProtocol>(type: T, spriteNames: [String]) -> SKSpriteNode {
        // TODO:
        // ideally we don't know the sprite size here or perhaps the textures should be of
        // appropriate size already - the game scene controls the tile size
        
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(Constants.tileSize.width), height: Int(Constants.tileSize.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        for spriteName in spriteNames {
            let image = Image(named: spriteName)!
            let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
            context!.draw(cgImage!, in: CGRect(origin: .zero, size: Constants.tileSize))
        }

        let result = context!.makeImage()!
        let texture = SKTexture(cgImage: result)
        
        let sprite = SKSpriteNode(texture: texture, size: Constants.tileSize)
        sprite.zPosition = DrawLayerHelper.zPosition(for: type)
        return sprite
    }
}

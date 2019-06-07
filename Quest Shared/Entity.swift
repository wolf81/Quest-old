//
//  Entity.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

protocol JSONConstructable {
    init(json: [String: Any])
}

class Entity : JSONConstructable {
    var coord: int2
    
    private let json: [String: Any]
    
    lazy var name: String = {
        return self.json["name"] as! String;
    }()
    
    lazy var sprite: SKSpriteNode = {
        guard let spriteName = self.json["sprite"] as? String else {
            return SKSpriteNode(color: SKColor.lightGray, size: CGSize(width: 64, height: 64))
        }
        let texture = SKTexture(imageNamed: spriteName)        
        return SKSpriteNode(texture: texture, size: CGSize(width: 64, height: 64))
    }()
    
    required init(json: [String: Any]) {
        self.json = json
        self.coord = int2(0, 0)
    }
    
    init(sprite: SKSpriteNode, coord: int2) {
        self.json = [:]
        self.coord = coord
    }
    
    func move(to position: CGPoint, duration: TimeInterval, completion: @escaping () -> Void) {
        let move = SKAction.sequence([
            SKAction.move(to: position, duration: duration),
            SKAction.run(completion)
        ])
        self.sprite.run(move)
    }
    
    func copy() -> Self {
        return copyInternal()
    }
    
    private func copyInternal<T: Entity>() -> T {
        return T(json: self.json)
    }
}

//
//  Door.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 24/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit
import GameplayKit

class Door: GKGridGraphNode & TileProtocol {
    var didExplore: Bool = false

    private(set) var json: [String: Any] = [:]
        
    lazy var name: String = { self.json["name"] as! String }()
    
    lazy var sprite: SKSpriteNode = {
        fatalError()
    }()
    
    var coord: vector_int2 { return self.gridPosition }

    var isOpen: Bool = false
            
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory, coord: vector_int2) {
        self.json = json
        
        super.init(gridPosition: coord)
        
        self.sprite = getSprite(isOpen: self.isOpen)
    }
    
    required init(json: [String : Any], entityFactory: EntityFactory) {
        self.json = json

        super.init(gridPosition: vector2(0, 0))

        self.sprite = getSprite(isOpen: self.isOpen)
    }
            
    func getSprite(isOpen: Bool) -> SKSpriteNode {
        let spriteInfo = self.json["sprite"] as! [String: String]
        let spriteName = spriteInfo[isOpen ? "open" : "closed"]!        
        return Entity.loadSprite(type: self, spriteName: spriteName)
    }
        
    func copy(coord: vector_int2, entityFactory: EntityFactory) -> Self {
        copyInternal(coord: coord, entityFactory: entityFactory)
    }

    private func copyInternal<T: Door>(coord: vector_int2, entityFactory: EntityFactory) -> T {
        return T(json: self.json, entityFactory: entityFactory, coord: coord)
    }
}

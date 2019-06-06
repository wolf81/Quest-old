//
//  Game.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class Game {
    private var level: Level!

    private(set) var entities: [Entity] = []

    var player: Player {
        get {
            return entities.filter({ $0 is Player }).first! as! Player
        }
    }
    
    func getTileAt(coord: int2) -> Tile? {
        return self.level.getTileAt(coord: coord)
    }
    
    func canMoveEntity(entity: Entity, toCoord coord: int2) -> Bool {
        guard let tile = self.getTileAt(coord: coord) else {
            return false
        }
        return tile.contains(.wall) == false
    }
    
    func start(scene: GameScene, levelIdx: Int = 0, tileSize: CGSize) {
        self.level = Level()
        
        var entities: [Entity] = []
        
        for y in (0 ..< level.height) {
            for x in (0 ..< level.width) {
                var entity: Entity!
                
                let coord = int2(Int32(x), Int32(y))
                let tile = level.getTileAt(coord: coord)
                let color : SKColor = tile.contains(.player) ? .blue : tile.contains(.wall) ? .darkGray : .gray
                let sprite = SKSpriteNode(texture: nil, color: color, size: tileSize)
                
                if tile.contains(.player) {
                    entity = Player(sprite: sprite, coord: coord)
                } else {
                    entity = Entity(sprite: sprite, coord: coord)
                }
                
                entities.append(entity)
            }
        }
        
        self.entities = entities
    }
    
    func update(_ deltaTime: TimeInterval) {
        // ...
    }    
}

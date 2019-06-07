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
    
    private let entityFactory: EntityFactory
    
    init(entityFactory: EntityFactory) {
        self.entityFactory = entityFactory
    }

    private(set) var entities: [Entity] = []

    var player: Player {
        get {
            return entities.filter({ $0 is Player }).first! as! Player
        }
    }
    
    func getTileAt(coord: int2) -> Int? {
        return self.level.getTileAt(coord: coord)
    }
    
    func canMoveEntity(entity: Entity, toCoord coord: int2) -> Bool {
        guard let tile = self.getTileAt(coord: coord) else {
            return false
        }
        return tile != 1
    }
    
    func start(scene: GameScene, levelIdx: Int = 0, tileSize: CGSize) {
        self.level = Level()
        
        var entities: [Entity] = []
                
        for y in (0 ..< level.height) {
            for x in (0 ..< level.width) {
                let coord = int2(Int32(x), Int32(y))
                let tile = level.getTileAt(coord: coord)
                var entity: Entity?

                switch tile {
                case 0: entity = entityFactory.newEntity(name: "floor")
                case 1: entity = entityFactory.newEntity(name: "wall")
                case 2: entity = entityFactory.newEntity(name: "stairs_up")
                case 3: entity = entityFactory.newEntity(name: "stairs_down")
                default: break
                }

                if let entity = entity {
                    entity.coord = coord
                    entities.append(entity)
                } else {
                    // TODO: Add dummy entity to indicate missing content?
                }
                
                if tile == 3 {
                    let monster = entityFactory.newEntity(name: "Human")!
                    monster.coord = coord
                    entities.append(monster)
                }
                
                if x == 8 && y == 5 {
                    let monster = entityFactory.newEntity(name: "Skeleton")!
                    monster.coord = coord
                    entities.append(monster)
                }
            }
        }
        
        self.entities = entities
    }
    
    func update(_ deltaTime: TimeInterval) {
        // ...
    }    
}

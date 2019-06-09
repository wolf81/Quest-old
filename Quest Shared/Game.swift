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
    
    private var activeActorIdx: Int = 0
    
    private var actors: [Actor] {
        return entities.filter({ $0 is Actor }) as! [Actor]
    }

    var hero: Hero {
        return entities.filter({ $0 is Hero }).first! as! Hero
    }
    
    func getTileAt(coord: int2) -> Int? {
        return self.level.getTileAt(coord: coord)
    }
    
    private func canMoveEntity(entity: Entity, toCoord coord: int2) -> Bool {
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
                    let player = entityFactory.newEntity(name: "Human")! as! Hero
                    player.attributes = [
                        .strength(12),
                        .dexterity(12),
                        .mind(12)
                    ]
                    player.coord = coord
                    entities.append(player)
                }

                if x == 8 && y == 5 {
                    let monster = entityFactory.newEntity(name: "Skeleton")!
                    monster.coord = coord
                    entities.append(monster)
                    
                    print(monster)
                }
                
                if x == 7 && y == 3 {
                    let monster = entityFactory.newEntity(name: "Skeleton")!
                    monster.coord = coord
                    entities.append(monster)
                    
                    print(monster)
                }
                
                if x == 8 && y == 1 {
                    let monster = entityFactory.newEntity(name: "Skeleton")!
                    monster.coord = coord
                    entities.append(monster)
                    
                    print(monster)
                }

            }
        }
        
        self.entities = entities
    }
    
    func update(_ deltaTime: TimeInterval) {
        // accept no input from player, until it's the turn of the player
        
        let activeActor = self.actors[self.activeActorIdx]
        
        guard let action = activeActor.getAction() else {
            return
        }
        
        action.perform()
        
        self.activeActorIdx = (self.activeActorIdx + 1) % self.actors.count
    }
    
    func movePlayer(direction: Direction) -> int2 {
        let coord = self.hero.coord &+ direction.coord
        
//        if let creature = self.actors.filter({ $0.coord == coord }).first {
//            // do attack ...?
//            return self.hero.coord
//        }

        guard self.canMoveEntity(entity: self.hero, toCoord: coord) else {
            return self.hero.coord
        }
        
        self.hero.setAction(MoveAction(actor: self.hero, coord: coord))
        
        return coord
    }
}

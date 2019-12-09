//
//  Game.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit
import DungeonBuilder

protocol GameDelegate: class {
    func gameDidMove(player: Hero, toCoord: SIMD2<Int32>, duration: TimeInterval)
}

class Game {
    private var level: Level!
    
    public weak var delegate: GameDelegate?
    
    private let entityFactory: EntityFactory
    
    private var isBusy: Bool = false
        
    init(entityFactory: EntityFactory, delegate: GameDelegate?) {
        self.delegate = delegate
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
    
    func getTileAt(coord: SIMD2<Int32>) -> Int? {
        return self.level.getTileAt(coord: coord)
    }
    
    func getActorAt(coord: SIMD2<Int32>) -> Actor? {
        return self.actors.filter({ $0.coord == coord }).first
    }
    
    func canMoveEntity(entity: Entity, toCoord coord: SIMD2<Int32>) -> Bool {
        guard actors.filter({ $0.coord == coord}).first == nil else {
            return false
        }

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
                let coord = SIMD2<Int32>(Int32(x), Int32(y))
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
                    let attributes = Attributes(strength: 16, dexterity: 12, mind: 8)
                    let skills = Skills(physical: 3, subterfuge: 0, knowledge: 0, communication: 0)
                    let armor = entityFactory.newEntity(name: "Studded Leather") as! Armor
                    let weapon = entityFactory.newEntity(name: "Longsword") as! Weapon
                    let equipment = Equipment(armor: armor, weapon: weapon)
                    let player = Hero(name: "Kendrick", race: .human, role: .fighter, attributes: attributes, skills: skills, equipment: equipment)
//                    let player = entityFactory.newEntity(name: "Human")! as! Hero
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
        guard self.isBusy == false else { return }

        let activeActor = self.actors[self.activeActorIdx]
        if activeActor.isAlive == false {
            print("\(activeActor.name) dies")
                        
            remove(actor: activeActor)

            return
        }
        
        guard let action = activeActor.getAction(state: self) else {
            return
        }
        
        // Start the action for the current actor ... make sure only 1 action is performed at any time
        self.isBusy = true
        guard action.perform(completion: { self.isBusy = false }) else {
            return
        }
        
        // If the hero moved, update camera position, so camera is always centered on the hero
        if let moveAction = action as? MoveAction, moveAction.actor == self.hero {
            self.delegate?.gameDidMove(player: self.hero, toCoord: moveAction.toCoord, duration: moveAction.duration)
        }
                
        self.activeActorIdx = (self.activeActorIdx + 1) % self.actors.count
    }
    
    func movePlayer(direction: Direction) {
        self.hero.move(direction: direction)
    }
    
    private func remove(actor: Actor) {
        actor.sprite.removeFromParent()
        
        self.entities.removeAll(where: { $0 == actor })

        // After we remove an actor, update the index to prevent an index out of range error
        self.activeActorIdx = self.activeActorIdx % self.actors.count
    }
}

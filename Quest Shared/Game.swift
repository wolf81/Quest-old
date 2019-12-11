//
//  Game.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit
import DungeonBuilder
import GameplayKit

protocol GameDelegate: class {
    func gameDidMove(hero: Hero, to coord: SIMD2<Int32>, duration: TimeInterval)
    func gameDidAdd(entity: Entity)
    func gameDidRemove(entity: Entity)
}

enum Mode {
    case `default`
    case selectTile
}

class Game {
    private var level: Level!
    
    public weak var delegate: GameDelegate?
    
    private let entityFactory: EntityFactory
    
    private(set) var hero: Hero
    
    private var isBusy: Bool = false
        
    private var tileSize: CGSize = .zero
    
    private var mode: Mode = .default
        
    init(entityFactory: EntityFactory, hero: Hero) {
        self.entityFactory = entityFactory
        self.hero = hero
    }

    private(set) var entities: [Entity] = []
    
    private var activeActorIdx: Int = 0
    
    private var actors: [Actor] {
        return self.entities.filter({ $0 is Actor }) as! [Actor]
    }
    
    func getTileAt(coord: SIMD2<Int32>) -> Int? {
        return self.level.getTileAt(coord: coord)
    }
    
    func getActorAt(coord: SIMD2<Int32>) -> Actor? {
        return self.actors.filter({ $0.coord == coord }).first
    }
    
    func canMove(entity: Entity, toCoord coord: SIMD2<Int32>) -> Bool {
        guard self.actors.filter({ $0.coord == coord}).first == nil else {
            return false
        }

        guard let tile = self.getTileAt(coord: coord) else {
            return false
        }
        
        return tile != 1
    }
    
    func showMovementTilesForHero() {
        guard self.actors[self.activeActorIdx] == self.hero && self.isBusy == false else { return }

        guard self.mode == .default else { return hideMovementTiles() }
                
        let xMin = max(self.hero.coord.x - Int32(self.hero.speed), 0)
        let xMax = min(self.hero.coord.x + Int32(self.hero.speed), Int32(self.level.width))
        let width = xMax - xMin + 1
        let yMin = max(self.hero.coord.y - Int32(self.hero.speed), 0)
        let yMax = min(self.hero.coord.y + Int32(self.hero.speed), Int32(self.level.height))
        let height = yMax - yMin + 1
        
        // Create a graph for the visible area
        var nodesToRemove: [GKGraphNode] = []

        let visibleAreaGraph = GKGridGraph(fromGridStartingAt: vector_int2(xMin, yMin), width: width, height: height, diagonalsAllowed: false)
        let movementGraph = GKGridGraph(fromGridStartingAt: vector_int2(xMin, yMin), width: width, height: height, diagonalsAllowed: false)
        for x in visibleAreaGraph.gridOrigin.x ..< (visibleAreaGraph.gridOrigin.x + Int32(visibleAreaGraph.gridWidth)) {
            for y in visibleAreaGraph.gridOrigin.y ..< (visibleAreaGraph.gridOrigin.y + Int32(visibleAreaGraph.gridHeight)) {
                let coord = SIMD2<Int32>(x, y)

                if isInCircle(origin: self.hero.coord, radius: self.hero.speed, coord: coord) == false {
                    if let node = visibleAreaGraph.node(atGridPosition: coord) {
                        visibleAreaGraph.remove([node])
                        if let movementGraphNode = movementGraph.node(atGridPosition: coord) {
                            movementGraph.remove([movementGraphNode])
                        }
                    }
                }
                
                if getTileAt(coord: coord) == 1 {
                    if let node = visibleAreaGraph.node(atGridPosition: coord) {
                        visibleAreaGraph.remove([node])

                        if let movementGraphNode = movementGraph.node(atGridPosition: coord) {
                            movementGraph.remove([movementGraphNode])
                        }
                    }
                }
            }
        }
        
        let actorCoords = self.actors.filter({ $0.coord != hero.coord }).compactMap({ $0.coord })
        for node in movementGraph.nodes ?? [] {
            let nodeCoord = (node as! GKGridGraphNode).gridPosition
            if actorCoords.contains(nodeCoord) {
                nodesToRemove.append(node)
            }
        }
        movementGraph.remove(nodesToRemove)

        let heroNode = movementGraph.node(atGridPosition: self.hero.coord)!
        for node in movementGraph.nodes ?? [] {
            let pathNodes = heroNode.findPath(to: node)
            if pathNodes.count == 0 {
                let nodeCoord = (node as! GKGridGraphNode).gridPosition
                print("could not find path to: \(nodeCoord.x).\(nodeCoord.y)")
                movementGraph.remove([node])
//            } else {
//                var path = "\(self.hero.coord.x).\(self.hero.coord.y)"
//                for pathNode in pathNodes {
//                    let pathNodeCoord = (pathNode as! GKGridGraphNode).gridPosition
//                    path += " -> \(pathNodeCoord.x).\(pathNodeCoord.y)"
//                }
//                print(path)
            }
        }
        
        // Compare visible area graph and movement graph and show appropriate tile colors depending if a tile is reachable or not
        for x in visibleAreaGraph.gridOrigin.x ... visibleAreaGraph.gridOrigin.x + Int32(visibleAreaGraph.gridWidth) {
            for y in visibleAreaGraph.gridOrigin.y ... visibleAreaGraph.gridOrigin.y + Int32(visibleAreaGraph.gridHeight) {
                let coord = SIMD2<Int32>(x,y)
                guard coord != self.hero.coord else { continue }
                
                if let _ = visibleAreaGraph.node(atGridPosition: coord) {
                    if let _ = movementGraph.node(atGridPosition: coord) {
                        let movementTile = OverlayTile(color: SKColor.green.withAlphaComponent(0.5), coord: coord)
                        self.entities.append(movementTile)
                        self.delegate?.gameDidAdd(entity: movementTile)
                    }
                    else {
                        let movementTile = OverlayTile(color: SKColor.red.withAlphaComponent(0.5), coord: coord)
                        self.entities.append(movementTile)
                        self.delegate?.gameDidAdd(entity: movementTile)
                    }
                }
            }
        }
        
        self.mode = .selectTile
    }
    
    func isInCircle(origin: SIMD2<Int32>, radius: Int, coord: SIMD2<Int32>) -> Bool {
        return ((coord.x - origin.x) * (coord.x - origin.x) + (coord.y - origin.y) * (coord.y - origin.y)) <= (radius * radius)
    }
    
    func hideMovementTiles() {
        guard self.mode == .selectTile else { return }
        
        let tiles = self.entities.filter({ $0 is OverlayTile })

        self.entities.removeAll(where: { tiles.contains($0 )})

        tiles.forEach({ self.delegate?.gameDidRemove(entity: $0) })
        
        self.mode = .default
    }
    
    func start(levelIdx: Int = 0, tileSize: CGSize) {
        self.level = Level()
        self.tileSize = tileSize
        
        var entities: [Entity] = []
                
        for y in (0 ..< self.level.height) {
            for x in (0 ..< self.level.width) {
                let coord = SIMD2<Int32>(Int32(x), Int32(y))
                let tile = self.level.getTileAt(coord: coord)
                var entity: Entity?

                switch tile {
                case 0: entity = try! entityFactory.newEntity(name: "floor")
                case 1: entity = try! entityFactory.newEntity(name: "wall")
                case 2: entity = try! entityFactory.newEntity(name: "stairs_up")
                case 3: entity = try! entityFactory.newEntity(name: "stairs_down")
                default: break
                }

                if let entity = entity {
                    entity.coord = coord
                    entities.append(entity)
                } else {
                    // TODO: Add dummy entity to indicate missing content?
                }
                
                if tile == 3 {
                    self.hero.coord = coord
                    entities.append(self.hero)
                    
                    print(self.hero)
                }

                if x == 4 && y == 1 {
                    let monster = try! entityFactory.newEntity(name: "Skeleton")
                    monster.coord = coord
                    entities.append(monster)
                    
                    print(monster)
                }

                if x == 4 && y == 2 {
                    let monster = try! entityFactory.newEntity(name: "Skeleton")
                    monster.coord = coord
                    entities.append(monster)
                    
                    print(monster)
                }

                if x == 5 && y == 3 {
                    let monster = try! entityFactory.newEntity(name: "Skeleton")
                    monster.coord = coord
                    entities.append(monster)
                    
                    print(monster)
                }

                if x == 7 && y == 3 {
                    let monster = try! entityFactory.newEntity(name: "Skeleton")
                    monster.coord = coord
                    entities.append(monster)
                    
                    print(monster)
                }
                
                if x == 8 && y == 1 {
                    let monster = try! entityFactory.newEntity(name: "Skeleton")
                    monster.coord = coord
                    entities.append(monster)
                    
                    print(monster)
                }
            }
        }
        
        self.entities = entities
    }
    
    func update(_ deltaTime: TimeInterval) {
        // If the game is busy for any reason (e.g. show animation), wait until ready
        guard self.isBusy == false else { return }

        let activeActor = self.actors[self.activeActorIdx]
        
        // If the current actor died, remove from play and continue with next actor
        if activeActor.isAlive == false {
            print("\(activeActor.name) dies")
            remove(actor: activeActor)
            return
        }
        
        // Wait until the current active actor performs an action
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
            self.delegate?.gameDidMove(hero: self.hero, to: moveAction.toCoord, duration: moveAction.duration)
        }
                
        // Activate next actor
        self.activeActorIdx = (self.activeActorIdx + 1) % self.actors.count
    }
    
    func movePlayer(direction: Direction) {
        hideMovementTiles()
                
        self.hero.move(direction: direction)
    }
    
    private func remove(actor: Actor) {
        self.entities.removeAll(where: { $0 == actor })

        // After we remove an actor, update the index to prevent an index out of range error
        self.activeActorIdx = self.activeActorIdx % self.actors.count
        
        self.delegate?.gameDidRemove(entity: actor)
    }
}

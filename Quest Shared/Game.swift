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
    func gameDidMove(hero: Hero, path path: [vector_int2], duration: TimeInterval)
    func gameDidAdd(entity: Entity)
    func gameDidRemove(entity: Entity)
}

enum Mode {
    case `default`
    case selectDestinationTile
    case selectMeleeTarget
    case selectSpellTarget(Spell.Type)
    case selectRangedTarget
    
    var isSelection: Bool {
        switch self {
        case .selectDestinationTile: fallthrough
        case .selectMeleeTarget: fallthrough
        case .selectRangedTarget: fallthrough
        case .selectSpellTarget(_): return true
        case .default: return false
        }
    }
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
    
    var actors: [Actor] {
        return self.entities.filter({ $0 is Actor }) as! [Actor]
    }
    
    func getTileAt(coord: vector_int2) -> Int? {
        return self.level.getTileAt(coord: coord)
    }
    
    func getActorAt(coord: vector_int2) -> Actor? {
        return self.actors.filter({ $0.coord == coord }).first
    }
    
    func canMove(entity: Entity, toCoord coord: vector_int2) -> Bool {
        guard self.actors.filter({ $0.coord == coord}).first == nil else {
            return false
        }

        guard let tile = self.getTileAt(coord: coord) else {
            return false
        }
        
        return tile != 1
    }
    
    func getMovementGraph(for actor: Actor, range: Int, excludedCoords: [vector_int2]) -> GKGridGraph<GKGridGraphNode> {
        let xMin = max(actor.coord.x - Int32(range), 0)
        let xMax = min(actor.coord.x + Int32(range + 1), Int32(self.level.width))
        let width = xMax - xMin
        let yMin = max(actor.coord.y - Int32(range), 0)
        let yMax = min(actor.coord.y + Int32(range + 1), Int32(self.level.height))
        let height = yMax - yMin
        
        // Create a graph for the visible area
        let movementGraph = GKGridGraph(fromGridStartingAt: vector_int2(xMin, yMin), width: width, height: height, diagonalsAllowed: false)
        for x in movementGraph.gridOrigin.x ..< (movementGraph.gridOrigin.x + Int32(movementGraph.gridWidth)) {
            for y in movementGraph.gridOrigin.y ..< (movementGraph.gridOrigin.y + Int32(movementGraph.gridHeight)) {
                let coord = vector_int2(x, y)

                if isInRange(origin: actor.coord, radius: range, coord: coord) == false || getTileAt(coord: coord) == 1 {
                    if let node = movementGraph.node(atGridPosition: coord) {
                        movementGraph.remove([node])
                    }
                }
                
                if excludedCoords.contains(coord) {
                    if let movementGraphNode = movementGraph.node(atGridPosition: coord) {
                        movementGraph.remove([movementGraphNode])
                    }
                }
            }
        }
        
        let actorNode = movementGraph.node(atGridPosition: actor.coord)!
        for node in movementGraph.nodes ?? [] {
            let pathNodes = actorNode.findPath(to: node)
            if pathNodes.count == 0 {
                let nodeCoord = (node as! GKGridGraphNode).gridPosition
                print("could not find path to: \(nodeCoord.x).\(nodeCoord.y)")
                movementGraph.remove([node])
            }
        }
        
        return movementGraph
    }
    
    func isHeroVisible(for actor: Actor) -> Bool {
        guard self.hero.isAlive else { return false }
        
        let sightRange = Int32(actor.sight)
        let xRange = actor.coord.x - sightRange ... actor.coord.x + sightRange
        let yRange = actor.coord.y - sightRange ... actor.coord.y + sightRange
        return xRange.contains(self.hero.coord.x) && yRange.contains(self.hero.coord.y)
    }
    
    func getVisiblityGraph(for actor: Actor) -> GKGridGraph<GKGridGraphNode> {
        let xMin = max(actor.coord.x - Int32(actor.speed), 0)
        let xMax = min(actor.coord.x + Int32(actor.speed + 1), Int32(self.level.width))
        let width = xMax - xMin
        let yMin = max(actor.coord.y - Int32(actor.speed), 0)
        let yMax = min(actor.coord.y + Int32(actor.speed + 1), Int32(self.level.height))
        let height = yMax - yMin
        
        // Create a graph for the visible area
        let visibleAreaGraph = GKGridGraph(fromGridStartingAt: vector_int2(xMin, yMin), width: width, height: height, diagonalsAllowed: false)
        for x in visibleAreaGraph.gridOrigin.x ..< (visibleAreaGraph.gridOrigin.x + Int32(visibleAreaGraph.gridWidth)) {
            for y in visibleAreaGraph.gridOrigin.y ..< (visibleAreaGraph.gridOrigin.y + Int32(visibleAreaGraph.gridHeight)) {
                let coord = vector_int2(x, y)

                if isInRange(origin: actor.coord, radius: actor.speed, coord: coord) == false || getTileAt(coord: coord) == 1 {
                    if let node = visibleAreaGraph.node(atGridPosition: coord) {
                        visibleAreaGraph.remove([node])
                    }
                }
            }
        }
                
        return visibleAreaGraph
    }
    
    func showMovementTilesForHero() {
        guard self.actors[self.activeActorIdx] == self.hero && self.isBusy == false else { return }

        if mode.isSelection { hideSelectionTiles() }
        
        let actorCoords = self.actors.filter({ $0.coord != self.hero.coord }).compactMap({ $0.coord })
        let movementGraph = getMovementGraph(for: self.hero, range: self.hero.speed, excludedCoords: actorCoords)
        let visibleAreaGraph = getVisiblityGraph(for: self.hero)
        
        // Compare visible area graph and movement graph and show appropriate tile colors depending if a tile is reachable or not
        for x in visibleAreaGraph.gridOrigin.x ..< visibleAreaGraph.gridOrigin.x + Int32(visibleAreaGraph.gridWidth) {
            for y in visibleAreaGraph.gridOrigin.y ..< visibleAreaGraph.gridOrigin.y + Int32(visibleAreaGraph.gridHeight) {
                let coord = vector_int2(x,y)
                guard coord != self.hero.coord else { continue }
                
                if let _ = visibleAreaGraph.node(atGridPosition: coord) {
                    if let _ = movementGraph.node(atGridPosition: coord) {
                        let movementTile = OverlayTile(color: SKColor.green.withAlphaComponent(0.4), coord: coord, isBlocked: false)
                        self.entities.append(movementTile)
                        self.delegate?.gameDidAdd(entity: movementTile)
                    } else {
                        let movementTile = OverlayTile(color: SKColor.green.withAlphaComponent(0.1), coord: coord, isBlocked: true)
                        self.entities.append(movementTile)
                        self.delegate?.gameDidAdd(entity: movementTile)
                    }
                }
            }
        }
        
        self.mode = .selectDestinationTile
    }
    
    func showTargetTilesForSpellType<T: Spell>(spellType: T.Type) {
        if spellType is SingleTargetDamageSpell.Type {
            showRangedAttackTilesForHero()
            
            self.mode = .selectSpellTarget(spellType)
        }
    }
    
    func showRangedAttackTilesForHero() {
        guard self.actors[self.activeActorIdx] == self.hero && self.isBusy == false else { return }

        if mode.isSelection { hideSelectionTiles() }

        let attackRange = Int32(self.hero.equipment.rangedWeapon.range)
        let xRange = self.hero.coord.x - attackRange ... self.hero.coord.x + attackRange
        let yRange = self.hero.coord.y - attackRange ... self.hero.coord.y + attackRange
        
        let actorCoords = self.actors.filter({ $0 != self.hero }).compactMap({ $0.coord })
        for actorCoord in actorCoords {
            if xRange.contains(actorCoord.x) && yRange.contains(actorCoord.y) {
                let movementTile = OverlayTile(color: SKColor.orange.withAlphaComponent(0.4), coord: actorCoord, isBlocked: true)
                self.entities.append(movementTile)
                self.delegate?.gameDidAdd(entity: movementTile)
            }
        }
        
        self.mode = .selectRangedTarget
    }
    
    func showMeleeAttackTilesForHero() {
        guard self.actors[self.activeActorIdx] == self.hero && self.isBusy == false else { return }

        if mode.isSelection { hideSelectionTiles() }

        let xRange = self.hero.coord.x - 1 ... self.hero.coord.x + 1
        let yRange = self.hero.coord.y - 1 ... self.hero.coord.y + 1
        
        let actorCoords = self.actors.filter({ $0 != self.hero }).compactMap({ $0.coord })
        for actorCoord in actorCoords {
            if xRange.contains(actorCoord.x) && yRange.contains(actorCoord.y) {
                let movementTile = OverlayTile(color: SKColor.red.withAlphaComponent(0.4), coord: actorCoord, isBlocked: true)
                self.entities.append(movementTile)
                self.delegate?.gameDidAdd(entity: movementTile)
            }
        }
        
        self.mode = .selectMeleeTarget
    }
        
    func hideSelectionTiles() {
        guard self.mode.isSelection else { return }
        
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
                let coord = vector_int2(Int32(x), Int32(y))
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

                let monsterCoords = [vector_int2(8, 6), vector_int2(18, 3), vector_int2(22, 8)]
                for monsterCoord in monsterCoords where monsterCoord == coord {
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
                
        // Wait until the current active actor performs an action
        guard let action = activeActor.getAction(state: self) else {
            return
        }

        print(action.message)

        // Start the action for the current actor ... make sure only 1 action is performed at any time
        self.isBusy = true
        guard action.perform(completion: { self.isBusy = false }) else {
            return self.isBusy = false
        }
                
        switch action {
        case let moveAction as MoveAction:
            if let hero = activeActor as? Hero {
                print("move hero")
                
//                self.delegate?.gameDidMove(hero: hero, to: moveAction.toCoord, duration: moveAction.duration)
                self.delegate?.gameDidMove(hero: hero, path: moveAction.path, duration: moveAction.duration)
            }
        case _ as DieAction:
            remove(actor: activeActor)
        default: break
        }
                
        // Activate next actor
        self.activeActorIdx = (self.activeActorIdx + 1) % self.actors.count
    }
    
    func movePlayer(direction: Direction) {
        hideSelectionTiles()
                
        self.hero.move(direction: direction)
    }
    
    private func remove(actor: Actor) {
        self.entities.removeAll(where: { $0 == actor })                

        // After we remove an actor, update the index to prevent an index out of range error
        self.activeActorIdx = self.activeActorIdx % self.actors.count
        
        self.delegate?.gameDidRemove(entity: actor)
    }
    
    public func handleInteraction(at coord: vector_int2) {
        guard self.mode.isSelection else { return }

        let overlayTiles = self.entities.filter({ $0 is OverlayTile }) as! [OverlayTile]

        switch self.mode {
        case .selectDestinationTile:
            if let destinationTile = overlayTiles.filter({ $0.coord == coord }).first, destinationTile.isBlocked == false {
                let actorCoords = self.actors.filter({ $0.coord != self.hero.coord }).compactMap({ $0.coord })
                let graph = getMovementGraph(for: self.hero, range: self.hero.speed, excludedCoords: actorCoords)
                                
                if let startNode = graph.node(atGridPosition: self.hero.coord), let endNode = graph.node(atGridPosition: destinationTile.coord) {
                    let nodes = graph.findPath(from: startNode, to: endNode) as! [GKGridGraphNode]
                    let path = nodes.compactMap({ $0.gridPosition })
                    self.hero.move(path: path)
                }
            }
        case .selectMeleeTarget:
            if let targetActor = self.actors.filter({ $0.coord == coord }).first {
                self.hero.attackMelee(actor: targetActor)
            }
        case .selectRangedTarget:
            if let targetActor = self.actors.filter({ $0.coord == coord }).first {
                self.hero.attackRanged(actor: targetActor)
            }
        case .default: break
        case .selectSpellTarget(let spellType):
            if let singleTargetDamageSpellType = spellType as? SingleTargetDamageSpell.Type,
                let targetActor = self.actors.filter({ $0.coord == coord }).first {
                let spell = singleTargetDamageSpellType.init(actor: self.hero, targetActor: targetActor)
                self.hero.cast(spell: spell)
            }
            break
        }

        hideSelectionTiles()
    }
}

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
import Fenris

protocol GameDelegate: class {
    func gameDidMove(entity: Entity, path: [vector_int2])
    func gameDidAdd(entity: EntityProtocol)
    func gamedidDestroy(entity: EntityProtocol)

    func gameDidUpdateStatus(message: String)
    func gameDidAttack(actor: Actor, targetActor: Actor)
    
    func gameDidChangeSelectionMode(_ selectionMode: SelectionMode)
}

enum SelectionMode {
    case none
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
        case .none: return false
        }
    }
}

class Game {
    public var level: Level!
    
    public weak var delegate: GameDelegate?
    
    private let entityFactory: EntityFactory
    
    private(set) var hero: Hero
            
    private var tileSize: CGSize = .zero
    
    private var selectionMode: SelectionMode = .none {
        didSet {
            self.delegate?.gameDidChangeSelectionMode(self.selectionMode)
        }
    }
        
    public var turnDuration: TimeInterval = 6
    
    private var visibility: Visibility!
            
    init(entityFactory: EntityFactory, hero: Hero) {
        self.entityFactory = entityFactory
        self.hero = hero
    }

    // all currently existing entities (players, monsters, loot), entities that are destroyed are removed
    private(set) var entities: [Entity] = []
            
    // level tiles used for walls, floor, etc...
    private(set) var tiles: [[Tile]] = []

    // coordinates of tiles that are currently visible for the player
    private(set) var actorVisibleCoords = Set<vector_int2>()

    var viewVisibleCoords = Set<vector_int2>()

//    private(set) var selectionModeCoords = Set<vector_int2>()
    private(set) var selectionModeTiles: [OverlayTile] = []
    
    // the current active actor, either a player or monster
    private var activeActorIdx: Int = 0
    
    // a list of dungeon loot
    var loot: [Lootable] { self.entities.filter({ $0 is Lootable }) as! [Lootable] }

    var actors: [Actor] { self.entities.filter({ $0 is Actor }) as! [Actor] }
    
    var monsters: [Monster] { self.entities.filter({ $0 is Monster }) as! [Monster] }
    
    var activeActors: [Actor] = []
    
    var actions: [Action] = []
    
    // get a value for a tile at a coordinate, can be nil when out of range and is otherwise some integer value that represents a wall, floor or other scenery
    func getTile(at coord: vector_int2) -> Int? {
        self.level[coord]
    }
    
    func getActor(at coord: vector_int2) -> Actor? {
        return self.actors.filter({ $0.coord == coord }).first
    }
    
    func getLoot(at coord: vector_int2) -> Lootable? {
        return self.loot.filter({ $0.coord == coord}).first
    }
    
    func canMove(entity: Entity, to coord: vector_int2) -> Bool {
        guard self.actors.filter({ $0.coord == coord}).first == nil else {
            return false
        }

        guard let tile = self.getTile(at: coord) else {
            return false
        }
        
        return tile != 1
    }
    
    func getRange(position: Int32, radius: Int32, constrainedTo range: Range<Int32>) -> Range<Int32> {
        let minValue = max(position - radius, range.lowerBound)
        let maxValue = min(position + radius + 1, range.upperBound)
        return Int32(minValue) ..< Int32(maxValue)
    }
    
    func getMovementGraph(for actor: Actor, range: Int32, excludedCoords: [vector_int2]) -> GKGridGraph<GKGridGraphNode> {
        let xRange = getRange(position: actor.coord.x, radius: range, constrainedTo: 0 ..< self.level.width)
        let width = xRange.upperBound - xRange.lowerBound
        let yRange = getRange(position: actor.coord.y, radius: range, constrainedTo: 0 ..< self.level.height)
        let height = yRange.upperBound - yRange.lowerBound
        
        // Create a graph for the visible area
        let movementGraph = GKGridGraph(fromGridStartingAt: vector_int2(xRange.lowerBound, yRange.lowerBound), width: width, height: height, diagonalsAllowed: false)
        for x in movementGraph.gridOrigin.x ..< (movementGraph.gridOrigin.x + Int32(movementGraph.gridWidth)) {
            for y in movementGraph.gridOrigin.y ..< (movementGraph.gridOrigin.y + Int32(movementGraph.gridHeight)) {
                let coord = vector_int2(x, y)
                                
                if self.actorVisibleCoords.contains(coord) == false || getTile(at: coord) == 1 {
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
        
        if let actorNode = movementGraph.node(atGridPosition: actor.coord) {
            for node in movementGraph.nodes ?? [] {
                let pathNodes = actorNode.findPath(to: node)
                if pathNodes.count == 0 {
                    movementGraph.remove([node])
                }
            }
        }

        return movementGraph
    }

    func isVisible(for actor: Actor, coord: vector_int2) -> Bool {
        let x1 = actor.coord.x
        let y1 = actor.coord.y
        
        let x2 = coord.x
        let y2 = coord.y
        
        let x = pow(Float(x2 - x1), 2)
        let y = pow(Float(y2 - y1), 2)
        return Int(sqrt(x + y)) <= actor.sight
    }
    
    private func getVisiblityGraph(for actor: Actor) -> GKGridGraph<GKGridGraphNode> {
        let radius: Int32 = 1
        let xRange = getRange(position: actor.coord.x, radius: radius, constrainedTo: 0 ..< self.level.width)
        let width = xRange.upperBound - xRange.lowerBound
        let yRange = getRange(position: actor.coord.y, radius: radius, constrainedTo: 0 ..< self.level.height)
        let height = yRange.upperBound - yRange.lowerBound

        // Create a graph for the visible area
        let visibleAreaGraph = GKGridGraph(fromGridStartingAt: vector_int2(xRange.lowerBound, yRange.lowerBound), width: width, height: height, diagonalsAllowed: false)
        for x in visibleAreaGraph.gridOrigin.x ..< (visibleAreaGraph.gridOrigin.x + Int32(visibleAreaGraph.gridWidth)) {
            for y in visibleAreaGraph.gridOrigin.y ..< (visibleAreaGraph.gridOrigin.y + Int32(visibleAreaGraph.gridHeight)) {
                let coord = vector_int2(x, y)

                if isInRange(origin: actor.coord, radius: radius, coord: coord) == false || getTile(at: coord) == 1 {
                    if let node = visibleAreaGraph.node(atGridPosition: coord) {
                        visibleAreaGraph.remove([node])
                    }
                }
            }
        }
                
        return visibleAreaGraph
    }
    
    // MARK: - Public
    
    func showMovementTilesForHero() {
        self.selectionModeTiles.removeAll()
        
        let coords: [vector_int2] = [
            vector_int2(self.hero.coord.x - 1, self.hero.coord.y),
            vector_int2(self.hero.coord.x + 1, self.hero.coord.y),
            vector_int2(self.hero.coord.x, self.hero.coord.y - 1),
            vector_int2(self.hero.coord.x, self.hero.coord.y + 1),
        ]
        
        for coord in coords {
            if self.getTile(at: coord) == 0 && self.monsters.filter({ $0.coord == coord }).count == 0 {
                self.selectionModeTiles.append(OverlayTile(color: SKColor.green.withAlphaComponent(0.5), coord: coord, isBlocked: false))
            }
        }
                                    
        self.selectionMode = .selectDestinationTile
    }
    
    func showTargetTilesForSpellType<T: Spell>(spellType: T.Type) {
        if spellType is SingleTargetDamageSpell.Type {
            showRangedAttackTilesForHero()
            
            self.selectionMode = .selectSpellTarget(spellType)
        }
    }
    
    func showRangedAttackTilesForHero() {
        return
        
//        guard self.actors[self.activeActorIdx] == self.hero && self.isBusy == false else { return }
//
//        if selectionMode.isSelection { hideSelectionTiles() }
//
//        let attackRange = Int32(self.hero.equipment.rangedWeapon.range)
//        let xRange = self.hero.coord.x - attackRange ... self.hero.coord.x + attackRange
//        let yRange = self.hero.coord.y - attackRange ... self.hero.coord.y + attackRange
//        
//        let actorCoords = self.actors.filter({ $0 != self.hero }).compactMap({ $0.coord })
//        for actorCoord in actorCoords {
//            if xRange.contains(actorCoord.x) && yRange.contains(actorCoord.y) {
//                let movementTile = OverlayTile(color: SKColor.orange.withAlphaComponent(0.4), coord: actorCoord, isBlocked: true)
//                self.tiles.append(movementTile)
//                self.delegate?.gameDidAdd(entity: movementTile)
//            }
//        }
//        
//        self.selectionMode = .selectRangedTarget
    }
    
    func showMeleeAttackTilesForHero() {
        self.selectionModeTiles.removeAll()
        
        let xRange = self.hero.coord.x - 1 ... self.hero.coord.x + 1
        let yRange = self.hero.coord.y - 1 ... self.hero.coord.y + 1
        
        for x in xRange {
            for y in yRange {
                let coord = vector_int2(x, y)
                
                if coord == self.hero.coord { continue }
        
                if let _ = self.monsters.filter({ $0.coord == coord }).first {
                    self.selectionModeTiles.append(OverlayTile(color: SKColor.red.withAlphaComponent(0.5), coord: coord, isBlocked: false))
                }
            }
        }
        
        self.selectionMode = .selectMeleeTarget
    }
            
    func start(levelIdx: Int = 0, tileSize: CGSize) {
        self.level = Level()
        print(self.level!)
        
        self.tileSize = tileSize
        
        let mapSize = CGSize(width: Int(self.level.width), height: Int(self.level.height))
        self.visibility = RaycastVisibility(mapSize: mapSize, blocksLight: {
            self.level[$0] != 0
        }, setVisible: {
            self.actorVisibleCoords.insert($0)
        }, getDistance: {
            let x = pow(Float($1.x - $0.x), 2)
            let y = pow(Float($1.y - $0.y), 2)
            return Int(sqrt(x + y))
        })
        
        var entities: [Entity] = []
        var tiles: [[Tile]] = []
        var fogTiles: [FogTile] = []
        
        var didAddHero = false
                
        var roomPotionInfo: [UInt: vector_int2] = [:]
        
        for y in (0 ..< self.level.height) {
            var tileRow: [Tile] = []
            
            for x in (0 ..< self.level.width) {
                let coord = vector_int2(Int32(x), Int32(y))
                let tile = self.level[coord]
                var entity: EntityProtocol?

                switch tile {
                case 0: entity = try! entityFactory.newEntity(type: Tile.self, name: "floor", coord: coord)
                case 1: entity = try! entityFactory.newEntity(type: Tile.self, name: "wall", coord: coord)
                case 2: entity = try! entityFactory.newEntity(type: Tile.self, name: "stairs_up", coord: coord)
                case 3: entity = try! entityFactory.newEntity(type: Tile.self, name: "stairs_down", coord: coord)
                default: break
                }

                if let entity = entity {
                    tileRow.append(entity as! Tile)
                } else {
                    // TODO: Add dummy entity to indicate missing content?
                }
                
                let fogTile = FogTile(json: [:], coord: coord)
                fogTiles.append(fogTile)
                
                if let roomId = level.getRoomId(at: coord), roomPotionInfo[roomId] == nil, [2, 8, 9].contains(roomId), let room = level.roomInfo[roomId] {
                    let coord = vector_int2(Int32(room.coord.x + room.width - 2), Int32(room.coord.y + room.height - 2))
                    let potion = try! entityFactory.newEntity(type: Potion.self, name: "Health Potion", coord: coord)
                    entities.append(potion)
                    print("potion added to room: \(roomId) @ \(coord.x).\(coord.y)")
                    
                    roomPotionInfo[roomId] = coord
                }
                
                if !didAddHero, let roomId = level.getRoomId(at: coord) {
                    print("level size: \(self.level.width) x \(self.level.height)")
                    print("hero added to room: \(roomId) @ \(coord.x).\(coord.y)")
                    self.hero.coord = coord
                    entities.append(self.hero)
                    print(self.hero)
                    
                    didAddHero = true
                }
            }
            tiles.append(tileRow)
        }
        
        var monsterCount = 0
        for (roomId, room) in self.level.roomInfo {
            // TODO: fix room coord calc in DungeonBuilder, so we don't have to do the following to get good coords ...
            let roomCoord = vector_int2(Int32(room.coord.x + room.width / 2), Int32(room.coord.y + room.height / 2))
            
            print("\(roomId): \(room.coord.x).\( room.coord.y) -> \(roomCoord.x).\(roomCoord.y)")
            let isEven = monsterCount.remainderReportingOverflow(dividingBy: 2).partialValue == 0
            let monster = try! entityFactory.newEntity(type: Monster.self, name: isEven ? "Gnoll" : "Skeleton", coord: roomCoord)
            entities.append(monster)
            
            monsterCount += 1
        }
        
        self.tiles = tiles
        self.entities = entities
        
        updateActiveActors()
        updateVisibility(for: self.hero)
    }
    
    func update(_ deltaTime: TimeInterval) {
        while let action = self.actions.first {
            action.perform(game: self)
            
            switch action {
            case let move as MoveAction:
                self.delegate?.gameDidMove(entity: move.actor, path: move.path)
                
                if action.actor is Hero {
                    updateActiveActors()
                    print("coord: \(action.actor.coord.x).\(action.actor.coord.y)")
                    updateVisibility(for: action.actor)
                }
            case let attack as MeleeAttackAction:
                self.delegate?.gameDidAttack(actor: attack.actor, targetActor: attack.targetActor)
            case let die as DieAction:
                self.delegate?.gamedidDestroy(entity: die.actor)
                remove(entity: die.actor)
                updateActiveActors()
            default: break
            }
                        
            self.actions.removeFirst()
        }
                
        while self.actions.isEmpty {
            let actor = self.activeActors[self.activeActorIdx]
                        
            if actor.canPerformAction && actor.isAwaitingInput {
                return actor.update(state: self)
            }

            if actor.canPerformAction {
                guard let action = actor.getAction() else { fatalError() }
                self.actions.append(action)
            } else {
                actor.addTimeUnits(10)
            }
                        
            nextActor()
        }
    }
    
    private func nextActor() {
        self.activeActorIdx = (self.activeActorIdx + 1) % self.activeActors.count
//        print("\(self.activeActorIdx + 1) of \(self.activeActors.count)")
    }
    
    func updateActiveActors() {
        self.activeActors.removeAll()
        
        let xRange = max(self.hero.coord.x - 10, 0) ... min(self.hero.coord.x + 10, self.level.width)
        let yRange = max(self.hero.coord.y - 10, 0) ... min(self.hero.coord.y + 10, self.level.height)
        
        for actor in self.actors {
            if xRange.contains(actor.coord.x) && yRange.contains(actor.coord.y) {
                self.activeActors.append(actor)
            }
        }
        
        if self.activeActorIdx > (self.activeActors.count - 1) {
            self.activeActorIdx = 0
        }
    }
            
    func movePlayer(direction: Direction) {        
        self.selectionMode = .none
        self.hero.move(direction: direction)
    }
    
    func stopPlayer() {
        self.selectionMode = .none
        self.hero.stop()
    }
        
    func remove(entity: Entity) {
        self.entities.removeAll(where: { $0 == entity })
        self.delegate?.gamedidDestroy(entity: entity)
    }

    func handleInteraction(at coord: vector_int2) {
        /*
        guard self.selectionMode.isSelection else { return }
        
        let overlayTiles = self.tiles.filter({ $0 is OverlayTile }) as! [OverlayTile]

        switch self.selectionMode {
        case .selectDestinationTile:
            if let destinationTile = overlayTiles.filter({ $0.coord == coord }).first, destinationTile.isBlocked == false {
                let actorCoords = self.actors.filter({ $0.coord != self.hero.coord }).compactMap({ $0.coord })
                let graph = getMovementGraph(for: self.hero, range: 1, excludedCoords: actorCoords)
                                
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
        case .selectSpellTarget(let spellType):
            if let singleTargetDamageSpellType = spellType as? SingleTargetDamageSpell.Type,
                let targetActor = self.actors.filter({ $0.coord == coord }).first {
                let spell = singleTargetDamageSpellType.init(actor: self.hero, targetActor: targetActor)
                self.hero.cast(spell: spell)
            }
        case .none: break
        }

     */
        self.selectionMode = .none
    }
    
    private func updateVisibility(for actor: Actor) {
        self.actorVisibleCoords.removeAll()
        self.visibility.compute(origin: actor.coord, rangeLimit: actor.sight)
    }
}

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
    func gameDidMove(hero: Hero, path: [vector_int2], duration: TimeInterval)
    func gameDidAdd(entity: EntityProtocol)
    func gameDidRemove(entity: EntityProtocol)
    
    func gameDidUpdateStatus(message: String)
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
    private var level: Level!
    
    public weak var delegate: GameDelegate?
    
    private let entityFactory: EntityFactory
    
    private(set) var hero: Hero
    
    private var isBusy: Bool = false
        
    private var tileSize: CGSize = .zero
    
    private var selectionMode: SelectionMode = .none
        
    private var timeInterval: TimeInterval = 0
    
    public var turnDuration: TimeInterval = 6
    
    private var visibility: Visibility!
    
    private var turn: Int = 1
        
    init(entityFactory: EntityFactory, hero: Hero) {
        self.entityFactory = entityFactory
        self.hero = hero
    }

    // all currently existing entities (players, monsters, loot), entities that are destroyed are removed
    private(set) var entities: [Entity] = []
        
    // level tiles used for walls, floor, etc...
    private(set) var tiles: [Tile] = []

    // tiles used for the fog of war
    private(set) var fogTiles: [FogTile] = []

    // coordinates of tiles that are currently visible for the player
    private(set) var visibleTileCoords = Set<vector_int2>()
        
    // the current active actor, either a player or monster
    private var activeActorIdx: Int = 0
    
    // a list of dungeon loot
    var loot: [Lootable] { self.entities.filter({ $0 is Lootable }) as! [Lootable] }

    var actors: [Actor] { self.entities.filter({ $0 is Actor }) as! [Actor] }
    
    var monsters: [Monster] { self.entities.filter({ $0 is Monster }) as! [Monster] }
    
    // get a value for a tile at a coordinate, can be nil when out of range and is otherwise some integer value that represents a wall, floor or other scenery
    func getTile(at coord: vector_int2) -> Int? {
        self.level.getTileAt(coord: coord)
    }
    
    func getActor(at coord: vector_int2) -> Actor? {
        return self.actors.filter({ $0.coord == coord }).first
    }
    
    func getLoot(at coord: vector_int2) -> Lootable? {
        print("loot: \(self.loot.compactMap({ $0.coord }))")
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

                if isInRange(origin: actor.coord, radius: range, coord: coord) == false || getTile(at: coord) == 1 {
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
//                print("could not find path to: \(nodeCoord.x).\(nodeCoord.y)")
                movementGraph.remove([node])
            }
        }
        
        return movementGraph
    }
        
    func isHeroVisible(for actor: Actor) -> Bool {
        guard self.hero.isAlive else { return false }
        
        let x1 = actor.coord.x
        let y1 = actor.coord.y
        
        let x2 = self.hero.coord.x
        let y2 = self.hero.coord.y
        
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
        guard self.actors[self.activeActorIdx] == self.hero && self.isBusy == false else { return }

        if selectionMode.isSelection { hideSelectionTiles() }
        
        let actorCoords = self.actors.filter({ $0.coord != self.hero.coord }).compactMap({ $0.coord })
        let movementGraph = getMovementGraph(for: self.hero, range: 1, excludedCoords: actorCoords)
        let visibleAreaGraph = getVisiblityGraph(for: self.hero)
        
        // Compare visible area graph and movement graph and show appropriate tile colors depending if a tile is reachable or not
        for x in visibleAreaGraph.gridOrigin.x ..< visibleAreaGraph.gridOrigin.x + Int32(visibleAreaGraph.gridWidth) {
            for y in visibleAreaGraph.gridOrigin.y ..< visibleAreaGraph.gridOrigin.y + Int32(visibleAreaGraph.gridHeight) {
                let coord = vector_int2(x,y)
                guard coord != self.hero.coord else { continue }
                
                if let _ = visibleAreaGraph.node(atGridPosition: coord) {
                    if let _ = movementGraph.node(atGridPosition: coord) {
                        let movementTile = OverlayTile(color: SKColor.green.withAlphaComponent(0.4), coord: coord, isBlocked: false)
                        self.tiles.append(movementTile)
                        self.delegate?.gameDidAdd(entity: movementTile)
                    } else {
                        let movementTile = OverlayTile(color: SKColor.green.withAlphaComponent(0.1), coord: coord, isBlocked: true)
                        self.tiles.append(movementTile)
                        self.delegate?.gameDidAdd(entity: movementTile)
                    }
                }
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
        guard self.actors[self.activeActorIdx] == self.hero && self.isBusy == false else { return }

        if selectionMode.isSelection { hideSelectionTiles() }

        let xRange = getRange(position: self.hero.coord.x, radius: 1, constrainedTo: 0 ..< self.level.width)
        let yRange = getRange(position: self.hero.coord.y, radius: 1, constrainedTo: 0 ..< self.level.width)
        
        let actorCoords = self.actors.filter({ $0 != self.hero }).compactMap({ $0.coord })
        for actorCoord in actorCoords {
            if xRange.contains(actorCoord.x) && yRange.contains(actorCoord.y) {
                let movementTile = OverlayTile(color: SKColor.red.withAlphaComponent(0.4), coord: actorCoord, isBlocked: true)
                self.tiles.append(movementTile)
                self.delegate?.gameDidAdd(entity: movementTile)
            }
        }
        
        self.selectionMode = .selectMeleeTarget
    }
        
    private func hideSelectionTiles() {
        guard self.selectionMode.isSelection else { return }
        
        let tiles = self.tiles.filter({ $0 is OverlayTile })

        self.tiles.removeAll(where: { tiles.contains($0 )})

        tiles.forEach({ self.delegate?.gameDidRemove(entity: $0) })
        
        self.selectionMode = .none
    }
    
    func start(levelIdx: Int = 0, tileSize: CGSize) {
        self.level = Level()
        self.tileSize = tileSize
        
        self.visibility = RaycastVisibility(mapSize: CGSize(width: Int(self.level.width), height: Int(self.level.height)), blocksLight: { (x, y) -> (Bool) in
            let tile = self.level.getTileAt(coord: vector2(x, y))
            return tile != 0
        }, setVisible: { (x, y) in
//            print("set visible: \(x).\(y)")
            let tileIdx = Int(y * self.level.width + x)
            let tile = self.tiles[tileIdx]
            tile.didExplore = true
            
            self.visibleTileCoords.insert(vector_int2(x, y))
            
            let fogTile = self.fogTiles[tileIdx]
            fogTile.sprite.alpha = 0.0
        }, getDistance: { (x1, y1, x2, y2) -> Int in
            let x = pow(Float(x2 - x1), 2)
            let y = pow(Float(y2 - y1), 2)
            return Int(sqrt(x + y))
        })
        
        var entities: [Entity] = []
        var tiles: [Tile] = []
        var fogTiles: [FogTile] = []
        
        var didAddHero = false
        
        for y in (0 ..< self.level.height) {
            for x in (0 ..< self.level.width) {
                let coord = vector_int2(Int32(x), Int32(y))
                let tile = self.level.getTileAt(coord: coord)
                var entity: EntityProtocol?

                switch tile {
                case 0: entity = try! entityFactory.newEntity(type: Tile.self, name: "floor", coord: coord)
                case 1: entity = try! entityFactory.newEntity(type: Tile.self, name: "wall", coord: coord)
                case 2: entity = try! entityFactory.newEntity(type: Tile.self, name: "stairs_up", coord: coord)
                case 3: entity = try! entityFactory.newEntity(type: Tile.self, name: "stairs_down", coord: coord)
                default: break
                }

                if let entity = entity {
                    tiles.append(entity as! Tile)
                } else {
                    // TODO: Add dummy entity to indicate missing content?
                }
                
                let fogTile = FogTile(json: [:], coord: coord)
                fogTiles.append(fogTile)
                
                if !didAddHero, let room = level.getRoomId(coord: coord) {
                    print("level size: \(self.level.width) x \(self.level.height)")
                    print("hero added to room: \(room) @ \(coord.x).\(coord.y)")
                    self.hero.coord = coord
                    entities.append(self.hero)
                    print(self.hero)
                    
                    didAddHero = true
                }

//                let monsterCoords = [vector_int2(8, 6), vector_int2(18, 3), vector_int2(22, 8)]
//                for monsterCoord in monsterCoords where monsterCoord == coord {
//                    let idx = monsterCoords.firstIndex(where: { $0 == coord })!
//                    let isEven = idx.remainderReportingOverflow(dividingBy: 2).partialValue == 0
//                    let monster = try! entityFactory.newEntity(type: Monster.self, name: isEven ? "Gnoll" : "Skeleton", coord: monsterCoord)
//                    entities.append(monster)
//                    print(monster)
//                }
//
//                let potionCoords = [vector_int2(4, 4)]
//                for potionCoord in potionCoords where potionCoord == coord {
//                    let potion = try! entityFactory.newEntity(type: Potion.self, name: "Health Potion", coord: potionCoord)
//                    entities.append(potion)
//                }
            }
        }
        
        var monsterCount = 0
        for (roomId, room) in self.level.getRoomInfo() {
            // TODO: fix room coord calc in DungeonBuilder, so we don't have to do the following to get good coords ...
            let xOffset = Int32((room.width * 2 + 1) / 2)
            let yOffset = Int32((room.height * 2 + 1) / 2)
            let x = room.coord.y * 2 + 1 + xOffset
            let y = self.level.width - 1 - (room.coord.x * 2 + 1) - yOffset
            let roomCoord = vector_int2(x, y)
            
            print("\(roomId): \(room.coord.x).\( room.coord.y) -> \(roomCoord.x).\(roomCoord.y)")
            let isEven = monsterCount.remainderReportingOverflow(dividingBy: 2).partialValue == 0
            let monster = try! entityFactory.newEntity(type: Monster.self, name: isEven ? "Gnoll" : "Skeleton", coord: roomCoord)
            entities.append(monster)
            
            monsterCount += 1
        }
        
        self.fogTiles = [] // fogTiles
        self.tiles = tiles
        self.entities = entities
        
        updateFogTilesVisibilityForHero()
    }
    
    func update(_ deltaTime: TimeInterval) {
        // If the game is busy for any reason (e.g. show animation), wait until ready
        guard self.isBusy == false else { return }
                
        if self.hero.hitPoints.current <= 0 {
            let sceneManager = try! ServiceLocator.shared.get(service: SceneManager.self)
            sceneManager.crossFade(to: GameOverScene.self)
            self.isBusy = true
        }

        let activeActor = self.actors[self.activeActorIdx]
        activeActor.addTimeUnits(Constants.timeUnitsPerTurn)
                
        // Wait until the current active actor performs an action
        guard let action = activeActor.getAction(state: self) else {
            return
        }
                
        // Start the action for the current actor ... make sure only 1 action is performed at any time
        self.isBusy = true
                        
        let visibleTileCoords = self.visibleTileCoords
        
        guard action.perform(game: self, completion: { [unowned self] in
            if let statusUpdatable = action as? StatusUpdatable, let message = statusUpdatable.message {
                print(message)
                self.delegate?.gameDidUpdateStatus(message: message)
            }

            self.updateFogTilesVisibilityForHero()
            
            switch (action, action.actor) {
            case is (MoveAction, Monster):
                let isMonsterInRangeOfHero = visibleTileCoords.contains(action.actor.coord)
//                action.actor.sprite.alpha = isMonsterInRangeOfHero ? 1.0 : 0.0
            case is (MoveAction, Hero):
                let newVisibleTileCoords = self.visibleTileCoords
                let removedTileCoords = visibleTileCoords.subtracting(newVisibleTileCoords)
                let addedTileCoords = newVisibleTileCoords.subtracting(visibleTileCoords)

                for monster in self.monsters {
                    if addedTileCoords.contains(monster.coord) {
                        print("show: \(monster)")
                        monster.sprite.alpha = 1.0
                    }
                    else if removedTileCoords.contains(monster.coord) {
                        print("hide: \(monster)")
                        monster.sprite.alpha = 0.0
                    }
                }
            case is (DieAction, Actor):
                self.remove(entity: activeActor)
            default: break
            }
             
            self.isBusy = false
        }) else {
            return self.isBusy = false
        }
        
        // get all monsters in visual range of hero 2
        // compare monster list 1 and 2 ... monsters added fade in, monsters removed fade out ...
        
        switch action {
        case let moveAction as MoveAction:
            switch activeActor {
            case let hero as Hero:
                self.delegate?.gameDidMove(hero: hero, path: moveAction.path, duration: moveAction.duration)
            default: break
            }
        default: break
        }
                
        // Activate next actor
        self.activeActorIdx = (self.activeActorIdx + 1) % self.actors.count
    }
    
    func movePlayer(direction: Direction) {
        hideSelectionTiles()
                
        self.hero.move(direction: direction)
    }
        
    func remove(entity: Entity) {
        self.entities.removeAll(where: { $0 == entity })

        if entity is Actor {
            // After we remove an actor, update the index to prevent an index out of range error
            self.activeActorIdx = self.activeActorIdx % self.actors.count
        }
                
        self.delegate?.gameDidRemove(entity: entity)
    }

    func handleInteraction(at coord: vector_int2) {
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

        hideSelectionTiles()
    }
        
    func updateFogTilesVisibilityForHero() {
        return
        let range = Int32(self.hero.sight + 1)
        let x1 = max(self.hero.coord.x - range, 0)
        let x2 = min(self.hero.coord.x + range + 1, Int32(self.level.width))
        let y1 = max(self.hero.coord.y - range, 0)
        let y2 = min(self.hero.coord.y + range + 1, Int32(self.level.height))
        
        for x in x1 ..< x2 {
            for y in y1 ..< y2 {
                let tileIdx = Int(Int32(self.level.width) * y + x)
                let alpha: CGFloat = (self.tiles[tileIdx] as Tile).didExplore ? 0.5 : 1.0
                self.fogTiles[tileIdx].sprite.alpha = alpha
            }
        }

        self.visibleTileCoords.removeAll()
        self.visibility.compute(origin: self.hero.coord, rangeLimit: self.hero.sight)
    }
}

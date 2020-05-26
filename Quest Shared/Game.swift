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
    func gameDidDestroy(entity: EntityProtocol)

    func gameDidUpdateStatus(message: String)
    func gameDidAttack(actor: Actor, targetActor: Actor)
    func gameDidRangedAttack(actor: Actor, targetActor: Actor, projectile: Projectile, isHit: Bool)
    
    func gameDidInteract(by actor: Actor, with entity: EntityProtocol)
    
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
    public let state: GameState
    
    public weak var delegate: GameDelegate?
                    
    private var tileSize: CGSize = .zero
    
    private var selectionMode: SelectionMode = .none {
        didSet {
            self.delegate?.gameDidChangeSelectionMode(self.selectionMode)
        }
    }

    var viewVisibleCoords = Set<vector_int2>()

    public var turnDuration: TimeInterval = 6
    
    private var visibility: Visibility!
            
    init(state: GameState) {
        self.state = state
    }

//    private(set) var selectionModeCoords = Set<vector_int2>()
    private(set) var selectionModeTiles: [OverlayTile] = []
        
    // a list of dungeon loot
    var loot: [Lootable] { self.state.entities.filter({ $0 is Lootable }) as! [Lootable] }
    
    var monsters: [Monster] { self.state.entities.filter({ $0 is Monster }) as! [Monster] }
        
    var actions: [Action] = []
                    
    func getRange(position: Int32, radius: Int32, constrainedTo range: Range<Int32>) -> Range<Int32> {
        let minValue = max(position - radius, range.lowerBound)
        let maxValue = min(position + radius + 1, range.upperBound)
        return Int32(minValue) ..< Int32(maxValue)
    }
        
    // MARK: - Public
    
    func showMovementTilesForHero() {
        self.selectionModeTiles.removeAll()
        
        let coords: [vector_int2] = [
            vector_int2(self.state.hero.coord.x - 1, self.state.hero.coord.y),
            vector_int2(self.state.hero.coord.x + 1, self.state.hero.coord.y),
            vector_int2(self.state.hero.coord.x, self.state.hero.coord.y - 1),
            vector_int2(self.state.hero.coord.x, self.state.hero.coord.y + 1),
        ]
        
        for coord in coords {
            if self.state[coord] == .open && self.monsters.filter({ $0.coord == coord }).count == 0 {
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
        
        let xRange = self.state.hero.coord.x - 1 ... self.state.hero.coord.x + 1
        let yRange = self.state.hero.coord.y - 1 ... self.state.hero.coord.y + 1
        
        for x in xRange {
            for y in yRange {
                let coord = vector_int2(x, y)
                
                if coord == self.state.hero.coord { continue }
        
                if let _ = self.monsters.filter({ $0.coord == coord }).first {
                    self.selectionModeTiles.append(OverlayTile(color: SKColor.red.withAlphaComponent(0.5), coord: coord, isBlocked: false))
                }
            }
        }
        
        self.selectionMode = .selectMeleeTarget
    }
            
    func start(levelIdx: Int = 0, tileSize: CGSize) {
        self.tileSize = tileSize
        
        let mapSize = CGSize(width: Int(self.state.width), height: Int(self.state.height))
        self.visibility = RaycastVisibility(mapSize: mapSize, blocksLight: {
            if let door = self.state.getDoor(at: $0) {
                return door.isOpen == false
            }
            
            return self.state[$0] == .blocked
        }, setVisible: {
            self.state.actorVisibleCoords.insert($0)
        }, getDistance: {
            let x = pow(Float($1.x - $0.x), 2)
            let y = pow(Float($1.y - $0.y), 2)
            return Int(sqrt(x + y))
        })
        
        /*
         // WIP tilesets
         
        var tilesets: [Tileset] = []
        for tilesetFile in ["snake", "orc", "marble", "sandstone", "church"] {
            let tileset = try! DataLoader.load(type: Tileset.self, fromFileNamed: tilesetFile, inDirectory: "Data/Tileset")
            tilesets.append(tileset)
        }
                        
        var roomTilesetInfo: [UInt: Bool] = [:]
                
        for (roomId, room) in self.level.roomInfo {
            if arc4random_uniform(4) != 0 || roomTilesetInfo.index(forKey: roomId) != nil { continue }
                        
            let midX: Int32 = Int32(room.coord.x + room.width / 2)
            let midY: Int32 = Int32(room.coord.y + room.height / 2)

            let minX = Int32(max(room.coord.x - 2, 0))
            let maxX = Int32(min(room.coord.x + room.width + 2, Int(self.level.width - 1)))
            let minY = Int32(max(room.coord.y - 2, 0))
            let maxY = Int32(min(room.coord.y + room.height + 2, Int(self.level.height - 1)))
            let p1 = vector_int2(minX, midY)
            let p2 = vector_int2(maxX, midY)
            let p3 = vector_int2(midX, minY)
            let p4 = vector_int2(midX, maxY)
            let p5 = vector_int2(minX, minY)
            let p6 = vector_int2(maxX, minY)
            let p7 = vector_int2(minX, maxY)
            let p8 = vector_int2(maxX, maxY)

            for point in [p1, p2, p3, p4, p5, p6, p7, p8] {
                let node = self.level.getNode(at: point)
                if node.contains(.room) {
                    roomTilesetInfo[node.roomId] = false
                }
            }
                        
            roomTilesetInfo[roomId] = true
            
            let tilesetIdx = arc4random_uniform(UInt32(tilesets.count))
            let tileset = tilesets[Int(tilesetIdx)]
            
            for x in (room.coord.x - 1) ... (room.coord.x + room.width) {
                for y in (room.coord.y - 1) ... (room.coord.y + room.height) {
                    let tile = self.tiles[y][x]

                    let tileType = self.getTile(at: vector_int2(Int32(x), Int32(y)))!

                    var sprite: SKSpriteNode
                    
                    switch tileType {
                    case 0: sprite = tileset.getFloorTile()
                    case 1: sprite = tileset.getWallTile()
                    default: continue // ignore doors for now?
                    }
                    
                    let newTile = Tile(sprite: sprite, coord: tile.coord)
                    self.tiles[y][x] = newTile
                }
            }
        }
                
 */
        /* WIP */
                        
        self.state.updateActiveActors()
        updateVisibility(for: self.state.hero)
    }
    
    func update(_ deltaTime: TimeInterval) {
        // process the list if pending actions
        while let action = self.actions.first {
            action.perform(state: self.state)
            
            switch action {
            case let interact as InteractAction:
//                print("\(interact.actor.name) @ \(interact.actor.coord.x).\(interact.actor.coord.y) is interacting with \(interact.entity.name)")
                updateVisibility(for: interact.actor)
                self.delegate?.gameDidInteract(by: interact.actor, with: interact.entity)
            case let move as MoveAction:
//                print("\(move.actor.name) @ \(move.actor.coord.x).\(move.actor.coord.y) is performing move")
                // after the hero moved to a new location, update the visible tiles for the hero
                if action.actor is Hero {
                    self.state.updateActiveActors()
                    updateVisibility(for: action.actor)
                }
                self.delegate?.gameDidMove(entity: move.actor, path: move.path)
            case let attack as MeleeAttackAction:
//                print("\(attack.actor.name) @ \(attack.actor.coord.x).\(attack.actor.coord.y) is performing melee attack")
                self.delegate?.gameDidAttack(actor: attack.actor, targetActor: attack.targetActor)
                if attack.targetActor.isAlive == false {
                    self.delegate?.gameDidDestroy(entity: attack.targetActor)
                    // on deleting an entity, update a list of active actors to exclude the deleted entity
                    remove(entity: attack.targetActor)
                    self.state.updateActiveActors()
                }
            case let attack as RangedAttackAction:
//                print("\(attack.actor.name) @ \(attack.actor.coord.x).\(attack.actor.coord.y) is performing ranged attack")
                let projectile = action.actor.equippedWeapon.projectile!
                projectile.configureSprite(origin: attack.actor.coord, target: attack.targetActor.coord)
                self.delegate?.gameDidRangedAttack(actor: attack.actor, targetActor: attack.targetActor, projectile: projectile, isHit: attack.isHit)
                
                if attack.targetActor.isAlive == false {
                    self.delegate?.gameDidDestroy(entity: attack.targetActor)
                    // on deleting an entity, update a list of active actors to exclude the deleted entity
                    remove(entity: attack.targetActor)
                    self.state.updateActiveActors()
                }
                break
            default: break
            }
            
//            print("energy: \(action.actor.energy.amount)")
                        
            self.actions.removeFirst()
        }
                
        // if no actions are pending, process each actor until an action is added
        while self.actions.isEmpty {
            let actor = self.state.currentActor
            
            if actor.canTakeTurn && actor.isAwaitingInput {                
                // in case of the hero, we might need to wait for input before we can get a new action
                updateVisibility(for: actor)
                return actor.update(state: self.state)
            }

            if actor.canTakeTurn {
                updateVisibility(for: actor)
                
                guard self.state.actorVisibleCoords.contains(self.state.hero.coord) else { return self.state.nextActor() }
                                
                actor.energy.increment(10)
                actor.update(state: self.state)

                // if the actor has a pending action, add the action to the pending action list
                guard let action = actor.getAction() else { return self.state.nextActor() }

                self.actions.append(action)
            } else {
                // otherwise increment the time units until we have enough to allow for an action
                actor.energy.increment(10)                
                self.state.nextActor()
            }
        }
    }
                    
    func movePlayer(direction: Direction) {        
        self.selectionMode = .none
        self.state.hero.move(direction: direction)
    }
    
    func stopPlayer() {
        self.selectionMode = .none
        self.state.hero.stop()
    }
    
    func tryPlayerInteraction() {
        let coords: [vector_int2] = [
            vector_int2(self.state.hero.coord.x - 1, self.state.hero.coord.y),
            vector_int2(self.state.hero.coord.x + 1, self.state.hero.coord.y),
            vector_int2(self.state.hero.coord.x, self.state.hero.coord.y - 1),
            vector_int2(self.state.hero.coord.x, self.state.hero.coord.y + 1),
        ]

        for coord in coords {
            let node = self.state[coord]
            if node == .door {
                let direction = Direction.relative(from: self.state.hero.coord, to: coord)
                self.selectionMode = .none
                self.state.hero.interact(direction: direction)
            }
        }
    }
        
    func remove(entity: Entity) {
        self.state.entities.removeAll(where: { $0 == entity })
        self.delegate?.gameDidDestroy(entity: entity)
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
        self.state.actorVisibleCoords.removeAll()
        self.visibility.compute(origin: actor.coord, rangeLimit: actor.sight)
    }
}

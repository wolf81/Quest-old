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
    func gameDidDestroy(entity: EntityProtocol)

    func gameDidChangeSelectionMode(_ selectionMode: SelectionMode)

    func gameDidUpdateStatus(message: String)
    
    func gameActorDidMove(actor: Actor, path: [vector_int2])
    
    func gameActorDidPerformMeleeAttack(actor: Actor, targetActor: Actor, isHit: Bool)

    func gameActorDidTriggerTrap(actor: Actor, trap: Trap, isHit: Bool)
    
    func gameActorDidPerformRangedAttack(actor: Actor, withProjectile projectile: Projectile, targetActor: Actor, isHit: Bool)

    func gameActorDidPerformInteraction(actor: Actor, targetEntity: EntityProtocol)
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
    
    private var lastUpdateTime: TimeInterval = 0

    public weak var delegate: GameDelegate?
                        
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
        print(self.state)
    }

//    private(set) var selectionModeCoords = Set<vector_int2>()
    private(set) var selectionModeTiles: [OverlayTile] = []
                
    var actions: [Action] = []
        
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
            if self.state.getMapNodeType(at: coord) == .open && self.state.monsters.filter({ $0.coord == coord }).count == 0 {
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
        
                if let _ = self.state.monsters.filter({ $0.coord == coord }).first {
                    self.selectionModeTiles.append(OverlayTile(color: SKColor.red.withAlphaComponent(0.5), coord: coord, isBlocked: false))
                }
            }
        }
        
        self.selectionMode = .selectMeleeTarget
    }
            
    func start(levelIdx: Int = 0, tileSize: CGSize) {        
        self.state.updateActiveActors(for: self.viewVisibleCoords)
        self.state.hero.updateVisibility()
    }
    
    func update(_ currentTime: TimeInterval) {
        var deltaTime = currentTime - self.lastUpdateTime
        
        defer {            
            self.lastUpdateTime = CACurrentMediaTime();
        }
        
        // process the list if pending actions
        while let action = self.actions.first {
            action.perform(state: self.state)
            
            switch action {
            case let interact as InteractAction:
//                print("\(interact.actor.name) @ \(interact.actor.coord.x).\(interact.actor.coord.y) is interacting with \(interact.entity.name)")
                interact.actor.updateVisibility()
                self.delegate?.gameActorDidPerformInteraction(actor: interact.actor, targetEntity: interact.entity)
            case let move as MoveAction:
//                print("\(move.actor.name) @ \(move.actor.coord.x).\(move.actor.coord.y) is performing move")
                // after the hero moved to a new location, update the visible tiles for the hero
                if let hero = action.actor as? Hero {
                    self.state.updateActiveActors(for: self.viewVisibleCoords)
                    if let loot = self.state.getLoot(at: hero.coord) {
                        self.state.remove(entity: loot)
                        hero.addToBackpack(loot)
                        self.delegate?.gameDidDestroy(entity: loot)
                    }
                    
                    if let trap = self.state.getTrap(at: hero.coord) {
                        let isHit = trap.trigger(actor: hero)
                        self.delegate?.gameActorDidTriggerTrap(actor: hero, trap: trap, isHit: isHit)
                        
                        if !hero.isAlive {
                            self.delegate?.gameDidDestroy(entity: hero)
                        }
                    }
                }
                self.delegate?.gameActorDidMove(actor: move.actor, path: move.path)
            case let attack as MeleeAttackAction:
//                print("\(attack.actor.name) @ \(attack.actor.coord.x).\(attack.actor.coord.y) is performing melee attack")
                self.delegate?.gameActorDidPerformMeleeAttack(actor: attack.actor, targetActor: attack.targetActor, isHit: attack.isHit)
                if attack.targetActor.isAlive == false {
                    self.delegate?.gameDidDestroy(entity: attack.targetActor)
                    // on deleting an entity, update a list of active actors to exclude the deleted entity
                    remove(entity: attack.targetActor)
                    self.state.updateActiveActors(for: self.viewVisibleCoords)
                }
            case let attack as RangedAttackAction:
//                print("\(attack.actor.name) @ \(attack.actor.coord.x).\(attack.actor.coord.y) is performing ranged attack")
                let projectile = action.actor.equippedWeapon.projectile!
                projectile.configureSprite(origin: attack.actor.coord, target: attack.targetActor.coord)
                self.delegate?.gameActorDidPerformRangedAttack(actor: attack.actor, withProjectile: projectile, targetActor: attack.targetActor, isHit: attack.isHit)
                
                if attack.targetActor.isAlive == false {
                    self.delegate?.gameDidDestroy(entity: attack.targetActor)
                    // on deleting an entity, update a list of active actors to exclude the deleted entity
                    remove(entity: attack.targetActor)
                    self.state.updateActiveActors(for: self.viewVisibleCoords)
                }
                break
            default: break
            }
                                    
            self.actions.removeFirst()
        }
        
        // if no actions are pending, process each actor until an action is added
        while self.actions.isEmpty {
            let actor = self.state.currentActor
            
            if actor.canTakeTurn && actor.isAwaitingInput {                
                // in case of the hero, we might need to wait for input before we can get a new action
                return actor.update(state: self.state)
            }

            if actor.canTakeTurn {
                // TODO: only update visible actors in fov                
                guard self.state.hero.visibleCoords.contains(actor.coord) else { return self.state.nextActor() }
                                
                actor.energy.increment(Constants.energyPerTick)
                actor.update(state: self.state)

                // if the actor has a pending action, add the action to the pending action list
                guard let action = actor.getAction() else { return self.state.nextActor() }

                self.actions.append(action)
            } else {
                // otherwise increment the time units until we have enough to allow for an action
                actor.energy.increment(Constants.energyPerTick)
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
    
    func attackTarget(actor: Actor) {
        print("attack: \(actor.name)")
        self.state.hero.attack(actor: actor)
    }
    
    func tryPlayerInteraction() {
        let coords: [vector_int2] = [
            vector_int2(self.state.hero.coord.x - 1, self.state.hero.coord.y),
            vector_int2(self.state.hero.coord.x + 1, self.state.hero.coord.y),
            vector_int2(self.state.hero.coord.x, self.state.hero.coord.y - 1),
            vector_int2(self.state.hero.coord.x, self.state.hero.coord.y + 1),
        ]

        for coord in coords {
            if self.state.getDoor(at: coord) != nil {
                let direction = Direction.relative(from: self.state.hero.coord, to: coord)
                self.selectionMode = .none
                self.state.hero.interact(direction: direction)
            }
        }
    }
    
    func toggleWeapons() {
        self.state.hero.toggleWeapons()        
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
}

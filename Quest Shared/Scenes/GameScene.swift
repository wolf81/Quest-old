//
//  GameScene.swift
//  Quest Shared
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Fenris
import SpriteKit
import GameplayKit

class GameScene: SKScene, SceneManagerConstructable {
    public struct UserInfoKey {
        public static let game = "game"
    }
    
    private var lastUpdateTime: TimeInterval = 0
        
    private var game: Game!
    
    private var actionBar: ActionBar!
    
    private var statusBar: StatusBar!
    
    private var world: SKNode = SKNode()
    
    private var playerCamera: SKCameraNode!
    
    private var inventory: InventoryNode?
    
    private var characterInfo: CharacterInfoNode?
    
    private let targetNode = TargetNode()
                    
    private var targetActor: Actor?
    
    required init(size: CGSize, userInfo: [String : Any]) {
        self.game = (userInfo[UserInfoKey.game] as! Game)
        
        super.init(size: size)

        self.game.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleTargetNodeVisibility), name: Notification.Name.actorDidChangeEquipment, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.actorDidChangeEquipment, object: nil)
    }

    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let deltaTime = currentTime - self.lastUpdateTime
        
        // Update game state
        if self.lastUpdateTime != 0 {
            self.game.update(deltaTime)
        }
        
        self.lastUpdateTime = currentTime
    }
    
    // MARK: - Public
    
    static func pointForCoord(_ coord: SIMD2<Int32>) -> CGPoint {
        let x = CGFloat(coord.x) * Constants.tileSize.width
        let y = CGFloat(coord.y) * Constants.tileSize.height
        return CGPoint(x: x, y: y)
    }
    
    static func coordForPoint(_ point: CGPoint) -> vector_int2 {
        let x = Int32((point.x + (Constants.tileSize.width / 2)) / Constants.tileSize.width)
        let y = Int32((point.y + (Constants.tileSize.height / 2)) / Constants.tileSize.height)
        return vector_int2(x, y)
    }

    // MARK: - Private
    
    private func setUpScene() {
        self.game.start(tileSize: Constants.tileSize)
        
        self.backgroundColor = SKColor.black
        
        self.actionBar = ActionBar(size: CGSize(width: self.size.width, height: 50), delegate: self)
        self.actionBar.position = CGPoint(x: 0, y: -(size.height / 2))
        self.actionBar.zPosition = 1_000_000_000

        self.playerCamera = SKCameraNode()
        self.playerCamera.position = cameraPositionForCoord(self.game.state.hero.coord)
        self.playerCamera.addChild(self.actionBar)

        self.world.addChild(self.playerCamera)
        scene?.camera = self.playerCamera
        
        self.speed = 8
        self.game.turnDuration = Double(6.0 / self.speed)
        
        addChild(self.world)
        
        var statusBarSize = self.size
        statusBarSize.height = 40
        statusBarSize.width -= 40
        self.statusBar = StatusBar(size: statusBarSize, font: DefaultMenuConfiguration.shared.labelFont)
        let statusBarY = self.actionBar.frame.maxY + 20
        self.statusBar.position = CGPoint(x: -self.size.width / 2 + 20, y: statusBarY)
        self.playerCamera.addChild(self.statusBar)
        
        self.statusBar.update(text: "Welcome to Quest")
        
        for entity in self.game.state.entities {
            entity.sprite.position = GameScene.pointForCoord(entity.coord)
        }
        
        gameActorDidMove(actor: self.game.state.hero, path: [self.game.state.hero.coord])
    }
    
    private func movePlayer(direction: Direction) {
        self.game.movePlayer(direction: direction)
    }
    
    private func moveCamera(path: [vector_int2], duration: TimeInterval) {
        var actions: [SKAction] = []
        
        for coord in path {
            let position = cameraPositionForCoord(coord)
            actions.append(SKAction.move(to: position, duration: duration / Double(path.count)))
        }
        
        self.playerCamera.run(SKAction.sequence(actions))
    }
        
    private func cameraPositionForCoord(_ coord: vector_int2) -> CGPoint {
        var position = GameScene.pointForCoord(coord)
        position.y -= self.actionBar.size.height
        return position
    }
    
    private func coordForCameraPosition() -> vector_int2 {
        return GameScene.coordForPoint(self.camera!.position)
    }
    
    fileprivate func toggleInventory() {
        if self.characterInfo != nil { toggleCharacterInfo() }
        
        if let inventory = self.inventory {
            inventory.removeFromParent()
            self.inventory = nil
        } else {
            let inventory = InventoryNode(size: CGSize(width: 600, height: 400), backgroundColor: .black, hero: self.game.state.hero)
            self.playerCamera.addChild(inventory)
            self.inventory = inventory
        }
    }
    
    fileprivate func toggleCharacterInfo() {
        if self.inventory != nil { toggleInventory() }
        
        if let characterInfo = self.characterInfo {
            characterInfo.removeFromParent()
            self.characterInfo = nil
        } else {
            let characterInfo = CharacterInfoNode(size: CGSize(width: 600, height: 400), backgroundColor: .black, hero: self.game.state.hero)
            self.playerCamera.addChild(characterInfo)
            self.characterInfo = characterInfo
        }
    }
    
    fileprivate func dismissCharacterInfoAndInventory() {
        if self.characterInfo != nil { toggleCharacterInfo() }
        if self.inventory != nil { toggleInventory() }
    }
    
    fileprivate func clearSelectionModeTiles() {
        for tile in self.game.selectionModeTiles {
            tile.sprite.removeFromParent()
        }
    }
    
    private func getMinMaxVisibleCoordsInView() -> (vector_int2, vector_int2) {
        let halfWidth = self.size.width / 2
        let minX = self.camera!.position.x - halfWidth
        let maxX = self.camera!.position.x + halfWidth
        let halfHeight = self.size.height / 2
        let minY = self.camera!.position.y - halfHeight
        let maxY = self.camera!.position.y + halfHeight
        let minCoord = GameScene.coordForPoint(CGPoint(x: minX, y: minY))
        let maxCoord = GameScene.coordForPoint(CGPoint(x: maxX, y: maxY))
                                
        let y1 = max(Int32(minCoord.y - 1), 0)
        let y2 = min(Int32(maxCoord.y + 1), Int32(self.game.state.mapHeight - 1))
        
        let x1 = max(Int32(minCoord.x - 1), 0)
        let x2 = min(Int32(maxCoord.x + 1), Int32(self.game.state.mapWidth - 1))

        return (vector_int2(x1, y1), vector_int2(x2, y2))
    }
    
    private func getCoordsInRange(minCoord: vector_int2, maxCoord: vector_int2) -> Set<vector_int2> {
        var coords = Set<vector_int2>()
        for y in minCoord.y ... maxCoord.y {
            for x in minCoord.x ... maxCoord.x {
                coords.insert(vector_int2(x, y))
            }
        }
        return coords
    }
    
    func showTargetNodeIfNeeded() {
        if self.targetNode.parent == nil {
            toggleTargetNodeVisibility()
        }
    }
    
    private func hideTargetNode() {
        self.targetActor = nil
        self.targetNode.removeFromParent()
    }
    
    @objc private func toggleTargetNodeVisibility() {
        guard self.game.state.hero.isRangedWeaponEquipped else {
            return hideTargetNode()
        }
        
        if self.targetNode.parent != nil {
            hideTargetNode()
        }

        var targets: [Actor] = []
        for visibleCoord in self.game.state.hero.visibleCoords {
            if let target = self.game.state.getActor(at: visibleCoord) as? Monster {
                targets.append(target)
            }
        }
        
        if let target = targets.first {
            self.targetActor = target
            target.sprite.addChild(self.targetNode)
        }
    }
}

func isInRange(origin: vector_int2, radius: Int32, coord: vector_int2) -> Bool {
    return ((coord.x - origin.x) * (coord.x - origin.x) + (coord.y - origin.y) * (coord.y - origin.y)) <= (radius * radius)
}

// MARK: - GameDelegate

extension GameScene: GameDelegate {
    func gameActorDidTriggerTrap(actor: Actor, trap: Trap, isHit: Bool) {
        trap.playSound(.hit, on: self.world)
        if isHit {
            actor.showBlood(duration: 8.0)
        }
    }
    
    func gameActorDidPerformInteraction(actor: Actor, targetEntity: EntityProtocol) {
        if let door = targetEntity as? Door {
            let oldSprite = door.sprite
            
            oldSprite.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 1.0),
                SKAction.run({ oldSprite.removeFromParent() })
            ]))

            let newSprite = door.getSprite(isOpen: door.isOpen)
            newSprite.position = oldSprite.position
            newSprite.alpha = 0.0
            self.world.addChild(newSprite)

            newSprite.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: 1.0),
                SKAction.run({ door.sprite = newSprite })
            ]))
            
            // update visible nodes
            gameActorDidMove(actor: actor, path: [actor.coord])
            
            door.playSound(door.isOpen ? .activate : .deactivate, on: self.world)
        }
    }
    
    func gameDidChangeSelectionMode(_ selectionMode: SelectionMode) {        
        clearSelectionModeTiles()
                
        if selectionMode.isSelection {
            for tile in self.game.selectionModeTiles {
                tile.sprite.position = GameScene.pointForCoord(tile.coord)
                self.world.addChild(tile.sprite)
            }
        }
    }
    
    func gameActorDidPerformRangedAttack(actor: Actor, withProjectile projectile: Projectile, targetActor: Actor, isHit: Bool) {
        // Make a copy of the sprite, to prevent the sprite to become unmanaged once the projectile is destroyed
        let sprite = projectile.sprite.copy() as! SKSpriteNode
        sprite.position = actor.sprite.position
        self.world.addChild(sprite)

        // for missing attacks, show arrow hitting coordinate next to the hero
        var toCoord = targetActor.coord
        if !isHit {
            let adjacentDirections = Direction.relative(from: actor.coord, to: targetActor.coord).adjacentDirections
            let direction = arc4random() % 2 == 0 ? adjacentDirections[0] : adjacentDirections[1]
            toCoord = toCoord &+ direction.coord
        }
        
        let attack = SKAction.sequence([
            SKAction.move(to: GameScene.pointForCoord(toCoord), duration: 2.5),
            SKAction.run {
                sprite.removeFromParent()
            }
        ])
        
        sprite.run(attack)
        
        if isHit {
            projectile.playSound(.hit, on: self.world)
            targetActor.showBlood(duration: 8.0)
            targetActor.playSound(.hit)
        }
    }
    
    func gameActorDidPerformMeleeAttack(actor: Actor, targetActor: Actor, isHit: Bool) {
        let actorPosition = GameScene.pointForCoord(actor.coord)
        let targetActorPosition = GameScene.pointForCoord(targetActor.coord)
        let midX = actorPosition.x + (targetActorPosition.x - actorPosition.x) / 2
        let midY = actorPosition.y + (targetActorPosition.y - actorPosition.y) / 2
        
        let stepDuration = 1.0 / 2
        let attack = SKAction.sequence([
            SKAction.move(to: CGPoint(x: midX, y: midY), duration: stepDuration),
            SKAction.move(to: actorPosition, duration: stepDuration)
        ])
        
        actor.sprite.run(attack)
        
        if isHit {
            actor.equippedWeapon.playSound(.hit, on: self.world)
            targetActor.showBlood(duration: 8.0)
            targetActor.playSound(.hit)
        }
    }
    
    func gameDidDestroy(entity: EntityProtocol) {
        if self.targetNode.parent == entity.sprite {
            hideTargetNode()
        }

        var fade: [SKAction] = [
            SKAction.fadeOut(withDuration: entity is Actor ? 6.0 : 1.0),
            SKAction.run {
                entity.sprite.removeFromParent()
            }
        ]

        if entity is Hero {
            fade.append(SKAction.run {
                let sceneManager = try! ServiceLocator.shared.get(service: SceneManager.self)
                sceneManager.crossFade(to: GameOverScene.self)
            })
        }
        
        if let actor = entity as? Actor {
            actor.showBlood(duration: 6.0)
            actor.playSound(.destroy)
        }

        entity.sprite.run(SKAction.sequence(fade))
    }
    
    func gameActorDidMove(actor: Actor, path: [vector_int2]) {
        switch actor {
        case let hero as Hero:
            let (minCoord, maxCoord) = getMinMaxVisibleCoordsInView()
                                                        
            let viewVisibleCoords = getCoordsInRange(minCoord: minCoord, maxCoord: maxCoord)

            for activeActor in self.game.state.activeActors {
                if hero.visibleCoords.contains(activeActor.coord) == false {
                    activeActor.sprite.removeFromParent()
                } else if activeActor.sprite.parent == nil {
                    self.world.addChild(activeActor.sprite)
                }
            }
                        
            for entity in self.game.state.loot {
                if hero.visibleCoords.contains(entity.coord) {
                    
                    if entity.sprite.parent == nil {
                        self.world.addChild(entity.sprite)
                    }
                    else {
                        let position = GameScene.pointForCoord(path.last!)
                        hero.sprite.run(SKAction.move(to: position, duration: 2.0))
                    }
                } else {
                    entity.sprite.removeFromParent()
                }
            }
                                    
            // add sprites for all newly added tiles ... these are tiles that used to be out of view bounds
            let addedCoords = viewVisibleCoords.subtracting(self.game.viewVisibleCoords)
            for coord in addedCoords {
                let tile = self.game.state.tiles[Int(coord.y)][Int(coord.x)]

                if hero.visibleCoords.contains(coord) {
                    tile.didExplore = true
                }

                tile.sprite.position = GameScene.pointForCoord(tile.coord)
                tile.sprite.alpha = 0.0
                self.world.addChild(tile.sprite)
                
                let alpha: CGFloat = hero.visibleCoords.contains(coord) ? 1.0 : tile.didExplore ? 0.5 : 0.0
                tile.sprite.run(SKAction.fadeAlpha(to: alpha, duration: 3.0))
            }

            // remove sprites for tiles that are out of view bounds
            let removedCoords = self.game.viewVisibleCoords.subtracting(viewVisibleCoords)
            for coord in removedCoords {
                let tile = self.game.state.tiles[Int(coord.y)][Int(coord.x)]
                tile.sprite.removeFromParent()
            }
                                    
            // update the remaining tiles
            let remainingCoords = self.game.viewVisibleCoords.subtracting(addedCoords).subtracting(removedCoords)
            for coord in remainingCoords {
                let tile = self.game.state.tiles[Int(coord.y)][Int(coord.x)]

                if hero.visibleCoords.contains(coord) {
                    tile.didExplore = true
                }

                let alpha: CGFloat = hero.visibleCoords.contains(coord) ? 1.0 : tile.didExplore ? 0.5 : 0.0
                tile.sprite.run(SKAction.fadeAlpha(to: alpha, duration: 1.5))
            }
            
            self.game.viewVisibleCoords = viewVisibleCoords

            let position = GameScene.pointForCoord(path.last!)
            hero.sprite.run(SKAction.move(to: position, duration: Constants.AnimationDuration.default))
            
            if let targetActor = self.targetActor, hero.visibleCoords.contains(targetActor.coord) == false {
                hideTargetNode()
            }
            
            moveCamera(path: path, duration: Constants.AnimationDuration.default)
        case _ where actor is Monster:
            let firstCoord = path.first!
            let lastCoord = path.last!
            
            let willShow = self.game.state.hero.visibleCoords.contains(lastCoord) && self.game.state.hero.visibleCoords.contains(firstCoord) == false

            var move: [SKAction] = []

            let stepCount = path.count + (willShow ? 1 : 0)
            let stepDuration = Constants.AnimationDuration.default / Double(stepCount)

            if willShow {
                move.append(SKAction.fadeIn(withDuration: stepDuration))
            }
            
            for coord in path {
                let position = GameScene.pointForCoord(coord)
                move.append(SKAction.move(to: position, duration: stepDuration))
            }
            
            actor.sprite.run(SKAction.sequence(move))
        default: break
        }
                
        showTargetNodeIfNeeded()
    }
        
    func gameDidUpdateStatus(message: String) {
        self.statusBar.update(text: message)
    }
}

// MARK: - ActionBarDelegate

extension GameScene: ActionBarDelegate {
    func actionBarDidSelectDefend() {
        print("defend")
    }
    
    func actionBarDidSelectMove() {
        clearSelectionModeTiles()
        self.game.showMovementTilesForHero()
    }
    
    func actionBarDidSelectMeleeAttack() {
        clearSelectionModeTiles()
        self.game.showMeleeAttackTilesForHero()
    }

    func actionBarDidSelectRangeAttack() {
        clearSelectionModeTiles()
        self.game.showRangedAttackTilesForHero()
    }
    
    func actionBarDidSelectCastSpell() {
        clearSelectionModeTiles()
        self.game.showTargetTilesForSpellType(spellType: MagicMissile.self)
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}
#endif

#if os(OSX)
// Mouse- & keyboard-based event handling
extension GameScene {
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        
        let nodes = self.nodes(at: location)

        if let inventory = self.inventory, nodes.contains(inventory) {
            inventory.convert(location, from: self)
            inventory.mouseDown(with: event)
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        
        let nodes = self.nodes(at: location)
        
        if nodes.contains(self.actionBar) {
            self.actionBar.convert(location, from: self)
            self.actionBar.mouseUp(with: event)
        } else if let inventory = self.inventory, nodes.contains(inventory) {
            inventory.convert(location, from: self)
            inventory.mouseUp(with: event)
        } else if nodes.contains(self.world) {
            let coord = GameScene.coordForPoint(location)
            self.game.handleInteraction(at: coord)
        }
    }
        
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case /* q */ 12: self.game.movePlayer(direction: .northWest)
        case /* e */ 14: self.game.movePlayer(direction: .northEast)
        case /* z */ 6: self.game.movePlayer(direction: .southWest)
        case /* c */ 8: self.game.movePlayer(direction: .southEast)
        case /* a */ 0: self.game.movePlayer(direction: .west)
        case /* d */ 2: self.game.movePlayer(direction: .east)
        case /* s */ 1: self.game.movePlayer(direction: .south)
        case /* w */ 13: self.game.movePlayer(direction: .north)
        default: print("\(event.keyCode)")
        }
    }        
    
    override func keyUp(with event: NSEvent) {
//        debugPrint(event.keyCode)
                
        switch event.keyCode {
        case /* esc */ 53: dismissCharacterInfoAndInventory()
        case /* q e z c a d s w */ 12, 14, 6, 8, 0, 1, 2, 13: self.game.stopPlayer()
        case /* t   */ 17: self.game.toggleWeapons()
        case /* i   */ 34: toggleInventory()
        case /* c   */ 35: toggleCharacterInfo()
        case /* u   */ 32: self.game.tryPlayerInteraction()
        case /* tab */ 48: break // change target
        case /* space */ 49: if let actor = self.targetActor { self.game.attackTarget(actor: actor) }
        default: print("\(event.keyCode)")
        }
    }
}
#endif


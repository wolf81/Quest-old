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
    
    private static let tileSize = CGSize(width: 48, height: 48)
    
    private var game: Game!
    
    private var actionBar: ActionBar!
    
    private var statusBar: StatusBar!
    
    private var world: SKNode = SKNode()
    
    private var playerCamera: SKCameraNode!
    
    private var inventory: InventoryNode?
    
    private var characterInfo: CharacterInfoNode?

    // Sprites should be removed on the main thread, to make this easy, we remove sprites in the update loop and then clear this array
    private var spritesToRemove: [SKSpriteNode] = []
    
    // Sprites should be added on the main thread, to make this easy, we add sprites in the update loop and then clear this array
    private var spritesToAdd: [SKSpriteNode] = []
                    
    required init(size: CGSize, userInfo: [String : Any]) {
        self.game = (userInfo[UserInfoKey.game] as! Game)
        
        super.init(size: size)

        self.game.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
            
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        self.spritesToRemove.forEach({ $0.removeFromParent() })
        self.spritesToRemove = []

        self.spritesToAdd.forEach({ self.world.addChild($0) })
        self.spritesToAdd = []
                
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
        let x = CGFloat(coord.x) * GameScene.tileSize.width
        let y = CGFloat(coord.y) * GameScene.tileSize.height
        return CGPoint(x: x, y: y)
    }
    
    static func coordForPoint(_ point: CGPoint) -> vector_int2 {
        let x = Int32((point.x + (GameScene.tileSize.width / 2)) / GameScene.tileSize.width)
        let y = Int32((point.y + (GameScene.tileSize.height / 2)) / GameScene.tileSize.height)
        return vector_int2(x, y)
    }

    // MARK: - Private
    
    private func setUpScene() {
        self.game.start(tileSize: GameScene.tileSize)
        
        self.backgroundColor = SKColor.black
        
        self.actionBar = ActionBar(size: CGSize(width: self.size.width, height: 50), delegate: self)
        self.actionBar.position = CGPoint(x: 0, y: -(size.height / 2))
        self.actionBar.zPosition = 1_000_000_000

        self.playerCamera = SKCameraNode()
        self.playerCamera.position = cameraPositionForCoord(self.game.hero.coord)
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
        
        for entity in self.game.entities {
            entity.sprite.position = GameScene.pointForCoord(entity.coord)
        }
        
        gameDidMove(entity: self.game.hero, path: [self.game.hero.coord], duration: 0)
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
            let inventory = InventoryNode(size: CGSize(width: 600, height: 400), backgroundColor: .black, hero: self.game.hero)
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
            let characterInfo = CharacterInfoNode(size: CGSize(width: 600, height: 400), backgroundColor: .black, hero: self.game.hero)
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
}

func isInRange(origin: vector_int2, radius: Int32, coord: vector_int2) -> Bool {
    return ((coord.x - origin.x) * (coord.x - origin.x) + (coord.y - origin.y) * (coord.y - origin.y)) <= (radius * radius)
}

// MARK: - GameDelegate

extension GameScene: GameDelegate {
    func gameDidChangeSelectionMode(_ selectionMode: SelectionMode) {
        print("selection mode: \(selectionMode)")
        
        clearSelectionModeTiles()
                
        if selectionMode.isSelection {
            for tile in self.game.selectionModeTiles {
                tile.sprite.position = GameScene.pointForCoord(tile.coord)
                self.world.addChild(tile.sprite)
            }
        }
    }
    
    func gameDidAttack(actor: Actor, targetActor: Actor) {
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
        
        self.game.activateNextActor()
    }
    
    func gameDidDie(actor: Actor) {
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        actor.sprite.run(fadeOut)
    }
    
    func gameDidMove(entity: Entity, path: [vector_int2], duration: TimeInterval) {
        if let hero = entity as? Hero {
            let (minCoord, maxCoord) = getMinMaxVisibleCoordsInView()
                                                        
            let viewVisibleCoords = getCoordsInRange(minCoord: minCoord, maxCoord: maxCoord)
            
            for entity in self.game.entities {
                if self.game.actorVisibleCoords.contains(entity.coord) {
                    if entity.sprite.parent == nil {
                        self.world.addChild(entity.sprite)
                    }
                    else {
                        let position = GameScene.pointForCoord(path.last!)
                        hero.sprite.run(SKAction.move(to: position, duration: 2.0))
                    }
                }
                else {
                    entity.sprite.removeFromParent()
                }
            }
            
            // add sprites for all newly added tiles ... these are tiles that used to be out of view bounds
            let addedCoords = viewVisibleCoords.subtracting(self.game.viewVisibleCoords)
            for coord in addedCoords {
                let tile = self.game.tiles[Int(coord.y)][Int(coord.x)]

                if game.actorVisibleCoords.contains(coord) {
                    tile.didExplore = true
                }

                tile.sprite.position = GameScene.pointForCoord(tile.coord)
                tile.sprite.alpha = 0.0
                self.world.addChild(tile.sprite)

                let alpha: CGFloat = self.game.actorVisibleCoords.contains(coord) ? 1.0 : tile.didExplore ? 0.5 : 0.0
                tile.sprite.run(SKAction.fadeAlpha(to: alpha, duration: 3.0))
            }

            // remove sprites for tiles that are out of view bounds
            let removedCoords = self.game.viewVisibleCoords.subtracting(viewVisibleCoords)
            for coord in removedCoords {
                let tile = self.game.tiles[Int(coord.y)][Int(coord.x)]
                tile.sprite.removeFromParent()
            }
                        
            // update the remaining tiles
            let remainingCoords = self.game.viewVisibleCoords.subtracting(addedCoords).subtracting(removedCoords)
            for coord in remainingCoords {
                let tile = self.game.tiles[Int(coord.y)][Int(coord.x)]

                if game.actorVisibleCoords.contains(coord) {
                    tile.didExplore = true
                }

                let alpha: CGFloat = self.game.actorVisibleCoords.contains(coord) ? 1.0 : tile.didExplore ? 0.5 : 0.0
                tile.sprite.run(SKAction.fadeAlpha(to: alpha, duration: 1.5))
            }
            
            self.game.viewVisibleCoords = viewVisibleCoords
            
            moveCamera(path: path, duration: 0.5)
        }
        else {
            let firstCoord = path.first!
            let lastCoord = path.last!
            
            let willShow = self.game.actorVisibleCoords.contains(lastCoord) && self.game.actorVisibleCoords.contains(firstCoord) == false
            
            var move: [SKAction] = []

            let stepCount = path.count + (willShow ? 1 : 0)
            let stepDuration = 1.0 / Double(stepCount)

            if willShow {
                move.append(SKAction.fadeIn(withDuration: stepDuration))
            }
            
            for coord in path {
                let position = GameScene.pointForCoord(coord)
                move.append(SKAction.move(to: position, duration: stepDuration))
            }
            
            entity.sprite.run(SKAction.sequence(move))
        }
        
        self.game.activateNextActor()
    }
    
    func gameDidAdd(entity: EntityProtocol) {
        entity.sprite.position = GameScene.pointForCoord(entity.coord)
        self.spritesToAdd.append(entity.sprite)
    }
    
    func gameDidRemove(entity: EntityProtocol) {
        self.spritesToRemove.append(entity.sprite)
    }

    func gameDidUpdateStatus(message: String) {
        self.statusBar.update(text: message)
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
        let y2 = min(Int32(maxCoord.y + 1), Int32(self.game.level.height - 1))
        
        let x1 = max(Int32(minCoord.x - 1), 0)
        let x2 = min(Int32(maxCoord.x + 1), Int32(self.game.level.width - 1))

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
    
    override func keyUp(with event: NSEvent) {
        debugPrint(event.keyCode)
                
        switch event.keyCode {
        case /* esc  */ 53: dismissCharacterInfoAndInventory()
        case /* a, ← */ 0, 123: self.game.movePlayer(direction: .left)
        case /* d, → */ 2, 124: self.game.movePlayer(direction: .right)
        case /* s, ↓ */ 1, 125: self.game.movePlayer(direction: .down)
        case /* w, ↑ */ 13, 126: self.game.movePlayer(direction: .up)
        case /* i    */ 34: toggleInventory()
        case /* c    */ 8: toggleCharacterInfo()
        default: print("\(event.keyCode)")
        }
    }
}
#endif


//
//  GameScene.swift
//  Quest Shared
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var lastUpdateTime: TimeInterval = 0
    
    private static let tileSize = CGSize(width: 48, height: 48)
    
    private var game: Game!
    
    private var actionBar: ActionBar!
    
    private var world: SKNode = SKNode()
    
    private var playerCamera: SKCameraNode!

    // Sprites should be removed on the main thread, to make this easy, we remove sprites in the update loop and then clear this array
    private var spritesToRemove: [SKSpriteNode] = []
    
    // Sprites should be added on the main thread, to make this easy, we add sprites in the update loop and then clear this array
    private var spritesToAdd: [SKSpriteNode] = []
        
    init(game: Game, size: CGSize) {
        self.game = game
        
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
        
        for tile in self.game.tiles {
            let position = GameScene.pointForCoord(tile.coord)
            tile.sprite.position = position
            self.world.addChild(tile.sprite)
        }

        for entity in self.game.entities {
            let position = GameScene.pointForCoord(entity.coord)
            entity.sprite.position = position            
            self.world.addChild(entity.sprite)
        }
        
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
}

func isInRange(origin: vector_int2, radius: Int, coord: vector_int2) -> Bool {
    return ((coord.x - origin.x) * (coord.x - origin.x) + (coord.y - origin.y) * (coord.y - origin.y)) <= (radius * radius)
}

// MARK: - GameDelegate

extension GameScene: GameDelegate {
    func gameDidMove(hero: Hero, path: [vector_int2], duration: TimeInterval) {
        moveCamera(path: path, duration: duration)
    }
    
    func gameDidAdd(entity: EntityProtocol) {
        entity.sprite.position = GameScene.pointForCoord(entity.coord)
        self.spritesToAdd.append(entity.sprite)
    }
    
    func gameDidRemove(entity: EntityProtocol) {
        self.spritesToRemove.append(entity.sprite)
    }
}

// MARK: - ActionBarDelegate

extension GameScene: ActionBarDelegate {
    func actionBarDidSelectDefend() {
        print("defend")
    }
    
    func actionBarDidSelectMove() {
        self.game.showMovementTilesForHero()
    }
    
    func actionBarDidSelectMeleeAttack() {
        self.game.showMeleeAttackTilesForHero()
    }

    func actionBarDidSelectRangeAttack() {
        self.game.showRangedAttackTilesForHero()
    }
    
    func actionBarDidSelectCastSpell() {
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
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        if self.nodes(at: location).contains(self.actionBar) {
            self.actionBar.convert(location, from: self)
            self.actionBar.mouseUp(with: event)
        } else if self.nodes(at: location).contains(self.world) {
            let coord = GameScene.coordForPoint(location)
            self.game.handleInteraction(at: coord)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 123: self.game.movePlayer(direction: .left)
        case 124: self.game.movePlayer(direction: .right)
        case 125: self.game.movePlayer(direction: .down)
        case 126: self.game.movePlayer(direction: .up)
        default: print("\(event.keyCode)")
        }
    }
}
#endif


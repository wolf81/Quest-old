//
//  GameScene.swift
//  Quest Shared
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    private var lastUpdateTime: TimeInterval = 0
    
    fileprivate static let tileSize = CGSize(width: 64, height: 64)    
    
    private var game: Game!
    
    private var actionBar: ActionBar!
    
    private var world: SKNode = SKNode()
    
    private var playerCamera: SKCameraNode!

    private var spritesToRemove: [SKSpriteNode] = []
    
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
        self.game.update(deltaTime)
        
        self.lastUpdateTime = currentTime
    }
    
    static func pointForCoord(_ coord: SIMD2<Int32>) -> CGPoint {
        let x = CGFloat(coord.x) * GameScene.tileSize.width
        let y = CGFloat(coord.y) * GameScene.tileSize.height
        return CGPoint(x: x, y: y)
    }

    // MARK: - Private
    
    private func setUpScene() {
        self.game.start(tileSize: GameScene.tileSize)
        
        for entity in self.game.entities {
            let position = GameScene.pointForCoord(entity.coord)
            entity.sprite.position = position
            
            self.world.addChild(entity.sprite)
        }

        self.actionBar = ActionBar(size: CGSize(width: self.size.width, height: 50), delegate: self)
        self.actionBar.position = CGPoint(x: 0, y: -(size.height / 2))

        self.playerCamera = SKCameraNode()
        self.playerCamera.position = cameraPositionForCoord(self.game.hero.coord)
        self.playerCamera.addChild(self.actionBar)

        self.world.addChild(self.playerCamera)
        scene?.camera = self.playerCamera
        
        addChild(self.world)
    }

    private func movePlayer(direction: Direction) {
        self.game.movePlayer(direction: direction)
    }
    
    private func moveCamera(to coord: SIMD2<Int32> , duration: TimeInterval) {
        let position = cameraPositionForCoord(coord)
        self.playerCamera.run(SKAction.move(to: position, duration: duration))
    }
    
    private func cameraPositionForCoord(_ coord: SIMD2<Int32>) -> CGPoint {
        var position = GameScene.pointForCoord(coord)
        position.y -= self.actionBar.size.height
        return position
    }
}

// MARK: - GameDelegate

extension GameScene: GameDelegate {
    func gameDidMove(hero: Hero, to coord: SIMD2<Int32>, duration: TimeInterval) {
        moveCamera(to: coord, duration: duration)
    }
    
    func gameDidAdd(entity: Entity) {
        entity.sprite.position = GameScene.pointForCoord(entity.coord)
        self.spritesToAdd.append(entity.sprite)
    }
    
    func gameDidRemove(entity: Entity) {
        self.spritesToRemove.append(entity.sprite)
    }
}

// MARK: - ActionBarDelegate

extension GameScene: ActionBarDelegate {
    func actionBarDidSelectDefend() {
        print("defend")
    }
    
    func actionBarDidSelectMove() {
        print("move")
        self.game.showMovementTilesForHero()
    }
    
    func actionBarDidSelectAttackMelee() {
        print("attack melee")
    }
    
    func actionBarDidSelectAttackRanged() {
        print("attack ranged")
    }
    
    func actionBarDidSelectCastSpell() {
        print("cast spell")
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


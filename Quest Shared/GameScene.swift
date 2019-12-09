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
    
    init(game: Game, size: CGSize) {
        self.game = game
                
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
        
    func setUpScene() {
        self.game.start(tileSize: GameScene.tileSize)
        
        for entity in self.game.entities {
            let position = pointForCoord(entity.coord)
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
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let deltaTime = currentTime - lastUpdateTime
        
        // Update game state
        self.game.update(deltaTime)
        
        self.lastUpdateTime = currentTime
    }
    
    func movePlayer(direction: Direction) {
        self.game.movePlayer(direction: direction)
    }
        
    public func moveCamera(to coord: SIMD2<Int32> , duration: TimeInterval) {
        let position = cameraPositionForCoord(coord)
        self.playerCamera.run(SKAction.move(to: position, duration: duration))
    }
    
    private func cameraPositionForCoord(_ coord: SIMD2<Int32>) -> CGPoint {
        var position = pointForCoord(coord)
        position.y -= self.actionBar.size.height
        return position
    }
}

func pointForCoord(_ coord: SIMD2<Int32>) -> CGPoint {
    let x = CGFloat(coord.x) * GameScene.tileSize.width
    let y = CGFloat(coord.y) * GameScene.tileSize.height
    return CGPoint(x: x, y: y)
}

extension GameScene: ActionBarDelegate {
    func actionBarDidSelectDefend() {
        print("defend")
    }
    
    func actionBarDidSelectMove() {
        print("move")
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
        if nodes(at: location).contains(self.actionBar) {
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


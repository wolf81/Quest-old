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
    
    private let game = Game()
    
    private var playerCamera: SKCameraNode!
    
    class func newGameScene(size: CGSize) -> GameScene {
        let scene = GameScene(size: size)
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
            
        return scene
    }
    
    func setUpScene() {
        self.game.start(scene: self, tileSize: GameScene.tileSize)
        
        for entity in self.game.entities {
            let position = pointForCoord(entity.coord)
            entity.sprite.position = position
            
            self.addChild(entity.sprite)
        }
        
        self.playerCamera = SKCameraNode()
        self.playerCamera.position = pointForCoord(self.game.player.coord)
        addChild(self.playerCamera)
        scene?.camera = self.playerCamera
    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()        
    }
    #endif
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let deltaTime = currentTime - lastUpdateTime
        
        // Update game state
        self.game.update(deltaTime)
        
        self.lastUpdateTime = currentTime
    }
    
    // TODO:
    // game scene shouldn't contain any game logic at all - the logic should all be contained by the
    // Game class - perhaps the game should have some delegate that notifies the scene and the
    // scene can then show the proper animation. E.g. after player moved to a position, show
    // movement animation for the sprite. Or perhaps just do all animation in the Game class, but
    // then the game class needs to know the size of the tiles
    func movePlayer(direction: Direction) {
        let coord = self.game.player.coord &+ direction.coord        
        
        let moveDuration: TimeInterval = 0.2
        let position = pointForCoord(coord)
        
        guard self.game.canMoveEntity(entity: self.game.player, toCoord: coord) else {
            return
        }
        
        self.game.player.move(to: position, duration: moveDuration) {
            self.game.player.coord = coord
        }
        
        moveCamera(toPosition: position, duration: moveDuration)
    }
    
    func moveCamera(toPosition: CGPoint, duration: TimeInterval) {
        self.playerCamera.run(SKAction.move(to: toPosition, duration: duration))
    }
}

func pointForCoord(_ coord: int2) -> CGPoint {
    let x = CGFloat(coord.x) * GameScene.tileSize.width
    let y = CGFloat(coord.y) * GameScene.tileSize.height
    return CGPoint(x: x, y: y)
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
// Mouse-based event handling
extension GameScene {
    override func mouseDown(with event: NSEvent) {
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
    }    
}
#endif


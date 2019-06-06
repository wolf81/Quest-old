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
    
    private static let tileSize = CGSize(width: 64, height: 64)
    
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
            let position = CGPoint(x: CGFloat(entity.coord.x) * GameScene.tileSize.width,
                                   y: CGFloat(entity.coord.y) * GameScene.tileSize.height)
            entity.sprite.position = position
            
            self.addChild(entity.sprite)
        }
        
        self.playerCamera = SKCameraNode()
        self.playerCamera.position = CGPoint(x: CGFloat(game.player.coord.x) * GameScene.tileSize.width,
                                             y: CGFloat(game.player.coord.y) * GameScene.tileSize.height)
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


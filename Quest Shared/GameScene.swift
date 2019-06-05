//
//  GameScene.swift
//  Quest Shared
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var level: Level! {
        didSet {
            guard let level = self.level else {
                fatalError()
            }
            print(level)
        }
    }

    class func newGameScene(size: CGSize) -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        let scene = GameScene(size: size)
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill

        scene.level = Level()
        
        return scene
    }
    
    func setUpScene() {
        let level = Level()
        
        for y in (0 ..< level.height) {
            for x in (0 ..< level.width) {
                let tile = level.getTileAt(x: x, y: y)
                let color : SKColor = tile == .empty ? .blue : .red
                let sprite = SKSpriteNode(texture: nil, color: color, size: CGSize(width: 64, height: 64))
                sprite.position = CGPoint(x: x * 64, y: y * 64)
                self.addChild(sprite)
            }
        }
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


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
    
    private var playerCamera: SKCameraNode!
    
    init(game: Game, size: CGSize) {
        self.game = game
            
        super.init(size: size)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    class func newGameScene(game: Game, size: CGSize) -> GameScene {
        let scene = GameScene(game: game, size: size)
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        scene.backgroundColor = .black
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
        self.playerCamera.position = pointForCoord(self.game.hero.coord)
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
    
    func movePlayer(direction: Direction) {
        self.game.movePlayer(direction: direction)
    }
        
    public func moveCamera(toPosition: CGPoint, duration: TimeInterval) {
        self.playerCamera.run(SKAction.move(to: toPosition, duration: duration))
    }
}

func pointForCoord(_ coord: SIMD2<Int32>) -> CGPoint {
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
// Mouse- & keyboard-based event handling
extension GameScene {
    override func mouseDown(with event: NSEvent) {
    }
    
    override func mouseDragged(with event: NSEvent) {
    }
    
    override func mouseUp(with event: NSEvent) {
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


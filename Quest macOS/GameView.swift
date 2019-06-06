//
//  GameView.swift
//  Quest macOS
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class GameView : SKView {
    private var gameScene: GameScene {
        return self.scene as! GameScene
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 123: self.gameScene.movePlayer(direction: .left)
        case 124: self.gameScene.movePlayer(direction: .right)
        case 125: self.gameScene.movePlayer(direction: .down)
        case 126: self.gameScene.movePlayer(direction: .up)
        default: print("\(event.keyCode)")
        }
        
        super.keyUp(with: event)
    }
}

//
//  GameView.swift
//  Quest macOS
//
//  Created by Wolfgang Schreurs on 05/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class GameView : SKView {
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func keyDown(with event: NSEvent) {
        
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 123: print("move left")
        case 124: print("move right")
        case 125: print("move down")
        case 126: print("move up")
        default: print("\(event.keyCode)")
        }
        
        super.keyUp(with: event)
    }
}

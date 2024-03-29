//
//  ActionBarButton.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 09/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class ActionBarButton: SKShapeNode {
    let sprite: SKSpriteNode
    
    var action: ActionBar.ButtonAction { didSet { updateSpriteForAction() } }
        
    var isEnabled: Bool = false
    
    var isActive: Bool = false
    
    init(action: ActionBar.ButtonAction) {
        self.action = action
        
        let spriteSize = CGSize(width: action.size.width - (action.lineWidth * 2), height: action.size.height - (action.lineWidth * 2))
        let texture = SKTexture(imageNamed: action.textureName)
        self.sprite = SKSpriteNode(texture: texture, color: .white, size: spriteSize)
        
        super.init()
                
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -action.size.width / 2, y: action.size.height / 2), size: action.size), transform: nil)
        self.strokeColor = SKColor.white
        self.lineWidth = action.lineWidth

        addChild(self.sprite)
        
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.sprite.position = CGPoint(x: 0, y: action.size.height)
    }
    
    func update(action: ActionBar.ButtonAction) {
        self.action = action
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Private
    
    private func updateSpriteForAction() {
        self.sprite.texture = SKTexture(imageNamed: action.textureName)
    }
}

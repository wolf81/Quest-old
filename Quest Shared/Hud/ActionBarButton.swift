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
    
    let action: ActionBar.ButtonAction
        
    var isEnabled: Bool = false 
    
    init(size: CGSize, action: ActionBar.ButtonAction) {
        self.action = action
        
        let spriteSize = CGSize(width: size.width - (action.lineWidth * 2), height: size.height - (action.lineWidth * 2))
        let texture = SKTexture(imageNamed: action.textureName)
        self.sprite = SKSpriteNode(texture: texture, color: .white, size: spriteSize)
        
        super.init()
                
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -size.width / 2, y: size.height / 2), size: size), transform: nil)
        self.strokeColor = SKColor.white
        
        addChild(self.sprite)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.sprite.position = CGPoint(x: 0, y: size.height)
                
        self.lineWidth = action.lineWidth
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

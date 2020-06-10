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
    
    private struct AnimationKey {
        static let pulse = "pulse"
    }
    
    var isEnabled: Bool = false {
        didSet {
            updateForEnabledState()
        }
    }
    
    init(size: CGSize, action: ActionBar.ButtonAction) {
        self.action = action
        
        let spriteSize = CGSize(width: size.width - 4, height: size.height - 4)
        let texture = SKTexture(imageNamed: action.textureName)
        self.sprite = SKSpriteNode(texture: texture, color: .white, size: spriteSize)
        
        super.init()
                
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -size.width / 2, y: size.height / 2), size: size), transform: nil)
        self.strokeColor = SKColor.white
        
        addChild(self.sprite)
        self.sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.sprite.position = CGPoint(x: 0, y: size.height)
                
        self.lineWidth = 2
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Private
    
    private func updateForEnabledState() {
//        if self.isEnabled {
//            guard self.sprite.action(forKey: AnimationKey.pulse) == nil else { return }
//            
//            let pulse = SKAction.repeatForever(SKAction.sequence([
//                SKAction.colorize(with: .yellow, colorBlendFactor: 0.8, duration: 8.0),
//                SKAction.colorize(with: .orange, colorBlendFactor: 0.8, duration: 4.0),
//                SKAction.colorize(with: .red, colorBlendFactor: 0.8, duration: 8.0),
//                SKAction.colorize(with: .orange, colorBlendFactor: 0.8, duration: 4.0),
//            ]))
//            self.sprite.run(pulse, withKey: AnimationKey.pulse)
//        } else {
//            self.sprite.removeAllActions()
//            self.sprite.colorBlendFactor = 0
//        }
    }
}

//
//  ButtonNode.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class ButtonNode: SKShapeNode {
    private let label: SKLabelNode
    
    var isEnabled: Bool = true {
        didSet {
            self.label.alpha = self.isEnabled ? 1.0 : 0.5
        }
    }
            
    init(size: CGSize, color: SKColor, text: String) {
        self.label = SKLabelNode(text: text)
        self.label.fontName = "Papyrus"
        self.label.fontSize = 14
        self.label.position = CGPoint(x: 0, y: -(self.label.frame.height / 2))
                
        super.init()
                
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size), transform: nil)
        
        self.fillColor = color
        self.strokeColor = .white
        self.lineWidth = 1
        
        addChild(self.label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }        
}

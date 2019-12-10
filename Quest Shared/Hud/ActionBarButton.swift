//
//  ActionBarButton.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 09/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

class ActionBarButton: SKShapeNode {
    init(size: CGSize, color: SKColor) {
        super.init()
        
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -size.width / 2, y: size.height / 2), size: size), transform: nil)
        self.strokeColor = SKColor.white
        self.fillColor = color
        
        self.lineWidth = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
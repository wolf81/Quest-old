//
//  HealthBar.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class HealthBar: SKShapeNode {
    private var fillBar: SKSpriteNode
    
    init(size: CGSize) {
        self.fillBar = SKSpriteNode(color: .green, size: size)
        
        super.init()
        
        let cornerWidth = size.height / 4
        self.path = CGPath(roundedRect: CGRect(origin: .zero, size: size), cornerWidth: cornerWidth, cornerHeight: cornerWidth, transform: nil)

        self.strokeColor = SKColor.white
        self.lineWidth = 1
                
        addChild(self.fillBar)
        self.fillBar.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func update(health: CGFloat) {
        let width = self.frame.width * health
        self.fillBar.size = CGSize(width: width, height: self.frame.height)
    }
}

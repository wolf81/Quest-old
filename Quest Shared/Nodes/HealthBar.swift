//
//  HealthBar.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class HealthBar: SKCropNode {
    private var barNode: SKSpriteNode
    
    private var borderNode: SKShapeNode
    
    init(size: CGSize) {
        self.barNode = SKSpriteNode(color: .green, size: size)

        self.borderNode = SKShapeNode(rect: CGRect(origin: .zero, size: size), cornerRadius: size.height / 4)
        self.borderNode.strokeColor = SKColor.white
        self.borderNode.fillColor = SKColor.black.withAlphaComponent(0.5)
        self.borderNode.lineWidth = 1

        super.init()
        
        addChild(self.borderNode)
        self.borderNode.position = .zero
        
        self.maskNode = self.borderNode
        
        self.addChild(self.barNode)
        
        self.barNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func update(health: CGFloat) {
        let width = self.borderNode.frame.width * health
        self.barNode.size = CGSize(width: width, height: self.borderNode.frame.height)
    }
}

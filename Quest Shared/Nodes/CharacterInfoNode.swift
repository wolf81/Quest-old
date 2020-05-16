//
//  CharacterInfoNode.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 16/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class CharacterInfoNode: SKShapeNode {
    
    
    init(size: CGSize, backgroundColor: SKColor, hero: Hero) {
        super.init()
        
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -(size.width / 2), y: -(size.height / 2)), size: size), transform: nil)
        
        self.lineWidth = 1
        self.strokeColor = .white
        self.fillColor = backgroundColor

//        self.backpack.position = CGPoint(x: (size.width - nodeWidth) / 2 - spacing, y: 0)
//        self.paperDoll.position = CGPoint(x: -(size.width - nodeWidth) / 2 + spacing, y: 0)

        self.zPosition = DrawLayerHelper.zPosition(for: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

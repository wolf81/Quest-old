//
//  TargetNode.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 29/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class TargetNode: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: "cursor_green")
        super.init(texture: texture, color: .clear, size: Constants.tileSize)
        
        self.zPosition = DrawLayerHelper.zPosition(for: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}

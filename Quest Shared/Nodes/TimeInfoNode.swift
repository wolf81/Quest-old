//
//  TimeInfoNode.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 06/06/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit
import Harptos
import Fenris

class TimeInfoNode: SKShapeNode {
    private let label: SKLabelNode = SKLabelNode()
    
    private let timeFormatter = HarptosTimeFormatter(monthFormat: "hh:mm:ss", festivalFormat: "hh:mm:ss")
            
    init(size: CGSize, font: Font) {
        let rect = CGRect(origin: .zero, size: size)
        let cornerRadius = size.height / 3
                
        super.init()

        self.path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

        self.fillColor = SKColor.black.withAlphaComponent(0.5)
        self.strokeColor = SKColor.white
        self.lineWidth = 1
                
        self.label.fontName = font.fontName
        self.label.fontSize = font.pointSize
        self.label.fontColor = SKColor.white
        self.label.position = CGPoint(x: size.width / 2, y: (size.height - font.capHeight) / 2)
        self.zPosition = DrawLayerHelper.zPosition(for: self)
        
        addChild(self.label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func update(time: HarptosTime) {
        self.label.text = self.timeFormatter.string(from: time)
    }
}

//
//  StatusBar.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 19/04/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit
import Fenris

class StatusBar: SKShapeNode {
    let label: SKLabelNode = SKLabelNode()
    
    private var dismissTime: Date = Date()
    
    private var dismissBlock: DispatchWorkItem?
        
    init(size: CGSize, font: Font) {
        super.init()
                
        let cornerWidth = size.height / 4
        self.path = CGPath(roundedRect: CGRect(origin: .zero, size: size), cornerWidth: cornerWidth, cornerHeight: cornerWidth, transform: nil)
        
        self.fillColor = SKColor.black.withAlphaComponent(0.5)
        self.strokeColor = SKColor.white
        self.lineWidth = 1
                
        self.label.fontName = font.fontName
        self.label.fontSize = font.pointSize
        self.label.fontColor = SKColor.white
        self.label.position = CGPoint(x: size.width / 2, y: (size.height - font.capHeight) / 2)
     
        self.zPosition = 1_000_000
        
        self.addChild(self.label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public func update(text: String?) {
        if let dismissBlock = self.dismissBlock {
            dismissBlock.cancel()
        }

        run(SKAction.fadeIn(withDuration: 0.5))

        self.label.text = text

        self.dismissBlock = DispatchWorkItem { self.dismiss() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: self.dismissBlock!)
    }
    
    private func dismiss() {
        print("dismiss")
        
        run(SKAction.fadeOut(withDuration: 0.5))
    }
}

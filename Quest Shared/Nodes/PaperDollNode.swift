//
//  PaperDollNode.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class PaperDollNode: SKShapeNode {
    private let chest: EquippedItemNode
    
    private let leftArm: EquippedItemNode
    
    private let rightArm: EquippedItemNode
    
    init(size: CGSize, backgroundColor: SKColor) {
        let itemSize = CGSize(width: 50, height: 50)
        self.chest = EquippedItemNode(size: itemSize)
        self.leftArm = EquippedItemNode(size: itemSize)
        self.rightArm = EquippedItemNode(size: itemSize)
        
        super.init()
        
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -(size.width / 2), y: -(size.height / 2)), size: size), transform: nil)
        
        self.fillColor = backgroundColor
        self.strokeColor = .white
        self.lineWidth = 1
        
        addChild(self.chest)
        addChild(self.leftArm)
        addChild(self.rightArm)
        
        self.leftArm.position = CGPoint(x: size.width / 3, y: 0)
        self.rightArm.position = CGPoint(x: -(size.width / 3), y: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func update(equipment: Equipment) {
        self.chest.update(entity: equipment.armor)
        self.leftArm.update(entity: equipment.shield)
        self.rightArm.update(entity: equipment.meleeWeapon)
    }
    
    // MARK: - Private
    
    private class EquippedItemNode: SKShapeNode {
        var sprite: SKSpriteNode
        
        init(size: CGSize) {
            self.sprite = SKSpriteNode(color: .red, size: CGSize(width: size.width - 2, height: size.height - 2))
            
            super.init()
            
            self.path = CGPath(rect: CGRect(origin: CGPoint(x: -(size.width / 2), y: -(size.height / 2)), size: size), transform: nil)
            
            self.lineWidth = 1
            self.strokeColor = .white
            self.fillColor = .clear
            
            addChild(self.sprite)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError()
        }
        
        func update(entity: Entity) {
            let update = SKAction.setTexture(entity.sprite.texture!, resize: false)
            self.sprite.run(update)
        }
    }
}

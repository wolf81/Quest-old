//
//  PaperDollNode.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

protocol PaperDollNodeDelegate: class {
    func paperDoll(_ paperDoll: PaperDollNode, didUnequip equipment: Equippable)
}

class PaperDollNode: SKShapeNode {
    private let silhouette: SKSpriteNode
    
    private let chest: EquippedItemNode
    
    private let leftArm: EquippedItemNode
    
    private let rightArm: EquippedItemNode
    
    weak var delegate: PaperDollNodeDelegate?
        
    init(size: CGSize, backgroundColor: SKColor) {
        let itemSize = CGSize(width: 50, height: 50)
        self.chest = EquippedItemNode(size: itemSize)
        self.leftArm = EquippedItemNode(size: itemSize)
        self.rightArm = EquippedItemNode(size: itemSize)
        
        let silhouetteTexture = SKTexture(imageNamed: "paper_doll")
        let silhouetteSize = CGSize(width: size.width - 30, height: size.height - 30)
        self.silhouette = SKSpriteNode(texture: silhouetteTexture, color: SKColor(white: 0.25, alpha: 1.0), size: silhouetteSize)
        self.silhouette.colorBlendFactor = 1.0
        
        super.init()
        
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -(size.width / 2), y: -(size.height / 2)), size: size), transform: nil)
        
        self.fillColor = backgroundColor
        self.strokeColor = .white
        self.lineWidth = 1
        
        addChild(self.silhouette)
        addChild(self.chest)
        addChild(self.leftArm)
        addChild(self.rightArm)
        
        self.silhouette.zPosition = 0
        self.chest.zPosition = 1
        self.leftArm.position = CGPoint(x: size.width / 3, y: 0)
        self.leftArm.zPosition = 1
        self.rightArm.position = CGPoint(x: -(size.width / 3), y: 0)
        self.rightArm.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func update(equipment: Equipment) {
        self.chest.equipment = equipment[.chest]
        self.leftArm.equipment = equipment[.leftArm]
        self.rightArm.equipment = equipment[.rightArm]
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)

        let nodes = [self.leftArm, self.rightArm, self.chest]

        if let selectedNode = nodes.filter({ $0.contains(location) }).first {
            print("selected: \(selectedNode)")

            if let equipment = selectedNode.equipment {
                selectedNode.equipment = nil
                
                self.delegate?.paperDoll(self, didUnequip: equipment)
            }            
        }
    }
    
    // MARK: - Private
    
    private class EquippedItemNode: SKShapeNode {
        var sprite: SKSpriteNode
        
        var equipment: Equippable? {
            didSet {
                guard let equipment = self.equipment else {
                    return self.sprite.texture = nil
                }
                
                let update = SKAction.setTexture(equipment.sprite.texture!, resize: false)
                self.sprite.run(update)
            }
        }
        
        init(size: CGSize) {
            self.sprite = SKSpriteNode(color: .clear, size: CGSize(width: size.width - 2, height: size.height - 2))
            
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
    }
}

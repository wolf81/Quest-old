//
//  PaperDollNode.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

protocol PaperDollNodeDelegate: class {
    func paperDoll(_ paperDoll: PaperDollNode, didUnequip equipmentSlot: EquipmentSlot)
    
    func paperDoll(_ paperDoll: PaperDollNode, equipmentIn equipmentSlot: EquipmentSlot) -> Equippable?
}

class PaperDollNode: SKShapeNode {
    private let silhouette: SKSpriteNode
    
    private let chest: EquippedItemNode
    private let mainhand: EquippedItemNode
    private let mainhand2: EquippedItemNode
    private let offhand: EquippedItemNode
    private let offhand2: EquippedItemNode
    private let ring: EquippedItemNode
    private let feet: EquippedItemNode
    private let head: EquippedItemNode
    
    weak var delegate: PaperDollNodeDelegate? {
        didSet {
            reload()
        }
    }
        
    init(size: CGSize, backgroundColor: SKColor) {
        let itemSize = CGSize(width: 50, height: 50)
        self.chest = EquippedItemNode(size: itemSize, equipmentSlot: .chest)
        self.mainhand = EquippedItemNode(size: itemSize, equipmentSlot: .mainhand)
        self.mainhand2 = EquippedItemNode(size: itemSize, equipmentSlot: .mainhand2)
        self.offhand = EquippedItemNode(size: itemSize, equipmentSlot: .offhand)
        self.offhand2 = EquippedItemNode(size: itemSize, equipmentSlot: .offhand2)
        self.ring = EquippedItemNode(size: itemSize, equipmentSlot: .ring)
        self.feet = EquippedItemNode(size: itemSize, equipmentSlot: .feet)
        self.head = EquippedItemNode(size: itemSize, equipmentSlot: .head)
        
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
        addChild(self.mainhand)
        addChild(self.mainhand2)
        addChild(self.offhand)
        addChild(self.offhand2)
        addChild(self.ring)
        addChild(self.feet)
        addChild(self.head)
        
        self.silhouette.zPosition = 0
        self.chest.zPosition = 1
        self.mainhand.position = CGPoint(x: -(size.width / 3), y: itemSize.height / 2)
        self.mainhand.zPosition = 1
        self.mainhand2.position = CGPoint(x: -(size.width / 3), y: -(itemSize.height / 2))
        self.mainhand2.zPosition = 1
        self.offhand.position = CGPoint(x: size.width / 3, y: itemSize.height / 2)
        self.offhand.zPosition = 1
        self.offhand2.position = CGPoint(x: size.width / 3, y: -(itemSize.height / 2))
        self.offhand2.zPosition = 1
        self.ring.position = CGPoint(x: -size.width / 3, y: size.height / 2.5)
        self.ring.zPosition = 1
        self.feet.position = CGPoint(x: 0, y: -size.height / 2.5)
        self.feet.zPosition = 1
        self.head.position = CGPoint(x: 0, y: size.height / 2.5)
        self.head.zPosition = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: Notification.Name.actorDidChangeWeapons, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.actorDidChangeWeapons, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
        
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)

        let nodes = [self.mainhand, self.offhand, self.chest, self.ring, self.feet, self.head]

        if let selectedNode = nodes.filter({ $0.contains(location) }).first {
            print("selected: \(selectedNode)")

            if let _ = selectedNode.equipment {
                selectedNode.equipment = nil
                
                self.delegate?.paperDoll(self, didUnequip: selectedNode.equipmentSlot)
            }            
        }
    }
    
    @objc func reload() {
        self.chest.equipment = self.delegate?.paperDoll(self, equipmentIn: .chest)
        self.mainhand.equipment = self.delegate?.paperDoll(self, equipmentIn: .mainhand)
        self.offhand.equipment = self.delegate?.paperDoll(self, equipmentIn: .offhand)
        self.ring.equipment = self.delegate?.paperDoll(self, equipmentIn: .ring)
        self.feet.equipment = self.delegate?.paperDoll(self, equipmentIn: .feet)
        self.head.equipment = self.delegate?.paperDoll(self, equipmentIn: .head)
        self.mainhand2.equipment = self.delegate?.paperDoll(self, equipmentIn: .mainhand2)
        self.offhand2.equipment = self.delegate?.paperDoll(self, equipmentIn: .offhand2)
    }
    
    // MARK: - Private
    
    private class EquippedItemNode: SKShapeNode {
        var sprite: SKSpriteNode
        
        let equipmentSlot: EquipmentSlot
        
        var equipment: Equippable? {
            didSet {
                guard let equipment = self.equipment else {
                    return self.sprite.texture = nil
                }
                
                let update = SKAction.sequence([
                    SKAction.setTexture(equipment.sprite.texture!, resize: true),
                    SKAction.resize(toWidth: self.frame.width - 10, height: self.frame.height - 10, duration: 0)
                ])
                self.sprite.run(update)
            }
        }
        
        init(size: CGSize, equipmentSlot: EquipmentSlot) {
            self.equipmentSlot = equipmentSlot
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

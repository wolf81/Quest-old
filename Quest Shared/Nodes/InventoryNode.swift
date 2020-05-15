//
//  InventoryNode.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

import Fenris

class InventoryNode: SKShapeNode {
    private let backpack: ListNode
    private let paperDoll: PaperDollNode
    
    private let hero: Hero
    
    init(size: CGSize, backgroundColor: SKColor, hero: Hero) {
        self.hero = hero
        
        let spacing: CGFloat = 5
        let nodeWidth = (size.width - spacing * 3) / 2
        let nodeSize = CGSize(width: nodeWidth, height: size.height - spacing * 2)
        self.backpack = ListNode(size: nodeSize, orientation: .vertical, backgroundColor: backgroundColor)
        self.paperDoll = PaperDollNode(size: nodeSize, backgroundColor: backgroundColor)
        
        super.init()
        
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -(size.width / 2), y: -(size.height / 2)), size: size), transform: nil)
        
        addChild(self.backpack)
        addChild(self.paperDoll)
        
        self.backpack.delegate = self
        self.paperDoll.delegate = self

        self.lineWidth = 1
        self.strokeColor = .white
        self.fillColor = backgroundColor

        self.backpack.position = CGPoint(x: (size.width - nodeWidth) / 2 - spacing, y: 0)
        self.paperDoll.position = CGPoint(x: -(size.width - nodeWidth) / 2 + spacing, y: 0)
        
        self.zPosition = DrawLayerHelper.zPosition(for: self)                
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func mouseUp(with event: NSEvent) {
        self.backpack.mouseUp(with: event)
        self.paperDoll.mouseUp(with: event)
    }
    
    override func mouseDown(with event: NSEvent) {
        self.backpack.mouseDown(with: event)
    }
    
    private func reload() {
        self.backpack.reload()
        self.paperDoll.reload()
        
        self.hero.updateSpriteForEquipment()
        print(self.hero)
    }
}

extension InventoryNode: PaperDollNodeDelegate {
    func paperDoll(_ paperDoll: PaperDollNode, didUnequip equipmentSlot: EquipmentSlot) {
        self.hero.inventory.unequip(equipmentSlot)
        reload()
    }
    
    func paperDoll(_ paperDoll: PaperDollNode, equipmentIn equipmentSlot: EquipmentSlot) -> Equippable? {
        self.hero.inventory.equippedItem(in: equipmentSlot)
    }
}

extension InventoryNode: ListNodeDelegate {
    func listNodeNumberOfItems(listNode: ListNode) -> Int {
        return self.hero.inventory.backpack.count
    }
    
    func listNode(_ listNode: ListNode, nodeAtIndex index: Int, size: CGSize) -> SKNode {
        let item = self.hero.inventory.backpack[index]
        
        let label = SKLabelNode(text: "\(item.name)")
        label.fontSize = 16
        label.fontName = "Papyrus"
        label.position = CGPoint(x: 0, y: -(label.frame.height / 2))

        let node = SKSpriteNode(color: SKColor.black, size: size)
        
        node.addChild(label)
        
        return node
    }
    
    func listNode(_ listNode: ListNode, didSelectNode node: SKNode, atIndex index: Int) {
        self.hero.inventory.equip(at: index)
        
        if let usableItem = self.hero.inventory.backpack[index] as? Usable {
            usableItem.use(actor: self.hero)
        }
        
        reload()
    }
    
    func listNodeWidthForItem(_ listNode: ListNode) -> CGFloat {
        return 0
    }
    
    func listNodeHeightForItem(_ listNode: ListNode) -> CGFloat {
        return 40
    }
}

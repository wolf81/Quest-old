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
        
        self.lineWidth = 1
        self.strokeColor = .white
        self.fillColor = backgroundColor

        self.backpack.position = CGPoint(x: (size.width - nodeWidth) / 2 - spacing, y: 0)
        self.paperDoll.position = CGPoint(x: -(size.width - nodeWidth) / 2 + spacing, y: 0)
        
        self.zPosition = DrawLayerHelper.zPosition(for: self)
        
        self.paperDoll.update(equipment: self.hero.equipment)
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
}

extension InventoryNode: ListNodeDelegate {
    func listNodeNumberOfItems(listNode: ListNode) -> Int {
        return 9
    }
    
    func listNode(_ listNode: ListNode, nodeAtIndex index: Int, size: CGSize) -> SKNode {
        let label = SKLabelNode(text: "Item \(index)")
        label.fontSize = 16
        label.fontName = "Papyrus"
        label.position = CGPoint(x: 0, y: -(label.frame.height / 2))

        let node = SKSpriteNode(color: SKColor.black, size: size)
        
        node.addChild(label)
        
        return node
    }
    
    func listNode(_ listNode: ListNode, didSelectNode node: SKNode) {
        if let label = node.children.first as? SKLabelNode, let text = label.text {
            print("\(text)")
        }
    }
    
    func listNodeWidthForItem(_ listNode: ListNode) -> CGFloat {
        return 0
    }
    
    func listNodeHeightForItem(_ listNode: ListNode) -> CGFloat {
        return 40
    }
}

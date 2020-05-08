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
    private let listNode: ListNode
    
    init(size: CGSize, backgroundColor: SKColor) {
        self.listNode = ListNode(size: CGSize(width: size.width / 2 - 10, height: size.height - 10), orientation: .vertical, backgroundColor: backgroundColor)
        
        super.init()
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -(size.width / 2), y: -(size.height / 2)), size: size), transform: nil)
        
        addChild(self.listNode)
        
        self.listNode.delegate = self
        
        self.lineWidth = 1
        self.strokeColor = .white
        self.fillColor = backgroundColor

        self.listNode.position = CGPoint(x: size.width / 4, y: 0)
        
        self.zPosition = DrawLayerHelper.zPosition(for: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func mouseUp(with event: NSEvent) {
        self.listNode.mouseUp(with: event)
    }
    
    override func mouseDown(with event: NSEvent) {
        self.listNode.mouseDown(with: event)
    }
}

extension InventoryNode: ListNodeDelegate {
    func listNodeNumberOfItems(listNode: ListNode) -> Int {
        return 9
    }
    
    func listNode(_ listNode: ListNode, nodeAtIndex index: Int, size: CGSize) -> SKNode {
        let (remainder, _) = index.remainderReportingOverflow(dividingBy: 2)
        let label = SKLabelNode(text: "Item \(index)")
        label.fontSize = 16
        label.fontName = "Papyrus"
        label.position = CGPoint(x: 0, y: -(label.frame.height / 2))

        var node: SKNode
        
        if remainder == 0 {
            node = SKSpriteNode(color: SKColor.blue, size: size)
        } else {
            node = SKSpriteNode(color: SKColor.magenta, size: size)
        }
        
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

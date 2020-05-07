//
//  InventoryNode.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

import Fenris

class InventoryNode: SKNode {
    private let listNode: ListNode
    
    init(size: CGSize) {
        self.listNode = ListNode(size: size, orientation: .vertical, backgroundColor: SKColor.white)
        
        super.init()
        
        addChild(self.listNode)
        
        self.listNode.delegate = self

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
        
        var node: SKNode
        
        if remainder == 0 {
            node = SKSpriteNode(color: SKColor.blue, size: size)
            node.addChild(label)
        }
        else {
            node = SKSpriteNode(color: SKColor.magenta, size: size)
            node.addChild(label)
        }
        
        return node
    }
    
    func listNodeWidthForItem(_ listNode: ListNode) -> CGFloat {
        return 0
    }
    
    func listNodeHeightForItem(_ listNode: ListNode) -> CGFloat {
        return 60
    }
}

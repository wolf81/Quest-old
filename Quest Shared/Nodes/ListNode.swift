//
//  ListNode.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

protocol ListNodeDelegate: class {
    func listNodeNumberOfItems(listNode: ListNode) -> Int
    
    func listNode(_ listNode: ListNode, nodeAtIndex index: Int, size: CGSize) -> SKNode
    
    // for vertical orientation
    func listNodeHeightForItem(_ listNode: ListNode) -> CGFloat
    
    // for horizontal orientation
    func listNodeWidthForItem(_ listNode: ListNode) -> CGFloat
}

enum ListNodeOrientation {
    case horizontal
    case vertical
}

private enum ScrollDirection {
    case backward
    case forward
    case none
}

class ListNode: SKNode {
    private let container: SKSpriteNode
    
    private let listContainer: SKCropNode
    
    private let list: SKSpriteNode
    
    weak var delegate: ListNodeDelegate? {
        didSet { reload() }
    }
    
    private var contentSize: CGSize = .zero
    
    private var contentOffset: CGPoint = .zero
    
    private var maxContentOffset: CGPoint = .zero
    
    private var previousButton: SKSpriteNode
    
    private var nextButton: SKSpriteNode
    
    private var scrollTimer: Timer?
    
    private var isScrollBackEnabled: Bool { self.contentOffset == .zero }
    
    private var isScrollForwardEnabled: Bool { self.orientation == .vertical ? self.contentOffset.y == self.maxContentOffset.y : self.contentOffset.x == self.maxContentOffset.x }
    
    override var zPosition: CGFloat {
        didSet {
            self.previousButton.zPosition = self.zPosition + 1
            self.nextButton.zPosition = self.zPosition + 1
            self.list.zPosition = self.zPosition + 1
        }
    }
    
    private var scrollDirection: ScrollDirection = .none {
        didSet {
            switch self.scrollDirection {
            case .none:
                self.scrollTimer?.invalidate()
                self.scrollTimer = nil
            default:
                guard self.scrollTimer == nil else { return }
                self.scrollTimer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(ListNode.performAutoscroll), userInfo: nil, repeats: true)
            }
        }
    }
    
    private let orientation: ListNodeOrientation
        
    init(size: CGSize, orientation: ListNodeOrientation, backgroundColor: SKColor) {
        self.orientation = orientation
        self.container = SKSpriteNode(color: backgroundColor, size: size)
        
        let buttonSize = self.orientation == .horizontal ? CGSize(width: 40, height: size.height) : CGSize(width: size.width, height: 40)
        self.previousButton = SKSpriteNode(color: SKColor.orange, size: buttonSize)
        self.nextButton = SKSpriteNode(color: SKColor.red, size: buttonSize)

        let listSize = orientation == .vertical ? CGSize(width: size.width, height: size.height - buttonSize.height * 2 - 2) : CGSize(width: size.width - buttonSize.width * 2 - 2, height: size.height)
        self.list = SKSpriteNode(color: .lightGray, size: listSize)

        self.listContainer = SKCropNode()
        self.listContainer.maskNode = self.list
                
        super.init()
        
        addChild(self.container)
        self.container.addChild(self.listContainer)
        self.container.addChild(self.previousButton)
        self.container.addChild(self.nextButton)
                
        let halfContainerWidth = self.container.frame.width / 2
        let halfContainerHeight = self.container.frame.height / 2
        switch self.orientation {
        case .horizontal:
            self.previousButton.position = CGPoint(x: -halfContainerWidth, y: 0)
            self.nextButton.position = CGPoint(x: halfContainerWidth / 2, y: 0)
        case .vertical:
            self.previousButton.position = CGPoint(x: 0, y: halfContainerHeight - self.previousButton.frame.height / 2)
            self.nextButton.position = CGPoint(x: 0, y: -halfContainerHeight + self.nextButton.frame.height / 2)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private func reload() {
        self.listContainer.children.forEach{ $0.removeFromParent() }

        if let delegate = delegate {
            let itemCount = delegate.listNodeNumberOfItems(listNode: self)
            let itemWidth = self.orientation == .vertical ? self.container.size.width : delegate.listNodeWidthForItem(self)
            let itemHeight = self.orientation == .horizontal ? self.container.size.height : delegate.listNodeHeightForItem(self) 
            
            switch self.orientation {
            case .horizontal: self.contentSize = CGSize(width: itemWidth * CGFloat(itemCount), height: itemHeight)
            case .vertical: self.contentSize = CGSize(width: itemWidth, height: itemHeight * CGFloat(itemCount))
            }
            
            var y: CGFloat = self.list.frame.height / 2 - itemHeight / 2
            for i in (0 ..< itemCount) {
                let node = delegate.listNode(self, nodeAtIndex: i, size: CGSize(width: itemWidth, height: itemHeight))
                self.listContainer.addChild(node)
                
                switch self.orientation {
                case .horizontal: node.position = CGPoint(x: itemWidth * CGFloat(i), y: 0)
                case .vertical: node.position = CGPoint(x: 0, y: y)
                }
                
                y -= itemHeight
            }
            
            let totalItemHeight = CGFloat(itemCount) * itemHeight
            let maxY = totalItemHeight > self.list.frame.height ? totalItemHeight - self.list.frame.height : 0
            self.maxContentOffset = CGPoint(x: 0, y: maxY)
        } else {
            self.contentSize = .zero
        }
        
        updateLayout()
    }
    
    @objc private func performAutoscroll() {
        DispatchQueue.main.async { [unowned self] in
            let offset = self.contentOffset
            
            switch self.scrollDirection {
            case .forward:
                let y: CGFloat = min(offset.y + 1, self.maxContentOffset.y)
                self.contentOffset = CGPoint(x: 0, y: y)
            case .backward:
                let y: CGFloat = max(offset.y - 1, 0)
                self.contentOffset = CGPoint(x: 0, y: y)
            default: break
            }
            self.updateLayout()
        }
    }
    
    private func updateLayout() {
        guard let delegate = self.delegate else { return }
        
        let itemWidth = self.orientation == .vertical ? self.container.size.width : delegate.listNodeWidthForItem(self)
        let itemHeight = self.orientation == .horizontal ? self.container.size.height : delegate.listNodeHeightForItem(self)

        var y: CGFloat = self.list.frame.height / 2 - itemHeight / 2 + self.contentOffset.y
        for (i, node) in self.listContainer.children.enumerated()  {
            switch self.orientation {
            case .horizontal: node.position = CGPoint(x: itemWidth * CGFloat(i), y: 0)
            case .vertical: node.position = CGPoint(x: 0, y: y)
            }
            
            y -= itemHeight
        }

        self.previousButton.alpha = self.isScrollBackEnabled ? 0.5 : 1.0
        self.nextButton.alpha = self.isScrollForwardEnabled ? 0.5 : 1.0
    }
    
    #if os(macOS)
        
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
                
        if self.previousButton.frame.contains(location) {
            self.scrollDirection = .backward
        }
        else if self.nextButton.frame.contains(location) {
            self.scrollDirection = .forward
        }
        
        updateLayout()
    }
    
    override func mouseUp(with event: NSEvent) {
        self.scrollDirection = .none
                
        updateLayout()
    }
    
    #endif
}
//
//  BackpackNode.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 07/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

protocol BackpackNodeDelegate: class {
    func backpackNodeNumberOfItems(backpackNode: BackpackNode) -> Int
    
    func backpackNode(_ backpackNode: BackpackNode, nodeAtIndex index: Int, size: CGSize) -> SKNode
    
    func backpackNode(_ backpackNode: BackpackNode, didSelectNode node: SKNode, atIndex index: Int)
    
    // for vertical orientation
    func backpackNodeHeightForItem(_ backpackNode: BackpackNode) -> CGFloat
    
    // for horizontal orientation
    func backpackNodeWidthForItem(_ backpackNode: BackpackNode) -> CGFloat
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

class BackpackNode: SKShapeNode {
    private let listContainer: SKCropNode
    
    private let list: SKSpriteNode
    
    weak var delegate: BackpackNodeDelegate? {
        didSet { reload() }
    }
        
    private var contentSize: CGSize = .zero
    
    private var contentOffset: CGPoint = .zero
    
    private var maxContentOffset: CGPoint = .zero
    
    private var previousButton: ButtonNode
    
    private var nextButton: ButtonNode
    
    private var scrollTimer: Timer?
    
    private var isScrollBackEnabled: Bool { self.contentOffset != .zero }
    
    private var isScrollForwardEnabled: Bool { self.orientation == .vertical ? self.contentOffset.y < self.maxContentOffset.y : self.contentOffset.x < self.maxContentOffset.x }
    
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
                self.scrollTimer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(BackpackNode.performAutoscroll), userInfo: nil, repeats: true)
            }
        }
    }
    
    private let orientation: ListNodeOrientation
        
    init(size: CGSize, orientation: ListNodeOrientation, backgroundColor: SKColor) {
        self.orientation = orientation
        
        let buttonSize = self.orientation == .horizontal ? CGSize(width: 40, height: size.height) : CGSize(width: size.width, height: 40)
        self.previousButton = ButtonNode(size: buttonSize, color: backgroundColor, text: "PREVIOUS")
        self.nextButton = ButtonNode(size: buttonSize, color: backgroundColor, text: "NEXT")

        let listSize = orientation == .vertical ? CGSize(width: size.width, height: size.height - buttonSize.height * 2) : CGSize(width: size.width - buttonSize.width * 2, height: size.height)
        self.list = SKSpriteNode(color: backgroundColor, size: listSize)

        self.listContainer = SKCropNode()
        self.listContainer.maskNode = self.list
                        
        super.init()
        
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -(size.width / 2), y: -(size.height / 2)), size: size), transform: nil)
        self.fillColor = backgroundColor
        self.strokeColor = .white
        self.lineWidth = 1
        
        self.addChild(self.listContainer)
        self.addChild(self.previousButton)
        self.addChild(self.nextButton)
                
        let halfContainerWidth = self.frame.width / 2
        let halfContainerHeight = self.frame.height / 2
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
    
    func reload() {
        self.listContainer.children.forEach{ $0.removeFromParent() }

        if let delegate = delegate {
            let itemCount = delegate.backpackNodeNumberOfItems(backpackNode: self)
            let itemWidth = self.orientation == .vertical ? self.frame.width : delegate.backpackNodeWidthForItem(self)
            let itemHeight = self.orientation == .horizontal ? self.frame.height : delegate.backpackNodeHeightForItem(self)
            
            switch self.orientation {
            case .horizontal: self.contentSize = CGSize(width: itemWidth * CGFloat(itemCount), height: itemHeight)
            case .vertical: self.contentSize = CGSize(width: itemWidth, height: itemHeight * CGFloat(itemCount))
            }
            
            var y: CGFloat = self.list.frame.height / 2 - itemHeight / 2
            for i in (0 ..< itemCount) {
                let node = delegate.backpackNode(self, nodeAtIndex: i, size: CGSize(width: itemWidth, height: itemHeight))
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
        
        let itemWidth = self.orientation == .vertical ? self.frame.width : delegate.backpackNodeWidthForItem(self)
        let itemHeight = self.orientation == .horizontal ? self.frame.height : delegate.backpackNodeHeightForItem(self)

        var y: CGFloat = self.list.frame.height / 2 - itemHeight / 2 + self.contentOffset.y
        for (i, node) in self.listContainer.children.enumerated()  {
            switch self.orientation {
            case .horizontal: node.position = CGPoint(x: itemWidth * CGFloat(i), y: 0)
            case .vertical: node.position = CGPoint(x: 0, y: y)
            }
            
            y -= itemHeight
        }

        self.previousButton.isEnabled = self.isScrollBackEnabled
        self.nextButton.isEnabled = self.isScrollForwardEnabled
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
                
        let location = event.location(in: self)

        if self.listContainer.contains(location) {
            for (idx, node) in self.listContainer.children.enumerated() {
                if node.frame.contains(location) {
                    self.delegate?.backpackNode(self, didSelectNode: node, atIndex: idx)
                    break
                }
            }
        }        
        
        updateLayout()
    }
    
    #endif
}

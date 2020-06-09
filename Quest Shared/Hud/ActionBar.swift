//
//  ActionBar.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 09/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

protocol ActionBarDelegate: class {
    func actionBarDidSelectButton(action: ActionBar.ButtonAction)
}

class ActionBar: SKShapeNode {
    enum ButtonAction {
        case converse
        case attack
        case backpack
        case interact
        case search
        case stealth
        case castDivineSpell
        case castArcaneSpell
        
        var textureName: String {
            switch self {
            case .castDivineSpell: return "scroll-unfurled"
            case .castArcaneSpell: return "spell-book"
            case .converse: return "conversation"
            case .attack: return "crossed-swords"
            case .backpack: return "backpack"
            case .interact: return "hand"
            case .search: return "magnifying-glass"
            case .stealth: return "cultist"
            }
        }
    }

    var size: CGSize { return self.path!.boundingBox.size }
        
    private let buttons: [ActionBarButton]!
    
    weak var delegate: ActionBarDelegate?
    
    init(size: CGSize, role: Role, delegate: ActionBarDelegate) {
        var actions: [ButtonAction]
        
        switch role {
        case .fighter: actions = [.converse, .attack, .interact, .backpack]
        case .cleric: actions = [.converse, .attack, .interact, .castDivineSpell, .backpack]
        case .mage: actions = [.converse, .attack, .interact, .castArcaneSpell, .backpack]
        case .rogue: actions = [.converse, .attack, .interact, .search, .stealth, .backpack]
        }

        self.buttons = ActionBar.createButtons(actions: actions, buttonSize: CGSize(width: size.height, height: size.height))
        
        super.init()
                        
        self.delegate = delegate

        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -size.width / 2, y: size.height / 2), size: size), transform: nil)
        self.lineWidth = 0
        self.zPosition = DrawLayerHelper.zPosition(for: self)
        
        var buttonX = -(CGFloat(self.buttons.count - 1) * self.buttons.first!.frame.size.width / 2)
        for button in self.buttons {
            button.position = CGPoint(x: buttonX, y: 0)
            buttonX += button.frame.size.width
            addChild(button)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func setSearchEnabled(isEnabled: Bool) {
        self.buttons.filter({ $0.action == .search }).first?.isEnabled = isEnabled
    }
    
    // MARK: - Private
    
    private static func createButtons(actions: [ButtonAction], buttonSize size: CGSize) -> [ActionBarButton] {
        var buttons: [ActionBarButton] = []
        
        let buttonSize = CGSize(width: size.height, height: size.height)
        for action in actions {
            let button = ActionBarButton(size: buttonSize, action: action)
            buttons.append(button)
        }
        
        return buttons
    }
}


// MARK: - macOS

#if os(macOS)

extension ActionBar {
    override func mouseUp(with event: NSEvent) {        
        let location = event.location(in: self)
        
        guard let action = self.buttons.filter({ $0.contains(location) }).first?.action else { return }

        self.delegate?.actionBarDidSelectButton(action: action)
    }
}

#endif

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
        case turnUndead
        case rest
        
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
            case .turnUndead: return "death-skull"
            case .rest: return "night-sleep"
            }
        }
    }

    var size: CGSize { return self.path!.boundingBox.size }
        
    private let buttons: [ActionBarButton]!
    
    weak var delegate: ActionBarDelegate?
    
    private var currentTime: TimeInterval = 0
    
    init(size: CGSize, role: Role, delegate: ActionBarDelegate) {
        var actions: [ButtonAction]
        
        switch role {
        case .fighter: actions = [.converse, .attack, .interact, .backpack, .rest]
        case .cleric: actions = [.converse, .attack, .interact, .castDivineSpell, .turnUndead, .backpack, .rest]
        case .mage: actions = [.converse, .attack, .interact, .castArcaneSpell, .backpack, .rest]
        case .rogue: actions = [.converse, .attack, .interact, .search, .stealth, .backpack, .rest]
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
        self.buttons.first(where: { $0.action == .search })?.isEnabled = isEnabled
    }
    
    func setStealthEnabled(isEnabled: Bool) {
        self.buttons.first(where: { $0.action == .stealth })?.isEnabled = isEnabled
    }
    
    func setRestEnabled(isEnabled: Bool) {
        self.buttons.first(where: { $0.action == .rest })?.isEnabled = isEnabled
    }
    
    func update(_ deltaTime: TimeInterval) {
        self.currentTime += deltaTime
        
        let minColorBlendFactor: Double = 0.5
        let colorBlendFactor = sin(self.currentTime) * minColorBlendFactor
        let color: SKColor = colorBlendFactor > 0 ? .green : .cyan
        
        for button in self.buttons {
            if button.isEnabled {
                button.sprite.color = color
                button.sprite.colorBlendFactor = CGFloat(abs(colorBlendFactor) + minColorBlendFactor)
            } else {
                button.sprite.colorBlendFactor = 0
            }
        }
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

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
        case useWand
        case useScroll
        case usePotion
        case turnUndead
        case rest
        case switchWeapon
        case empty
        
        var textureName: String {
            switch self {
            case .castDivineSpell: return "holy-symbol"
            case .castArcaneSpell: return "spell-book"
            case .converse: return "conversation"
            case .attack: return "crossed-swords"
            case .backpack: return "backpack"
            case .interact: return "hand"
            case .search: return "magnifying-glass"
            case .stealth: return "cultist"
            case .turnUndead: return "death-skull"
            case .rest: return "night-sleep"
            case .useWand: return "orb-wand"
            case .useScroll: return "scroll-unfurled"
            case .usePotion: return "magic-potion"
            case .switchWeapon: return "switch-weapon"
            case .empty: return "none"
            }
        }
        
        var size: CGSize {
            switch self {
            case .empty: return CGSize(width: 25, height: 50)
            default: return CGSize(width: 50, height: 50)
            }
        }
        
        var lineWidth: CGFloat {
            switch self {
            case .empty: return 0
            default: return 2
            }
        }
    }

    var size: CGSize { return self.path!.boundingBox.size }
        
    private let buttons: [ActionBarButton]!
    
    weak var delegate: ActionBarDelegate?
    
    private var currentTime: TimeInterval = 0
    
    init(width: CGFloat, role: Role, delegate: ActionBarDelegate) {
        var actions: [ButtonAction] = [.converse, .interact, .empty, .switchWeapon, .attack]
        
        switch role {
        case .fighter: break
        case .cleric: actions.append(contentsOf: [.empty, .castDivineSpell, .turnUndead])
        case .mage: actions.append(contentsOf: [.empty, .castArcaneSpell])
        case .rogue: actions.append(contentsOf: [.empty, .search, .stealth])
        }
        
        actions.append(contentsOf: [.empty, .usePotion, .useWand, .useScroll, .empty, .backpack, .rest])

        let buttonSize = CGSize(width: 50, height: 50)
        self.buttons = ActionBar.createButtons(actions: actions, buttonSize: buttonSize)
        
        super.init()
                        
        self.delegate = delegate

        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -width / 2, y: 50 / 2), size: CGSize(width: width, height: 50)), transform: nil)
        self.lineWidth = 0
        self.zPosition = DrawLayerHelper.zPosition(for: self)
        
        let totalWidth = self.buttons.compactMap({ $0.frame.size.width }).reduce(0, +)
        var buttonX = -(totalWidth / 2) + self.buttons.first!.frame.width / 2
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
            let size = action == .empty ? CGSize(width: size.width / 2, height: size.height) : buttonSize
            let button = ActionBarButton(size: size, action: action)
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

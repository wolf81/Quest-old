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
            case .empty: return CGSize(width: 14, height: ActionBar.buttonHeight)
            default: return CGSize(width: ActionBar.buttonHeight, height: ActionBar.buttonHeight)
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
    
    private static let buttonHeight: CGFloat = 50
    
    init(width: CGFloat, role: Role, delegate: ActionBarDelegate) {
        let actions = ActionBar.getActionsFor(role: role)
        self.buttons = ActionBar.createButtons(actions: actions)
        
        super.init()
                        
        self.delegate = delegate

        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -width / 2, y: ActionBar.buttonHeight / 2), size: CGSize(width: width, height: ActionBar.buttonHeight)), transform: nil)
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
    
    private static func createButtons(actions: [ButtonAction]) -> [ActionBarButton] {
        var buttons: [ActionBarButton] = []
        
        for action in actions {
            let button = ActionBarButton(action: action)
            buttons.append(button)
        }
        
        return buttons
    }
    
    private static func getActionsFor(role: Role) -> [ButtonAction] {
        // actions on other entities
        let interactActions: [ButtonAction] = [.converse, .interact, .empty, .switchWeapon, .attack]
        // actions on the hero
        let personalActions: [ButtonAction] = [.empty, .usePotion, .useWand, .useScroll, .empty, .backpack, .rest]
        // actions restricted to the current role
        let roleActions: [ButtonAction] = {
            switch role {
            case .fighter: return []
            case .cleric: return [.empty, .castDivineSpell, .turnUndead]
            case .mage: return [.empty, .castArcaneSpell]
            case .rogue: return [.empty, .search, .stealth]
            }
        }()

        return interactActions + roleActions + personalActions
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

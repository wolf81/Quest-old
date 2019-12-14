//
//  ActionBar.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 09/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

protocol ActionBarDelegate: class {
    func actionBarDidSelectMove()
    func actionBarDidSelectDefend()
    func actionBarDidSelectMeleeAttack()
    func actionBarDidSelectRangeAttack()
    func actionBarDidSelectCastSpell()
}

class ActionBar: SKShapeNode {
    var size: CGSize { return self.path!.boundingBox.size }
    
    private var moveButton: ActionBarButton!
    private var meleeAttackButton: ActionBarButton!
    private var rangeAttackButton: ActionBarButton!
    private var castSpellButton: ActionBarButton!
    
    weak var delegate: ActionBarDelegate?
    
    init(size: CGSize, delegate: ActionBarDelegate) {
        super.init()

        self.delegate = delegate

        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -size.width / 2, y: size.height / 2), size: size), transform: nil)
        self.lineWidth = 0

        addButtons()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Private
    
    private func addButtons() {
        let buttonSize = CGSize(width: size.height, height: size.height)
        self.moveButton = ActionBarButton(size: buttonSize, color: SKColor.green)
        self.meleeAttackButton = ActionBarButton(size: buttonSize, color: SKColor.red)
        self.rangeAttackButton = ActionBarButton(size: buttonSize, color: SKColor.orange)
        self.castSpellButton = ActionBarButton(size: buttonSize, color: SKColor.blue)
        let defendButton = ActionBarButton(size: buttonSize, color: SKColor.darkGray)

        let buttons: [ActionBarButton] = [self.moveButton, self.meleeAttackButton, self.rangeAttackButton, self.castSpellButton, defendButton]
        var buttonX = -(CGFloat(buttons.count - 1) * buttonSize.width / 2)
        for button in buttons {
            button.position = CGPoint(x: buttonX, y: 0)
            buttonX += buttonSize.width
            addChild(button)
        }
    }
}

// MARK: - macOS

#if os(macOS)

extension ActionBar {
    override func mouseUp(with event: NSEvent) {        
        let location = event.location(in: self)
        switch location {
        case _ where self.moveButton.contains(location):
            self.delegate?.actionBarDidSelectMove()
        case _ where self.meleeAttackButton.contains(location):
            self.delegate?.actionBarDidSelectMeleeAttack()
        case _ where self.rangeAttackButton.contains(location):
            self.delegate?.actionBarDidSelectRangeAttack()
        case _ where self.castSpellButton.contains(location):
            self.delegate?.actionBarDidSelectCastSpell()
        default: break
        }
    }
}

#endif

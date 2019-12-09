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
    func actionBarDidSelectAttackMelee()
    func actionBarDidSelectAttackRanged()
    func actionBarDidSelectCastSpell()
}

class ActionBar: SKShapeNode {
    var size: CGSize { return self.path!.boundingBox.size }
    
    weak var delegate: ActionBarDelegate?
    
    init(size: CGSize, delegate: ActionBarDelegate) {
        super.init()

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
        let moveButton = ActionBarButton(size: buttonSize, color: SKColor.green)
        let attackMeleeButton = ActionBarButton(size: buttonSize, color: SKColor.red)
        let attackRangedButton = ActionBarButton(size: buttonSize, color: SKColor.orange)
        let castSpellButton = ActionBarButton(size: buttonSize, color: SKColor.blue)
        let defendButton = ActionBarButton(size: buttonSize, color: SKColor.darkGray)

        let buttons: [ActionBarButton] = [moveButton, attackMeleeButton, attackRangedButton, castSpellButton, defendButton]
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
        print("handle mouse up in action bar")
    }
}

#endif

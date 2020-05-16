//
//  CharacterInfoNode.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 16/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import SpriteKit

class CharacterInfoNode: SKShapeNode {
    private let characterNode: InfoNode

    private let statsNode: InfoNode
    
    private let skillsNode: InfoNode
    
    private let attributesNode: InfoNode
            
    init(size: CGSize, backgroundColor: SKColor, hero: Hero) {
        let spacing: CGFloat = 5
        let nodeWidth = (size.width - spacing * 3) / 2
        let nodeHeight = (size.height - spacing * 3) / 2
        let infoNodeSize = CGSize(width: nodeWidth, height: nodeHeight)
        self.characterNode = InfoNode(size: infoNodeSize, backgroundColor: backgroundColor, header: "Character", labelInfo: [
            ("Race:", "\(hero.race)"),
            ("Role:", "\(hero.role)"),
            ("Level:", "\(hero.level)")
        ])
        self.statsNode = InfoNode(size: infoNodeSize, backgroundColor: backgroundColor, header: "Combat Stats", labelInfo: [
            ("Hitpoints:", "\(hero.hitPoints.current) / \(hero.hitPoints.base)"),
            ("Armor Class:", "\(hero.armorClass)"),
            ("Attack Bonus:", "\(hero.meleeAttackBonus)")
        ])
        self.skillsNode = InfoNode(size: infoNodeSize, backgroundColor: backgroundColor, header: "Skills", labelInfo: [
            ("Physical:", "\(hero.skills.physical)"),
            ("Subterfuge:", "\(hero.skills.subterfuge)"),
            ("Knowledge:", "\(hero.skills.knowledge)"),
            ("Communication:", "\(hero.skills.communication)")
        ])
        self.attributesNode = InfoNode(size: infoNodeSize, backgroundColor: backgroundColor, header: "Attributes", labelInfo: [
            ("Strength:", "\(hero.attributes.strength)"),
            ("Dexterity:", "\(hero.attributes.dexterity)"),
            ("Mind:", "\(hero.attributes.mind)")
        ])
        
        super.init()
        
        self.path = CGPath(rect: CGRect(origin: CGPoint(x: -(size.width / 2), y: -(size.height / 2)), size: size), transform: nil)
        
        self.lineWidth = 1
        self.strokeColor = .white
        self.fillColor = backgroundColor

        addChild(self.statsNode)
        addChild(self.characterNode)
        addChild(self.skillsNode)
        addChild(self.attributesNode)
        
        self.characterNode.position = CGPoint(x: -(size.width - nodeWidth) / 2 + spacing, y: (size.height - nodeHeight) / 2 - spacing)
        self.statsNode.position = CGPoint(x: (size.width - nodeWidth) / 2 - spacing, y: -(size.height - nodeHeight) / 2 + spacing)
        self.skillsNode.position = CGPoint(x: (size.width - nodeWidth) / 2 - spacing, y: (size.height - nodeHeight) / 2 - spacing)
        self.attributesNode.position = CGPoint(x: -(size.width - nodeWidth) / 2 + spacing, y: -(size.height - nodeHeight) / 2 + spacing)
        
        self.zPosition = DrawLayerHelper.zPosition(for: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private class InfoNode: SKShapeNode {
        init(size: CGSize, backgroundColor: SKColor, header: String, labelInfo: [(String, String)]) {
            super.init()
            
            self.path = CGPath(rect: CGRect(origin: CGPoint(x: -(size.width / 2), y: -(size.height / 2)), size: size), transform: nil)
            
            self.lineWidth = 1
            self.strokeColor = .white
            self.fillColor = backgroundColor

            let spacing: CGFloat = 5
            
            let nodeHeight = size.height / 5

            let header = SKLabelNode(text: header)
            header.fontSize = 16
            header.verticalAlignmentMode = .center
            header.fontName = "Papyrus"
            addChild(header)
            header.position = CGPoint(x: -(header.frame.width / 2), y: size.height / 2 - nodeHeight / 2)
                        
            var i = 0
            for (title, details) in labelInfo {
                let y = size.height / 2 - (nodeHeight * CGFloat(i + 1)) - nodeHeight / 2

                let titleLabel = SKLabelNode(text: title)
                titleLabel.fontSize = 16
                titleLabel.verticalAlignmentMode = .baseline
                titleLabel.fontName = "Papyrus"
                addChild(titleLabel)
                titleLabel.position = CGPoint(x: -(titleLabel.frame.width / 2) - spacing, y: y)

                let detailLabel = SKLabelNode(text: details)
                detailLabel.fontSize = 16
                detailLabel.verticalAlignmentMode = .baseline
                detailLabel.fontName = "Papyrus"
                addChild(detailLabel)
                detailLabel.position = CGPoint(x: (detailLabel.frame.width / 2) + spacing, y: y)
                
                i += 1
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError()
        }
    }
}

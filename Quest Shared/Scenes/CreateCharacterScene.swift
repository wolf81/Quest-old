//
//  CreateCharacterMenu.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 19/04/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Fenris
import SpriteKit

class CreateCharacterScene: MenuSceneBase {
    private let raceChooser = TextChooserItem(values: ["Human", "Dwarf", "Elf", "Halfling"], selectedValueIdx: Int(arc4random_uniform(4)))
    private let roleChooser = TextChooserItem(values: ["Fighter", "Rogue", "Cleric", "Mage"], selectedValueIdx: Int(arc4random_uniform(4)))
    private let genderChooser = TextChooserItem(values: ["Male", "Female"], selectedValueIdx: Int(arc4random_uniform(2)))
    
    required init(size: CGSize, userInfo: [String : Any]) {
        super.init(size: size, userInfo: userInfo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func getMenu() -> Menu {
        return LabeledMenuBuilder()
            .withHeader(title: "Create New Character")
            .withEmptyRow()
            .withRow(title: "Race", item: raceChooser)
            .withRow(title: "Class", item: roleChooser)
            .withRow(title: "Gender", item: genderChooser)
            .withEmptyRow()
            .withFooter(items: [
                ButtonItem(title: "Back", onClick: { self.createCharacterMenuDidSelectBack() }),
                ButtonItem(title: "Next", onClick: {
                    let race = Race(rawValue: self.raceChooser.value.lowercased())!
                    let role = Role(rawValue: self.roleChooser.value.lowercased())!
                    let gender = Gender(rawValue: self.genderChooser.value.lowercased())!
                    self.createCharacterMenuDidSelect(race: race, role: role, gender: gender)
                })
            ])
            .build();
    }
    
    override var configuration: MenuConfiguration { DefaultMenuConfiguration.shared }
    
    func createCharacterMenuDidSelect(race: Race, role: Role, gender: Gender) {
        try! ServiceLocator.shared.get(service: SceneManager.self).push(to: ChooseAttributesScene.self, userInfo: [
            ChooseAttributesScene.UserInfoKey.race: race,
            ChooseAttributesScene.UserInfoKey.role: role,
            ChooseAttributesScene.UserInfoKey.gender: gender
        ])
    }
    
    func createCharacterMenuDidSelectBack() {
        try! ServiceLocator.shared.get(service: SceneManager.self).pop(to: MainMenuScene.self)
    }
}

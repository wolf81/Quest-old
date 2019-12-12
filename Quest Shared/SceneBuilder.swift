//
//  Scene.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 18/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Fenris
import CoreGraphics

protocol MainMenuSceneDelegate {
    func mainMenuDidSelectNewGame()
    func mainMenuDidSelectContinueGame()
    func mainMenuDidSelectSettings()
    func mainMenuDidSelectQuit()
}

protocol SettingsMenuDelegate {
    func settingsMenuDidSelectBack()
}

protocol CreateCharacterMenuDelegate {
    func createCharacterMenuDidSelect(race: Race, role: Role, gender: Gender)
    func createCharacterMenuDidSelectBack()
}

protocol ChooseAttributesMenuDelegate {
    func chooseAttributesMenuDidSelectBack()
    func chooseAttributesMenuDidSelect(attributes: Attributes)
}

struct SceneBuilder {
    private static let menuConfig = DefaultMenuConfiguration()
    
    static func mainMenu(size: CGSize, delegate: MainMenuSceneDelegate) -> MenuScene {
        let menu = SimpleMenuBuilder()
            .withRow(item: ButtonItem(title: "New Game", onClick: { delegate.mainMenuDidSelectNewGame() }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Continue Game", onClick: { delegate.mainMenuDidSelectContinueGame() }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Settings", onClick: { delegate.mainMenuDidSelectSettings() }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Quit", onClick: { delegate.mainMenuDidSelectQuit() }))
            .build()
        return MenuScene(size: size, configuration: menuConfig, menu: menu)
    }

    static func createCharacterMenu(size: CGSize, delegate: CreateCharacterMenuDelegate) -> MenuScene {
        let raceChooser = TextChooserItem(values: ["Human", "Dwarf", "Elf", "Halfling"], selectedValueIdx: 0)
        let roleChooser = TextChooserItem(values: ["Fighter", "Rogue", "Cleric", "Mage"], selectedValueIdx: 0)
        let genderChooser = TextChooserItem(values: ["Male", "Female"], selectedValueIdx: 0)

        let menu = LabeledMenuBuilder()
            .withHeader(title: "Create New Character")
            .withEmptyRow()
            .withRow(title: "Race", item: raceChooser)
            .withRow(title: "Class", item: roleChooser)
            .withRow(title: "Gender", item: genderChooser)
            .withEmptyRow()
            .withFooter(items: [
                ButtonItem(title: "Back", onClick: { delegate.createCharacterMenuDidSelectBack() }),
                ButtonItem(title: "Next", onClick: {
                    let race = Race(rawValue: raceChooser.value.lowercased())!
                    let role = Role(rawValue: roleChooser.value.lowercased())!
                    let gender = Gender(rawValue: genderChooser.value.lowercased())!
                    delegate.createCharacterMenuDidSelect(race: race, role: role, gender: gender)
                })
            ])
            .build();
        return MenuScene(size: size, configuration: menuConfig, menu: menu)
    }
    
    static func chooseAttributesMenu(size: CGSize, race: Race, delegate: ChooseAttributesMenuDelegate) -> MenuScene {
        let attributes = Attributes.roll(race: race)
        let strengthLabel = LabelItem(title: String(attributes.strength))
        let dexterityLabel = LabelItem(title: String(attributes.dexterity))
        let mindLabel = LabelItem(title: String(attributes.mind))
        
        let menu = LabeledMenuBuilder()
            .withHeader(title: "Choose Attributes")
            .withEmptyRow()
            .withRow(title: "Strength", item: strengthLabel)
            .withRow(title: "Dexterity", item: dexterityLabel)
            .withRow(title: "Mind", item: mindLabel)
            .withEmptyRow()
            .withFooter(items: [
                ButtonItem(title: "Back", onClick: { delegate.chooseAttributesMenuDidSelectBack() }),
                ButtonItem(title: "Reroll", onClick: {
                    let attributes = Attributes.roll(race: race)
                    strengthLabel.title = String(attributes.strength)
                    dexterityLabel.title = String(attributes.dexterity)
                    mindLabel.title = String(attributes.mind)
                }),
                ButtonItem(title: "Next", onClick: {
                    delegate.chooseAttributesMenuDidSelect(attributes: attributes)
                })
            ])
            .build()
        return MenuScene(size: size, configuration: menuConfig, menu: menu)
    }
    
    static func settingsMenu(size: CGSize, delegate: SettingsMenuDelegate) -> MenuScene {
        let menu = LabeledMenuBuilder()
            .withHeader(title: "Settings")
            .withEmptyRow()
            .withRow(title: "Music", item: ToggleItem(enabled: false))
            .withRow(title: "Developer Mode", item: ToggleItem(enabled: false))
            .withEmptyRow()
            .withFooter(items: [ButtonItem(title: "Back", onClick: { delegate.settingsMenuDidSelectBack() })])
            .build()
        return MenuScene(size: size, configuration: menuConfig, menu: menu)
    }
}

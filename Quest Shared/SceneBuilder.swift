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

protocol ChooseRaceMenuDelegate {
    func chooseRaceMenuDidSelectRace(race: String)
    func chooseRaceMenuDidSelectBack()
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

    static func chooseRaceMenu(size: CGSize, delegate: ChooseRaceMenuDelegate) -> MenuScene {
        let raceChooser = TextChooserItem(values: ["Human", "Dwarf", "Elf", "Halfling"], selectedValueIdx: 0)
        
        let menu = LabeledMenuBuilder()
            .withHeader(title: "Choose Race")
            .withEmptyRow()
            .withRow(title: "Race", item: raceChooser)
            .withEmptyRow()
            .withFooter(items: [
                ButtonItem(title: "Back", onClick: { delegate.chooseRaceMenuDidSelectBack() }),
                ButtonItem(title: "Next", onClick: { delegate.chooseRaceMenuDidSelectRace(race: raceChooser.value) })
            ])
            .build();
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

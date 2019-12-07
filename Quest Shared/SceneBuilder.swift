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

struct SceneBuilder {
    private static let menuConfig = MenuConfiguration(
        menuWidth: 320,
        rowHeight: 40,
        titleFont: Font(name: "Papyrus", size: 22)!,
        labelFont: Font(name: "Papyrus", size: 18)!
    )
    
    static func mainMenu(size: CGSize, delegate: MainMenuSceneDelegate?) -> MenuScene {
        let menu = SimpleMenuBuilder()
            .withRow(item: ButtonItem(title: "New Game", onClick: { delegate?.mainMenuDidSelectNewGame() }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Continue Game", onClick: { delegate?.mainMenuDidSelectContinueGame() }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Settings", onClick: { delegate?.mainMenuDidSelectSettings() }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Quit", onClick: { delegate?.mainMenuDidSelectQuit() }))
            .build()
        return MenuScene(size: size, configuration: menuConfig, menu: menu)
    }

    static func settingsMenu(size: CGSize, delegate: SettingsMenuDelegate?) -> MenuScene {
        let menu = LabeledMenuBuilder()
            .withHeader(title: "Settings")
            .withEmptyRow()
            .withRow(title: "Music", item: ToggleItem(enabled: false))
            .withRow(title: "Developer Mode", item: ToggleItem(enabled: false))
            .withEmptyRow()
            .withFooter(items: [ButtonItem(title: "Back", onClick: { delegate?.settingsMenuDidSelectBack() })])
            .build()
        return MenuScene(size: size, configuration: menuConfig, menu: menu)
    }
}

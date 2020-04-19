//
//  SettingsScene.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 19/04/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Fenris

class SettingsScene: MenuSceneBase {
    override func getMenu() -> Menu {
        return LabeledMenuBuilder()
            .withHeader(title: "Settings")
            .withEmptyRow()
            .withRow(title: "Music", item: ToggleItem(enabled: false))
            .withRow(title: "Developer Mode", item: ToggleItem(enabled: false))
            .withEmptyRow()
            .withFooter(items: [ButtonItem(title: "Back", onClick: { try! ServiceLocator.shared.get(service: SceneManager.self).pop(to: MainMenuScene.self) })])
            .build()
    }
    
    override var configuration: MenuConfiguration { DefaultMenuConfiguration.shared }
}

//
//  MainMenuScene.swift
//  Quest iOS
//
//  Created by Wolfgang Schreurs on 19/04/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Fenris

#if os(macOS)
import Cocoa
#endif

class MainMenuScene: MenuSceneBase {
    override func getMenu() -> Menu {        
        return SimpleMenuBuilder()
            .withRow(item: ButtonItem(title: "New Game", onClick: { try! ServiceLocator.shared.get(service: SceneManager.self).push(to: CreateCharacterScene.self)  }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Continue Game", onClick: { try! ServiceLocator.shared.get(service: SceneManager.self).push(to: GameScene.self) }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Settings", onClick: { try! ServiceLocator.shared.get(service: SceneManager.self).push(to: SettingsScene.self) }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Hi", onClick: {

                let nameSet = try! DataLoader.load(type: NameInfo.self, fromFileNamed: "human", inDirectory: "Data/Names")
                let nameGenerator = NameGenerator(nameInfo: nameSet.nameInfo)
                let names = nameGenerator.generateNamesFor(category: "male", count: 10)
                print(names)
                }))
            .withEmptyRow()
            .withRow(item: ButtonItem(title: "Quit", onClick: {
                #if os(macOS)
                NSApp.terminate(self)
                #endif
            }))
            .build()
    }
        
    override var configuration: MenuConfiguration { DefaultMenuConfiguration.shared }
}

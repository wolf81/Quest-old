//
//  GameOverScene.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 14/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Fenris

class GameOverScene: MenuSceneBase {
    override func getMenu() -> Menu {
        return LabeledMenuBuilder()
            .withHeader(title: "Game Over")
            .withEmptyRow()
            .withFooter(items: [
                ButtonItem(title: "Menu", onClick: {
                    let sceneManager = try! ServiceLocator.shared.get(service: SceneManager.self)
                    sceneManager.crossFade(to: MainMenuScene.self)
                }),
                ButtonItem(title: "Restart", onClick: {
                    let heroBuilder = HeroBuilder.last()                                        
                    let sceneManager = try! ServiceLocator.shared.get(service: SceneManager.self)
                    sceneManager.crossFade(to: LoadingScene.self, userInfo: [LoadingScene.UserInfoKey.heroBuilder: heroBuilder])
                })
            ])
            .build()
    }
    
    override var configuration: MenuConfiguration { DefaultMenuConfiguration.shared }
}

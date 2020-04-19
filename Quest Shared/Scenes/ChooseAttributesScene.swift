//
//  ChooseAttributesScene.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 19/04/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Fenris
import SpriteKit

class ChooseAttributesScene: MenuSceneBase {
    struct UserInfoKey {
        static let race = "race"
        static let gender = "gender"
        static let role = "role"
    }
    
    let strengthLabel: LabelItem
    let dexterityLabel: LabelItem
    let mindLabel: LabelItem
    
    let race: Race
    let role: Role
    let gender: Gender

    var attributes: Attributes

    required init(size: CGSize, userInfo: [String : Any]) {
        self.race = userInfo[UserInfoKey.race] as! Race
        self.gender = userInfo[UserInfoKey.gender] as! Gender
        self.role = userInfo[UserInfoKey.role] as! Role
        
        self.attributes = Attributes.roll(race: self.race)

        self.strengthLabel = LabelItem(title: String(attributes.strength))
        self.dexterityLabel = LabelItem(title: String(attributes.dexterity))
        self.mindLabel = LabelItem(title: String(attributes.mind))

        super.init(size: size, userInfo: userInfo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func getMenu() -> Menu {
        return LabeledMenuBuilder()
            .withHeader(title: "Choose Attributes")
            .withEmptyRow()
            .withRow(title: "Strength", item: strengthLabel)
            .withRow(title: "Dexterity", item: dexterityLabel)
            .withRow(title: "Mind", item: mindLabel)
            .withEmptyRow()
            .withFooter(items: [
                ButtonItem(title: "Back", onClick: { try! ServiceLocator.shared.get(service: SceneManager.self).pop(to: CreateCharacterScene.self) }),
                ButtonItem(title: "Reroll", onClick: {
                    self.attributes = Attributes.roll(race: self.race)
                    self.strengthLabel.title = String(self.attributes.strength)
                    self.dexterityLabel.title = String(self.attributes.dexterity)
                    self.mindLabel.title = String(self.attributes.mind)
                }),
                ButtonItem(title: "Next", onClick: { self.startGame()
                })
            ])
            .build()
    }
    
    override var configuration: MenuConfiguration { DefaultMenuConfiguration.shared }
    
    private func startGame() {
        do {
            let entityFactory = EntityFactory()
            try EntityLoader.loadEntities(for: entityFactory)

            let heroBuilder = HeroBuilder()
                .with(gender: self.gender)
                .with(race: self.race)
                .with(role: self.role)
                .with(attributes: self.attributes)
                .with(name: "Kendrick")
            
            try ServiceLocator.shared.get(service: SceneManager.self).fade(to: LoadingScene.self, userInfo: [
                LoadingScene.UserInfoKey.heroBuilder: heroBuilder
            ])
        }
        catch let error {
            print(error)
        }
    }
}

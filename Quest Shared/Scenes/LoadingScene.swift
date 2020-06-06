//
//  LoadingScene.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 19/04/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Fenris
import SpriteKit
import Harptos

class LoadingScene: MenuSceneBase {
    struct UserInfoKey {
        static let heroBuilder = "heroBuilder"
    }
    
    private let progressBar = ProgressBarItem()
        
    private let heroBuilder: HeroBuilder
    
    required init(size: CGSize, userInfo: [String : Any]) {
        self.heroBuilder = userInfo[UserInfoKey.heroBuilder] as! HeroBuilder
        
        super.init(size: size, userInfo: userInfo)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func getMenu() -> Menu {
         return LabeledMenuBuilder()
             .withHeader(title: "Loading")
             .withEmptyRow()
             .withFooter(items: [self.progressBar])
             .build()
     }
     
    override var configuration: MenuConfiguration { DefaultMenuConfiguration.shared }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadData()
        }
    }
    
    private func loadDataFinished(entityFactory: EntityFactory) {
        let hero = try! self.heroBuilder
            .with(name: "Kendrick")
            .build(entityFactory: entityFactory)

        let time = HarptosCalendar.getTimeFor(year: 985, month: 3, day: 5, hour: 12, minute: 15, second: 0)
        let state = try! GameState(level: 0, hero: hero, time: time, entityFactory: entityFactory)
        let game = Game(state: state)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            try! ServiceLocator.shared.get(service: SceneManager.self).fade(to: GameScene.self, userInfo: [
                GameScene.UserInfoKey.game: game
            ])
        }
    }
    
    private func loadDataFailed(error: Error) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            print(error)
            
            try! ServiceLocator.shared.get(service: SceneManager.self).pop(to: ChooseAttributesScene.self, userInfo: [
                ChooseAttributesScene.UserInfoKey.role: self.heroBuilder.role!,
                ChooseAttributesScene.UserInfoKey.race: self.heroBuilder.race!,
                ChooseAttributesScene.UserInfoKey.gender: self.heroBuilder.gender!
            ])
        }
    }
    
    private func loadData() {
        do {
            let entityFactory = EntityFactory(delegate: self)
            try EntityLoader.loadEntities(for: entityFactory)
            loadDataFinished(entityFactory: entityFactory)
        } catch let error {
            loadDataFailed(error: error)
        }
    }
}

extension LoadingScene: EntityFactoryDelegate {
    func entityFactory(entityFactory: EntityFactory, didRegister entity: EntityProtocol) {
        let progress = Float(entityFactory.entityCount) / Float(EntityLoader.entityCount)
        self.progressBar.value = progress
    }
}

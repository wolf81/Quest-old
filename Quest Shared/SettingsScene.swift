//
//  SettingsScene.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 11/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Fenris
import CoreGraphics

#if os(macOS)
import Cocoa
#endif

class SettingsScene: MenuScene {
    init(size: CGSize) {
        let options: [MenuOption] = [
            Toggle(title: "Music", value: false, valueChanged: { (newValue) in
                print("music: \(newValue)")
            }),
            Toggle(title: "Sound", value: false, valueChanged: { (newValue) in
                print("sound: \(newValue)")
            }),
            Button(title: "Back", selected: {
                ServiceLocator.shared.sceneManager.transitionTo(
                    scene: MainMenuScene(size: size),
                    animation: .pop
                )
            })
        ]
        
        super.init(size: size, controlHeight: 30, options: options)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  Interactable.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/06/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

protocol Interactable: EntityProtocol {
    var canInteract: Bool { get }
    
    func interact(state: GameState)     
}

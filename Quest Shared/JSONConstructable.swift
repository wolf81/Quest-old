//
//  JSONConstructable.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/06/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import SpriteKit

protocol JSONConstructable {
    init(json: [String: Any])
}

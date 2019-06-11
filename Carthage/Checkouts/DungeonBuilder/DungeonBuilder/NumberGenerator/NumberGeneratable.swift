//
//  NumberGeneratable.swift
//  DungeonBuilder
//
//  Created by Wolfgang Schreurs on 04/09/2018.
//  Copyright © 2018 Wolftrail. All rights reserved.
//

import Foundation

public protocol NumberGeneratable {
    func next(maxValue: Int) -> Int

    func seed(data: Data)
}

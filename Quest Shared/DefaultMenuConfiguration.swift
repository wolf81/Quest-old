//
//  DefaultMenuConfiguration.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 08/12/2019.
//  Copyright © 2019 Wolftrail. All rights reserved.
//

import Foundation
import Fenris

class DefaultMenuConfiguration: MenuConfiguration {
    var menuWidth: CGFloat = 320

    var rowHeight: CGFloat = 40
    
    var titleFont: Font = Font(name: "Papyrus", size: 22)!
    
    var labelFont: Font = Font(name: "Papyrus", size: 18)!
    
    private init() {}
    
    public static let shared = DefaultMenuConfiguration()
}

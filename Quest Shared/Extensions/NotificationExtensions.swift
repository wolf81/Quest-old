//
//  NotificationExtensions.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 29/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let actorDidChangeEquipment = Notification.Name("actorDidChangeEquipment")
    static let actorDidStopSearching = Notification.Name("actorDidStopSearching")
    static let actorDidStartSearching = Notification.Name("actorDidStartSearching")
}

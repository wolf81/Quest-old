//
//  Image.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 24/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

#if os(macOS)

import Cocoa

typealias Image = NSImage

#endif

#if os(iOS) || os(tvOS)

typealias Image = UIImage

#endif

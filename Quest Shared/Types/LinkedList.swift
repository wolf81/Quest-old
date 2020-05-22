//
//  LinkedList.swift
//  Quest
//
//  Created by Wolfgang Schreurs on 22/05/2020.
//  Copyright © 2020 Wolftrail. All rights reserved.
//

import Foundation

class LinkedListNode<T> {
    var value: T!
    var next: LinkedListNode?
    var previous: LinkedListNode?
}

class LinkedList<T: Equatable> {
    private var head: LinkedListNode<T> = LinkedListNode<T>()
    private var tail: LinkedListNode<T> = LinkedListNode<T>()
    
    var isEmpty: Bool {
        self.head === self.tail
    }
}

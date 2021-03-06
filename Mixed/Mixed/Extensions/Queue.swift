//
//  Queue.swift
//  Mixed
//
//  Created by Jay Lees on 18/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import Foundation

public struct Queue<T> {
    fileprivate var list = [T]()
    
    public var isEmpty: Bool {
        return list.isEmpty
    }
    
    public var count: Int {
        return list.count
    }
    
    public mutating func enqueue(_ element: T) {
        list.append(element)
    }
    
    public mutating func dequeue() -> T? {
        guard !list.isEmpty, let element = list.first else { return nil }
        
        list.remove(at: 0)
        return element
    }
    
    public func peek() -> T? {
        return list.first
    }
    
    public func getAll() -> [T]{
        return list
    }
    
    public mutating func clear() {
        list.removeAll()
    }
    
    public mutating func setTo(_ list: [T]){
        self.list = list
    }
    
    subscript(index: Int) -> T {
        get {
            return list[index]
        }
    }
}

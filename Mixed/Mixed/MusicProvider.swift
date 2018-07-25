//
//  MusicProvider.swift
//  Mixed
//
//  Created by Jay Lees on 22/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

protocol MusicProviderDelegate {
    func queryDidSucceed(_ songs: [Song])
    func queryDidFail(_ error: Error)
}

protocol MusicProvider {
    var delegate: MusicProviderDelegate? { get set }
    func search(for query: String)
}

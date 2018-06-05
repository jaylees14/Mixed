//
//  MusicPlayer.swift
//  Mixed
//
//  Created by Jay Lees on 03/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

public protocol MusicPlayer {
    func setDelegate(_ delegate: PlayerDelegate)
    
    func validateSession()
    
    func play()
    func pause()
    func next()
    func clearQueue()
    func enqueue(song: String)
    func getCurrentStatus() -> PlaybackStatus
}

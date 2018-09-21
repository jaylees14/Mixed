//
//  MusicPlayer.swift
//  Mixed
//
//  Created by Jay Lees on 03/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

public protocol MusicPlayer {
    var delegate: PlayerDelegate? { get set }
    func validateSession(for: PlayerType)
    func hasValidSession() -> Bool
    func enqueue(song: Song)
    func next()
    func play()
    func pause()
    func stop()
    func clearQueue()
    func getCurrentStatus() -> PlaybackStatus
    func unsubscribeFromUpdates()
}

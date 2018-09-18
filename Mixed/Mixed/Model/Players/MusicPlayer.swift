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
    func validateSession(for: PlayerType)
    func hasValidSession() -> Bool
    func hasSong() -> Bool
    func play(song: Song)
    func resume()
    func pause()
    func stop()
    func clearQueue()
    func getCurrentStatus() -> PlaybackStatus
}

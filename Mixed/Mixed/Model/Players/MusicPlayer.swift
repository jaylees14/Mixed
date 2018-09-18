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
    func hasSong() -> Bool
    func play(song: Song, autoplay: Bool)
    func resume()
    func pause()
    func stop()
    func getCurrentStatus() -> PlaybackStatus
}

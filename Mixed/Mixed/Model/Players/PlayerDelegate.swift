//
//  PlayerDelegate.swift
//  Mixed
//
//  Created by Jay Lees on 04/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

public protocol PlayerDelegate {
    func playerDidFinishPlaying(songID: String?)
    func playerDidChange(to state: PlaybackStatus)
    func requestAuth(to url: URL)
    func hasValidSession()
    func didReceiveError(_ error: Error)
}

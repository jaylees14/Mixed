//
//  MusicPlayerFactory.swift
//  Mixed
//
//  Created by Jay Lees on 03/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

class MusicPlayerFactory {
    static func generatePlayer(for provider: MusicProvider) -> MusicPlayer {
        switch provider {
        case .appleMusic: return AppleMusicPlayer()
        case .spotify: return SpotifyMusicPlayer()
        }
    }
}

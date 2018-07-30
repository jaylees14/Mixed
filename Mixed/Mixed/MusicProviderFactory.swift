//
//  MusicProviderFactory.swift
//  Mixed
//
//  Created by Jay Lees on 22/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

class MusicProviderFactory {
    static func generateMusicProvider(for provider: StreamingProvider, with delegate: MusicProviderDelegate) -> MusicProvider {
        switch provider {
        case .appleMusic: return AppleMusic(delegate: delegate)
        case .spotify: return Spotify(delegate: delegate)
        }
    }
}

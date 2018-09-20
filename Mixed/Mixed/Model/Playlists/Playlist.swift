//
//  Playlist.swift
//  Mixed
//
//  Created by Jay Lees on 18/09/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

struct PlaylistInfo: Decodable {
    struct TrackInfo : Decodable {
        let href: String
    }
    
    let name: String
    let tracks: TrackInfo
}

protocol Playlist {
    var playlistInfo: PlaylistInfo { get }
    var songs: [Song] { get }
    func downloadSongs(then: @escaping () -> Void)
}




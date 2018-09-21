//
//  MusicProvider.swift
//  Mixed
//
//  Created by Jay Lees on 22/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

protocol MusicProvider {
    func search(for query: String, callback: @escaping ([Song]?, Error?) -> Void)
    func getPlaylists(_ callback: @escaping ([Playlist]?, Error?) -> Void)
}

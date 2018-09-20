//
//  AppleMusicPlaylist.swift
//  Mixed
//
//  Created by Jay Lees on 20/09/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation
import MediaPlayer

class AppleMusicPlaylist: Playlist {
    var playlistInfo: PlaylistInfo
    var songs: [Song]
    
    init(playlistInfo: PlaylistInfo, songs : [Song] = []){
        self.playlistInfo = playlistInfo
        self.songs = songs
    }
    
    func downloadSongs(then: @escaping () -> Void){
        let token = ConfigurationManager.shared.appleMusicToken!
        // TODO: Refactor this, casting isn't nice
        MPMediaQuery.playlists().collections?.forEach({ (collection) in
            guard "\(collection.value(forProperty: MPMediaPlaylistPropertyPersistentID) as! NSNumber)" == playlistInfo.tracks.href else {
                return
            }
            let ids = collection.items.reduce("", { (acc, item) -> String in
                return "\(acc),\(item.playbackStoreID)"
            })
            let url = URL(string: "https://api.music.apple.com/v1/catalog/gb/songs?ids=" + ids)!
            NetworkRequest.getRequest(to: url, bearer: token) { (json, error) in
                guard error == nil, let json = json else {
                    Logger.log(error!, type: .error)
                    return
                }
                self.songs = self.processSongJSON(json)
                DispatchQueue.main.async {
                    then()
                }
                self.songs.forEach({$0.downloadImage(on: DispatchQueue(label: "com.jaylees.mixed.playlistdownload)"), then: { _ in then() })})
            }
        })
    }
    
    // TODO: Can we refactor this into the song class?
    private func processSongJSON(_ json: [String: Any]) -> [Song] {
        let data = json["data"] as! [[String: Any]]
        return data.map { song in
            let attributes = song["attributes"] as! [String:Any]
            let artistName = attributes["artistName"] as! String
            let artworkInfo = attributes["artwork"] as! [String: Any]
            let size = CGSize(width: artworkInfo["width"] as! Int, height: artworkInfo["height"] as! Int)
            let imageURL = artworkInfo["url"] as! String
            let songName = attributes["name"] as! String
            let songURL = attributes["url"] as! String
            let songID = songURL.components(separatedBy: "?i=")[1]
            
            return Song(artist: artistName, songName: songName, songURL: songID, imageURL: imageURL, imageSize: size, image: nil, addedBy: "someone", played: false)
        }
    }
}

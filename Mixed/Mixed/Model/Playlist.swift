//
//  Playlist.swift
//  Mixed
//
//  Created by Jay Lees on 18/09/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

struct PlaylistInfo: Decodable {
    struct Image : Decodable {
        let height: Int
        let url: String
        let width: Int
    }
    
    struct TrackInfo : Decodable {
        let href: String
        let total: Int
    }
    
    let name: String
    let images : [Image]
    let tracks : TrackInfo
}

protocol Playlist {
    var playlistInfo: PlaylistInfo { get }
    var songs: [Song] { get }
}

class AppleMusicPlaylist: Playlist {
    var playlistInfo: PlaylistInfo
    var songs: [Song]
    init(playlistInfo: PlaylistInfo){
        self.playlistInfo = playlistInfo
        self.songs = []
        downloadSongs()
    }
    
    private func downloadSongs(){
        
    }
}

class SpotifyPlaylist: Playlist {
    var playlistInfo: PlaylistInfo
    var songs: [Song]
    
    init(playlistInfo: PlaylistInfo){
        self.playlistInfo = playlistInfo
        self.songs = []
        DispatchQueue(label: "com.jaylees.mixed.downloadplaylist").async {
            self.downloadSongs()
        }
    }
    
    private func downloadSongs(){
        let url = URL(string: playlistInfo.tracks.href)!
        guard let session = SPTAuth.defaultInstance()?.session else {
            Logger.log("No active session", type: .debug)
            return
        }
        NetworkRequest.getRequest(to: url, bearer: session.accessToken) { (json, error) in
            guard error == nil else {
                Logger.log(error!, type: .debug)
                return
            }
            if let items = json?["items"] as? [[String: Any]] {
                self.songs = self.processJSON(items)
                self.songs.forEach({$0.downloadImage(on: DispatchQueue(label: "com.jaylees.mixed.playlist"), then: nil)})
            }
        }
    }
    
    private func processJSON(_ json: [[String: Any]]) -> [Song] {
        return json.map { (song)  -> Song in
            let item = song["track"] as! [String : Any]
            let artistData = item["artists"] as! [[String:Any]]
            var artist = ""
            for person in artistData {
                if artist != "" {
                    artist += " & "
                }
                artist += person["name"] as! String
            }
            
            let songName = item["name"] as! String
            let url = item["uri"] as! String
            let albumData = item["album"] as! [String:Any]
            let imageData = albumData["images"] as! [[String:Any]]
            let imageURL = imageData[0]["url"] as! String
            let imageWidth = imageData[0]["width"] as! Int
            let imageHeight = imageData[0]["height"] as! Int
            
            return Song(artist: artist,
                 songName: songName,
                 songURL: url,
                 imageURL: imageURL,
                 imageSize: CGSize(width: imageWidth, height: imageHeight),
                 image: nil,
                 addedBy: nil,
                 played: false)
        }
    }
}

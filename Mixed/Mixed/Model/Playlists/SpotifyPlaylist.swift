//
//  SpotifyPlaylist.swift
//  Mixed
//
//  Created by Jay Lees on 20/09/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

class SpotifyPlaylist: Playlist {
    var playlistInfo: PlaylistInfo
    var songs: [Song]
    
    init(playlistInfo: PlaylistInfo){
        self.playlistInfo = playlistInfo
        self.songs = []
    }
    
    public func downloadSongs(then: @escaping () -> Void){
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
                self.songs.forEach({$0.downloadImage(on: DispatchQueue(label: "com.jaylees.mixed.playlist"), then: { _ in then()})})
            }
        }
    }
    
    private func processJSON(_ json: [[String: Any]]) -> [Song] {
        let currentUser = try? CurrentUser.shared.getShortName()
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
                        addedBy: currentUser,
                        played: false)
        }
    }
}

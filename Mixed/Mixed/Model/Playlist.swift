//
//  Playlist.swift
//  Mixed
//
//  Created by Jay Lees on 18/09/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation
import MediaPlayer

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

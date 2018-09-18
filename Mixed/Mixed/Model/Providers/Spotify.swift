//
//  Spotify.swift
//  Mixed
//
//  Created by Jay Lees on 29/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import Foundation

enum SpotifyError: Error {
    case unknownError(code: Int)
    case invalidResponse
}

class Spotify: MusicProvider {
    func getPlaylists(_ callback: @escaping ([Playlist]?, Error?) -> Void) {
        guard let session = SPTAuth.defaultInstance()?.session else {
            Logger.log("Could not get current session", type: .error)
            return
        }
        getUserID(from: session) { (id) in
            guard let id = id else {
                Logger.log("No id found", type: .debug)
                return
            }
            let url = URL(string: "https://api.spotify.com/v1/users/\(id)/playlists")!
            NetworkRequest.getRequest(to: url, bearer: session.accessToken, callback: { (response, error) in
                let playlists = self.processPlaylistJSON(response ?? [:])
                callback(playlists, nil)
            })
        }
    }
    
    func search(for query: String, callback: @escaping ([Song]?, Error?) -> Void) {
        let formattedQuery = query.replacingOccurrences(of: " ", with: "+").lowercased()
        guard let url = URL(string: "https://api.spotify.com/v1/search?q=" + formattedQuery + "&type=track") else {
            Logger.log("Could not form URL", type: .error)
            return
        }
        var bearer = ""
        if let session = SPTAuth.defaultInstance().session.accessToken {
            bearer = session
        }
    
        NetworkRequest.getRequest(to: url, bearer: bearer) { (json, error) in
            guard error == nil, let json = json else {
                Logger.log("Error: \(error!)", type: .error)
                callback(nil, error!)
                return
            }
            let songs = self.processSearchJSON(json)
            callback(songs, nil)
        }
    }
    
    // MARK: - Utilities
    private func getUserID(from session: SPTSession, callback: @escaping (String?) -> Void){
        SPTUser.requestCurrentUser(withAccessToken: session.accessToken) { (error, data) in
            guard error == nil else {
                callback(nil)
                return
            }
            
            if let user = data as? SPTUser {
                callback(String(user.uri.absoluteString.split(separator: ":")[2]))
            } else {
                callback(nil)
            }
        }
    }
    
    private func processSearchJSON(_ json: [String: Any]) -> [Song] {
        guard let tracks = json["tracks"] as? [String:Any] else { return [] }
        guard let items = tracks["items"] as? [[String:Any]] else { return [] }
        let username = try? CurrentUser.shared.getShortName()
        
        var songs = [Song]()
        for item in items {
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
            
            let song = Song(artist: artist, songName: songName, songURL: url, imageURL: imageURL, imageSize: CGSize(width: imageWidth, height: imageHeight), image: nil, addedBy: username ?? "someone", played: false)
            songs.append(song)
        }
        return songs
    }
    
    private func processPlaylistJSON(_ json: [String: Any]) -> [Playlist] {
        if let items = json["items"] as? [[String: Any]],
           let data = try? JSONSerialization.data(withJSONObject: items) {
            let playlists = try? JSONDecoder().decode(Array<Playlist>.self, from: data)
            return playlists ?? []
        }
        return []
    }
}

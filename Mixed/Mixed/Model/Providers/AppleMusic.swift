//
//  AppleMusic.swift
//  SV
//
//  Created by Jay Lees on 09/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import Foundation
import UIKit
import StoreKit
import MediaPlayer

enum AppleMusicError: Error {
    case permissionDenied
    case noSubscription
    case unknownError(code: Int)
}

class AppleMusic: MusicProvider {
    func getPlaylists(_ callback: @escaping ([Playlist]?, Error?) -> Void) {
        
    }
    
    func search(for query: String, callback: @escaping ([Song]?, Error?) -> Void) {
        let formattedQuery = query.replacingOccurrences(of: " ", with: "+").lowercased()
        let url = URL(string: "https://api.music.apple.com/v1/catalog/gb/search?term=" + formattedQuery + "&limit=20")
        let token = ConfigurationManager.shared.appleMusicToken!
        
        NetworkRequest.getRequest(to: url!, bearer: token) { (json, error) in
            guard error == nil else {
                Logger.log(error!, type: .error)
                callback(nil, error)
                return
            }
            guard let json = json else {
                //TODO: Generate an error
                return
            }
            
            let songs = self.processSearchJSON(json)
            callback(songs, nil)
        }
    }
    
    //TODO: Refactor this to decodable and should return an error not []
    private func processSearchJSON(_ json: [String: Any]) -> [Song] {
        let results = json["results"] as! [String: Any]
        guard let songs = results["songs"] as? [String: Any] else { return [] }
        guard let songData = songs["data"] as? [Any] else { return [] }
        let username = try? CurrentUser.shared.getShortName()
        
        var songsArray = [Song]()
        for song in songData {
            if let song = song as? [String:Any] {
                let attributes = song["attributes"] as! [String:Any]
                let artistName = attributes["artistName"] as! String
                let artworkInfo = attributes["artwork"] as! [String: Any]
                let size = CGSize(width: artworkInfo["width"] as! Int, height: artworkInfo["height"] as! Int)
                let imageURL = artworkInfo["url"] as! String
                let songName = attributes["name"] as! String
                let songURL = attributes["url"] as! String
                let songID = songURL.components(separatedBy: "?i=")[1]

                let newSong = Song(artist: artistName, songName: songName, songURL: songID, imageURL: imageURL, imageSize: size, image: nil, addedBy: username ?? "someone", played: false)
                songsArray.append(newSong)
            }
        }
        return songsArray
    }
}

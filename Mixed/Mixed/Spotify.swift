//
//  Spotify.swift
//  Mixed
//
//  Created by Jay Lees on 29/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import Foundation

protocol SpotifyDelegate {
    func spotifyQueryDidReturn(_ songs: [Song])
    func spotifyError(code: Int)
}

class Spotify {
    
    var delegate: SpotifyDelegate?
    
    init(delegate: SpotifyDelegate){
        self.delegate = delegate
    }
    
    public func makeSearchRequest(query: String){
        let formattedQuery = query.replacingOccurrences(of: " ", with: "+").lowercased()
        let url = URL(string: "https://api.spotify.com/v1/search?q=" + formattedQuery + "&type=track")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        if let session = SPTAuth.defaultInstance().session.accessToken {
            urlRequest.setValue("Bearer \(session)", forHTTPHeaderField: "Authorization")
        }
    
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                print("Spotify Error: Error from URL request \(error!)")
                return
            }
            guard let data = data else {
                print("Spotify Error: Error data returned is nil")
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            if response.statusCode == 200 {
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                self.processSearchJSON(json)
            } else {
                self.delegate?.spotifyError(code: response.statusCode)
            }
        }
        task.resume()
    }
    
    private func processSearchJSON(_ json: [String: Any]){
        guard let tracks = json["tracks"] as? [String:Any] else { return }
        guard let items = tracks["items"] as? [[String:Any]] else { return }
        
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
            let song = Song(artist: artist, songName: songName, songURL: url, imageURL: imageURL, imageSize: CGSize(width: imageWidth, height: imageHeight), image: nil)
            songs.append(song)
        }
        
        DispatchQueue.main.async {
            self.delegate?.spotifyQueryDidReturn(songs)
        }
        
    }
    
    
}

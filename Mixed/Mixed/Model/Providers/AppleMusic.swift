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
    var delegate: MusicProviderDelegate?
    
    init(delegate: MusicProviderDelegate){
        self.delegate = delegate
        self.determineAuthStatus()
    }
    
    private func determineAuthStatus() {
        // Determine if the user is already authorised
        switch SKCloudServiceController.authorizationStatus() {
        case .authorized:
            return
        case .denied:
            delegate?.queryDidFail(AppleMusicError.permissionDenied)
        case .notDetermined:
            requestAuth()
        case .restricted:
            delegate?.queryDidFail(AppleMusicError.noSubscription)
        }
    }
    
    private func requestAuth(){
        SKCloudServiceController.requestAuthorization { (status:SKCloudServiceAuthorizationStatus) in
            switch status {
            case .authorized:
                break
            case .denied:
                self.delegate?.queryDidFail(AppleMusicError.permissionDenied)
                break
            case .notDetermined:
                break;
            case .restricted:
                self.delegate?.queryDidFail(AppleMusicError.noSubscription)
            }
        }
    }
    
    public func search(for query: String){
        let formattedQuery = query.replacingOccurrences(of: " ", with: "+").lowercased()
        let url = URL(string: "https://api.music.apple.com/v1/catalog/gb/search?term=" + formattedQuery + "&limit=20")
        let token = ConfigurationManager.shared.appleMusicToken!
        

        NetworkRequest.getRequest(to: url!, bearer: token) { (json, error) in
            guard error == nil else {
                print(error!)
                return
            }
            guard let json = json else {
                return
            }
            
            self.processSearchJSON(json)
        }
    }
    
    //TODO: Refactor this to decodable
    private func processSearchJSON(_ json: [String: Any]){
        let results = json["results"] as! [String: Any]
        guard let songs = results["songs"] as? [String: Any] else { return }
        guard let songData = songs["data"] as? [Any] else { return }
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
        
        DispatchQueue.main.async {
            self.delegate?.queryDidSucceed(songsArray)
        }
    }
}

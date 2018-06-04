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

protocol AppleMusicDelegate {
    func queryDidReturn(_ songs: [Song])
    func permissionDenied()
    func noSubscription()
    func appleMusicError(code: Int)
}

class AppleMusic {
    var delegate: AppleMusicDelegate?
    
    init(delegate: AppleMusicDelegate){
        self.delegate = delegate
        requestCapabilities { (result) in
            guard result else {
                delegate.noSubscription()
                return
            }
            self.determineAuthStatus()
        }
        
    }
    
    private func requestCapabilities(_ callback: @escaping (Bool) -> Void) {
        let serviceController = SKCloudServiceController()
        serviceController.requestCapabilities { (capability, error) in
            switch capability {
            case SKCloudServiceCapability.musicCatalogPlayback,
                 SKCloudServiceCapability.addToCloudMusicLibrary:
                callback(true)
            default:
                callback(false)
            }
        }
    }
    
    private func determineAuthStatus() {
        // Determine if the user is already authorised
        switch SKCloudServiceController.authorizationStatus() {
        case .authorized:
            return
        case .denied:
            delegate?.permissionDenied()
        case .notDetermined:
            requestAuth()
        case .restricted:
            delegate?.noSubscription()
        }
    }
    
    private func requestAuth(){
        SKCloudServiceController.requestAuthorization { (status:SKCloudServiceAuthorizationStatus) in
            switch status {
            case .authorized:
                break
            case .denied:
                self.delegate?.permissionDenied()
                break
            case .notDetermined:
                break;
            case .restricted:
                self.delegate?.noSubscription()
            }
        }
    }
    
    public func makeSearchRequest(query: String){
        let formattedQuery = query.replacingOccurrences(of: " ", with: "+").lowercased()
        let url = URL(string: "https://api.music.apple.com/v1/catalog/gb/search?term=" + formattedQuery + "&limit=20")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "GET"
        let token = UserDefaults.standard.value(forKey: "AMTOKEN") as! String
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                print("AppleMusic Error: Error from URL request \(error!)")
                return
            }
            guard let data = data else {
                print("AppleMusic Error: Error data returned is nil")
                return
            }
            
            guard let response = response as? HTTPURLResponse else { return }
            print("Response code: ", response.statusCode)
            if response.statusCode == 200 {
                let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                self.processSearchJSON(json)
            } else {
                self.delegate?.appleMusicError(code: response.statusCode)
            }
        }
        task.resume()
    }
    
    private func processSearchJSON(_ json: [String: Any]){
        let results = json["results"] as! [String: Any]
        guard let songs = results["songs"] as? [String: Any] else { return }
        guard let songData = songs["data"] as? [Any] else { return }
        
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

                let newSong = Song(artist: artistName, songName: songName, songURL: songURL, imageURL: imageURL, imageSize: size, image: nil)
                songsArray.append(newSong)
            }
        }
        
        DispatchQueue.main.async {
            self.delegate?.queryDidReturn(songsArray)
        }
    }
    
    
    //    func appleMusicFetchStorefrontRegion() {
    //        let serviceController = SKCloudServiceController()
    //        serviceController.requestStorefrontIdentifier { (id, error) in
    //            guard error == nil else { return }
    //            print(id)
    //        }
    //    }

}

//
//  DataStore.swift
//  Mixed
//
//  Created by Jay Lees on 23/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation
import Firebase

protocol DatastoreDelegate {
    func didAddSong(_ song: Song)
    func duplicateSongAdded(_ song: Song)
    func queueDidChange(songs: [Song])
}

extension Encodable {
    var asDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}

class Datastore {
    private let ref = Database.database().reference()
    private let databaseName = "v2-parties-beta"
    
    public static let instance = Datastore()
    public var delegate: DatastoreDelegate?
    
    private init() { }
    
    public func addSong(song: Song, to party: String, completion: (() -> Void)? = nil){
        let partyQueue = ref.child(databaseName).child(party).child("queue")
        partyQueue.observeSingleEvent(of: .value) { (snapshot) in
            let currentQueueSize: Int = (snapshot.value as? Array<Any>)?.count ?? 0
            if currentQueueSize > 0 {
                let lastSongAdded = (snapshot.value as! Array<[String:Any]>)[currentQueueSize - 1]
                let url = lastSongAdded["songURL"] as! String
                if url == song.songURL {
                    // We don't allow the same song to be added directly after each other
                    self.delegate?.duplicateSongAdded(song)
                    completion?()
                    return
                }
            }
            
            if let data = song.asDictionary {
                partyQueue.child("\(currentQueueSize)").setValue(data)
            }
            completion?()
        }
    }
    public func addSongs(songs: [Song], to party: String) {
        // There is a slight issue with the Spotify API that can't deal with the requests coming in
        // as quickly to enqueue a new song. We mitigate this for now by delaying the song uploads
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard !songs.isEmpty else { return }
            self.addSong(song: songs.first!, to: party) {
                self.addSongs(songs: Array(songs.dropFirst()), to: party)
            }
        }
    }
    
    // Recursively generates a new party ID
    private func generatePartyID(callback: @escaping (String) -> Void){
        let id = randomString(length: 6)
        ref.child(databaseName).child(id).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                self.generatePartyID(callback: callback)
            } else {
                callback(id)
            }
        })
    }
    
    public func createNewParty(with provider: StreamingProvider, callback: @escaping (String) -> Void) {
        generatePartyID { (id) in
            let username = (try? CurrentUser.shared.getShortName()) ?? "Someone"
            self.ref.child(self.databaseName).child(id).child("host").setValue(username)
            self.ref.child(self.databaseName).child(id).child("streamingProvider").setValue(provider.rawValue)
            self.ref.child(self.databaseName).child(id).child("queue").setValue([])
            callback(id)
        }
    }
    
    // FIXME: If user is listening to songs via offical AM app, it triggers this!!
    public func didFinish(song id: Int, party: String){
        ref.child(databaseName).child(party).child("queue").child("\(id)").child("played").setValue(true)
    }
    
    public func joinParty(with id: String, callback: @escaping (Party?) -> ()) {
        ref.child(databaseName).child(id).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                guard let value = snapshot.value as? [String: Any],
                      let partyHost = value["host"] as? String,
                      let provider = value["streamingProvider"] as? String else {
                        callback(nil)
                        return
                }
                
                let party = Party(partyHost: partyHost,
                                  partyID: id,
                                  streamingProvider: StreamingProvider(rawValue: provider)!)
                callback(party)
            } else {
                callback(nil)
            }
        }
    }

    public func submitFeedback(_ feedback: String, systemConfig: [String: Any]){
        ref.child("feedback").observeSingleEvent(of: .value) { (snapshot) in
            var modifiedConfig = systemConfig
            modifiedConfig["feedback"] = feedback
            if snapshot.exists() {
                var currentFeedback = snapshot.value as? [[String: Any]]
                currentFeedback?.append(modifiedConfig)
                self.ref.child("feedback").setValue(currentFeedback)
            } else {
                self.ref.child("feedback").setValue([modifiedConfig])
            }
        }
    }
    
    public func subscribeToUpdates(for party: String, type: PlayerType){
        
        if type == .host {
            ref.child(databaseName).child(party).child("queue").observe(.childAdded) { (snapshot) in
                guard let json = snapshot.value as? [String: Any],
                      let data = try? JSONSerialization.data(withJSONObject: json, options: []),
                      let song = try? JSONDecoder().decode(Song.self, from:  data) else {
                       Logger.log("Failed to decode response", type: .error)
                    return
                }
                self.delegate?.didAddSong(song)
            }
        } else {
            ref.child(databaseName).child(party).observe(.childChanged) { (snapshot) in
                guard let json = snapshot.value as? [[String: Any]],
                    let data = try? JSONSerialization.data(withJSONObject: json, options: []),
                    let songs = try? JSONDecoder().decode(Array<Song>.self, from:  data) else {
                        Logger.log("Failed to decode response", type: .error)
                        return
                }
                self.delegate?.queueDidChange(songs: songs)
            }
        }
    }
    
    public func unsubscribeFromUpdates() {
        ref.removeAllObservers()
    }
}

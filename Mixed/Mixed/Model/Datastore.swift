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
    func topSongDidChange(to song: Song)
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
    
    public func addSong(song: Song, to party: String){
        let partyQueue = ref.child(databaseName).child(party).child("queue")
        partyQueue.observeSingleEvent(of: .value) { (snapshot) in
            let currentQueueSize: Int = (snapshot.value as? Array<Any>)?.count ?? 0
            if let data = song.asDictionary {
                partyQueue.child("\(currentQueueSize)").setValue(data)
            } else {
                // TODO: Notify of failure
            }
            
        }
        print("Adding \(song.songName)")
    }
    
    public func createNewParty(with provider: StreamingProvider) -> String {
        //TODO: Create a UUID for each
        let betaID = "abcdef"
        ref.child(databaseName).child(betaID).child("host").setValue("Jay")
        ref.child(databaseName).child(betaID).child("streamingProvider").setValue(provider.rawValue)
        ref.child(databaseName).child(betaID).child("queue").setValue([])
        return betaID
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
    
    public func remove(song: Song){
        
    }
    
    
    public func subscribeToUpdates(for party: String){
        ref.child(databaseName).child(party).child("queue").observe(.childAdded) { (snapshot) in
            guard let json = snapshot.value as? [String: Any],
                  let data = try? JSONSerialization.data(withJSONObject: json, options: []),
                  let song = try? JSONDecoder().decode(Song.self, from:  data) else {
                    print("Could not decode data :(")
                return
            }
            self.delegate?.didAddSong(song)
        }
        
        ref.child(databaseName).child(party).child("queue").observe(.childChanged) { (snapshot) in
            print(snapshot.value)
        }
        // Call delegate.didAddSong
    }
    
    
    
}

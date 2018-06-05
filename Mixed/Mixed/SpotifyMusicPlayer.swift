//
//  SpotifyMusicPlayer.swift
//  Mixed
//
//  Created by Jay Lees on 03/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

public class SpotifyMusicPlayer: NSObject, MusicPlayer {
    private let player: SPTAudioStreamingController
    private var delegate: PlayerDelegate?
    private var hasStarted: Bool = false
    
    public override init() {
        
        player = SPTAudioStreamingController.sharedInstance()
        //player.playbackDelegate = self
        
        super.init()
        
        
    }
    
    private func startPlayer(){
        do {
            try self.player.start(withClientId: SPTAuth.defaultInstance().clientID)
        } catch let error {
            print("Error whilst starting!! \(error)")
            //TODO: Parser error
            return
        }
        
        self.player.login(withAccessToken: SPTAuth.defaultInstance().session.accessToken)
        self.player.setIsPlaying(false, callback: { (error) in
            // TODO: Parse error
        })
        self.hasStarted = true
    }
    
    public func setDelegate(_ delegate: PlayerDelegate) {
        self.delegate = delegate
    }
    
    
    // MARK: - Music Player
    
    public func validateSession() {
        // If a valid session already exists, start player
        if let session = SPTAuth.defaultInstance().session {
            if session.isValid() {
                startPlayer()
                return
            }
        }
        
        // Otherwise request auth from spotify
        self.delegate?.requestAuth(to: SPTAuth.defaultInstance().spotifyWebAuthenticationURL())
    }
    
    
    public func play() {
        if player.metadata.currentTrack == nil {
            print("No current track")
        }
        
        print("Playing")
        player.setIsPlaying(true) { (error) in
            guard error == nil else {
                print(error)
                // TODO: Throw
                return
            }
        }
    }
    
    public func pause() {
        print("Pausing")
        player.setIsPlaying(false) { (error) in
            guard error == nil else {
                print(error)
                // TODO: Throw
                return
            }
        }
    }
    
    public func next() {
        
    }
    
    public func clearQueue() {
        
    }
    
    public func enqueue(song: String) {
        if !hasStarted {
            startPlayer()
        }
        
        if player.metadata == nil || player.metadata.currentTrack == nil {
            player.playSpotifyURI(song, startingWith: 0, startingWithPosition: 0) { (error) in
                guard error == nil else {
                    // TODO: Throw error elsewhere
                    print("Could not play")
                    return
                }
                self.pause()
            }
            
        } else {
            player.queueSpotifyURI(song, callback: { (error) in
                if error != nil {
                    print("Could not queue \(error)")
                    // TODO: Throw error elsewhere
                }
            })
        }
    }
    
    public func getCurrentStatus() -> PlaybackStatus {
        return player.playbackState.isPlaying ? .playing : .paused
    }
    
}




//MARK: - Spotify Session

//
//    func closeSpotifySession(){
//        spotifyPlayer?.setIsPlaying(false, callback: { (_) in
//            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (_) in
//                self.spotifyPlayer?.logout()
//
//                do {
//                 try self.spotifyPlayer?.stop()
//                } catch let error {
//                    print(error)
//                }
//
//                self.navigationController?.popViewController(animated: true)
//            })
//        })
//    }

extension SpotifyMusicPlayer: SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    //If an error was formed from the server, display it to the user in an altert conroller
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
        // TODO: Process Message/Error?
    }

    //Did switch between playing and not playing
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        print("Playback status did change to \(isPlaying)")
        
        
//        if !isPlaying && songQueue.count == 1 && spotifyPlayer?.metadata.currentTrack != nil && !spotifyTappedPause {
//            spotifyDidFinish = true
//            Database.database().reference().child("parties").child(self.partyID).child("queue").child(String(self.playedSongs.count)).child("played").setValue(true)
//            self.playedSongs.append(self.songQueue[0])
//            self.songQueue.remove(at: 0)
//            self.tableView.reloadData()
//        }
//
//        if isPlaying {
//            playButton.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
//            self.activateAudioSession()
//        } else  {
//            playButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
//            self.deactivateAudioSession()
//        }
    }

    // If metadata changes then update the UI
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
//        if isQueueing {
//            isQueueing = false
//            return
//        }
//        if spotifyPlayer?.metadata.prevTrack != nil {
//            Database.database().reference().child("parties").child(partyID).child("queue").child(String(playedSongs.count)).child("played").setValue(true)
//            playedSongs.append(songQueue[0])
//            songQueue.remove(at: 0)
//            tableView.reloadData()
//        }
    }

    //If user did logout, close session
    public func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
        //self.closeSpotifySession()
    }
    
    public func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // TODO: FILL THIS IN!!!!!
    }

    //If recieve error, show error
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
        //TODO: Parse Error
    }


    // MARK: Activate audio session
    func activateAudioSession() {
//        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: Deactivate audio session
    func deactivateAudioSession() {
//        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

//SPOT
//            guard songQueue.count > 0 else { return }
//            if spotifyPlayer?.playbackState != nil {
//                if spotifyPlayer?.metadata.currentTrack == nil || spotifyDidFinish {
//                    spotifyPlayer?.playSpotifyURI(songQueue[0].songURL, startingWith: 0, startingWithPosition: 0, callback: { (error) in
//                        if let error = error {
//                            print(error)
//                        }
//                    })
//                    spotifyDidFinish = false
//                }
//
//                spotifyPlayer?.setIsPlaying(!(spotifyPlayer?.playbackState.isPlaying)!, callback: { (error) in
//                    if let error = error {
//                        print(error)
//                    }
//                })
//
//                spotifyTappedPause = !spotifyTappedPause
//
//            }


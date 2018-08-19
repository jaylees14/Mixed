//
//  SpotifyMusicPlayer.swift
//  Mixed
//
//  Created by Jay Lees on 03/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation
import MediaPlayer

public class SpotifyMusicPlayer: NSObject, MusicPlayer {
    private let player: SPTAudioStreamingController
    private var delegate: PlayerDelegate?
    private var hasStarted: Bool = false
    private var gotFirstTrack: Bool = false
    
    public override init() {
        player = SPTAudioStreamingController.sharedInstance()
        super.init()
        player.playbackDelegate = self
    }
    
    private func startPlayer(){
        do {
            try self.player.start(withClientId: SPTAuth.defaultInstance().clientID)
        } catch let error {
            delegate?.didReceiveError(error)
            return
        }
        
        self.player.login(withAccessToken: SPTAuth.defaultInstance().session.accessToken)
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
        DispatchQueue.main.async {
            self.delegate?.requestAuth(to: SPTAuth.defaultInstance().spotifyWebAuthenticationURL())
        }
    }
    
    public func hasValidSession() -> Bool {
        if let session = SPTAuth.defaultInstance().session {
            return session.isValid()
        }
        return false
    }
    
    
    public func play() {
        guard player.metadata.currentTrack != nil && gotFirstTrack else {
            return
        }
        
        player.setIsPlaying(true) { (error) in
            guard error == nil else {
                self.delegate?.didReceiveError(error!)
                return
            }
        }
    }
    
    public func pause() {
        player.setIsPlaying(false) { (error) in
            guard error == nil else {
                self.delegate?.didReceiveError(error!)
                return
            }
        }
    }
    
    public func next() {
        guard player.metadata.nextTrack != nil else {
            self.pause()
            self.gotFirstTrack = false
            self.delegate?.playerDidStartPlaying(songID: nil)
            return
        }
        
        player.skipNext { (error) in
            guard error == nil else {
                self.delegate?.didReceiveError(error!)
                return
            }
        }
    }
    
    public func stop(){
        self.pause()
    }
    
    public func clearQueue() {
        self.gotFirstTrack = false
    }
    
    public func enqueue(song: Song) {
        if !hasStarted {
            startPlayer()
        }

        if !gotFirstTrack {
            player.playSpotifyURI(song.songURL, startingWith: 0, startingWithPosition: 0) { (error) in
                guard error == nil else {
                    self.delegate?.didReceiveError(error!)
                    return
                }
                self.pause()
                self.gotFirstTrack = true
            }
        } else {
            player.queueSpotifyURI(song.songURL, callback: { (error) in
                guard error == nil else {
                    self.delegate?.didReceiveError(error!)
                    return
                }
            })
        }
    }
    
    public func getCurrentStatus() -> PlaybackStatus {
        return player.playbackState.isPlaying ? .playing : .paused
    }
    
}


extension SpotifyMusicPlayer: SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    //If an error was formed from the server, display it to the user in an altert conroller
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
        // TODO: Process Message/Error?
    }

    //Did switch between playing and not playing
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        delegate?.playerDidChange(to: isPlaying ? .playing : .paused)
        
        //Allows audio to be played in background
        if isPlaying {
            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try? AVAudioSession.sharedInstance().setActive(true)
        } else {
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }
    
    
    // If metadata changes then update the UI
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        delegate?.playerDidStartPlaying(songID: metadata.currentTrack?.uri)
    }

    public func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("Login did finish")
        // TODO: FILL THIS IN!!!!!
    }

    //If recieve error, show error
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
        if let error = error {
             delegate?.didReceiveError(error)
        }
    }
}


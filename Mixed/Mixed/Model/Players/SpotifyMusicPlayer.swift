//
//  SpotifyMusicPlayer.swift
//  Mixed
//
//  Created by Jay Lees on 03/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation
import MediaPlayer

public enum SpotifyPlayerError: Error {
    case noSubscription
    case invalidSignIn
}

public class SpotifyMusicPlayer: NSObject, MusicPlayer {
    private static let player: SPTAudioStreamingController = SPTAudioStreamingController.sharedInstance()
    private var delegate: PlayerDelegate?
    private var hasStarted: Bool = false
    private var gotFirstTrack: Bool = false
    
    public override init() {
        super.init()
        SpotifyMusicPlayer.player.playbackDelegate = self
    }
    
    private func startPlayer(){
        do {
            try SpotifyMusicPlayer.player.start(withClientId: SPTAuth.defaultInstance().clientID)
        } catch {
            Logger.log("Error whilst starting Spotify player - it's probably already started.", type: .error)
        }
        SpotifyMusicPlayer.player.login(withAccessToken: SPTAuth.defaultInstance().session.accessToken)
        self.delegate?.hasValidSession()
        self.hasStarted = true
    }
    
    public func setDelegate(_ delegate: PlayerDelegate) {
        self.delegate = delegate
    }
    
    
    // MARK: - Music Player
    
    public func validateSession(for player: PlayerType) {
        // If a valid session already exists, start player
        if let session = SPTAuth.defaultInstance().session {
            if session.isValid() {
                // request current user to make sure they have premium
                SPTUser.requestCurrentUser(withAccessToken: session.accessToken) { (error, data) in
                    guard error == nil else {
                        Logger.log(error!, type: .debug)
                        self.delegate?.didReceiveError(SpotifyPlayerError.invalidSignIn)
                        return
                    }
        
                    if let user = data as? SPTUser {
                        // Either have to have preimum, or be an attendee
                        guard user.product == SPTProduct.premium || player == PlayerType.attendee else {
                            self.delegate?.didReceiveError(SpotifyPlayerError.noSubscription)
                            return
                        }
                        self.startPlayer()
                    }
                }
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
        guard SpotifyMusicPlayer.player.metadata.currentTrack != nil && gotFirstTrack else {
            return
        }
        
        SpotifyMusicPlayer.player.setIsPlaying(true) { (error) in
            guard error == nil else {
                self.delegate?.didReceiveError(error!)
                return
            }
        }
    }
    
    public func pause() {
        SpotifyMusicPlayer.player.setIsPlaying(false) { (error) in
            guard error == nil else {
                self.delegate?.didReceiveError(error!)
                return
            }
        }
    }
    
    public func next() {
        guard SpotifyMusicPlayer.player.metadata.nextTrack != nil else {
            self.pause()
            self.gotFirstTrack = false
            self.delegate?.playerDidStartPlaying(songID: nil)
            return
        }
        
        SpotifyMusicPlayer.player.skipNext { (error) in
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
            SpotifyMusicPlayer.player.playSpotifyURI(song.songURL, startingWith: 0, startingWithPosition: 0) { (error) in
                guard error == nil else {
                    self.delegate?.didReceiveError(error!)
                    return
                }
                self.pause()
                self.gotFirstTrack = true
            }
        } else {
            SpotifyMusicPlayer.player.queueSpotifyURI(song.songURL, callback: { (error) in
                guard error == nil else {
                    self.delegate?.didReceiveError(error!)
                    return
                }
            })
        }
    }
    
    public func getCurrentStatus() -> PlaybackStatus {
        if SpotifyMusicPlayer.player.playbackState == nil {
            return .paused
        }
        return SpotifyMusicPlayer.player.playbackState.isPlaying ? .playing : .paused
    }
    
}


extension SpotifyMusicPlayer: SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    //If an error was formed from the server, display it to the user in an altert conroller
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
        Logger.log(message, type: .warning)
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
        Logger.log("Spotify login succeeded", type: .debug)
    }

    //If recieve error, show error
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
        if let error = error {
             delegate?.didReceiveError(error)
        }
    }
}


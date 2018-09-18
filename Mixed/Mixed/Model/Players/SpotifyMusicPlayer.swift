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
    public var delegate: PlayerDelegate?
    
    private var hasStarted: Bool = false
    private var triggeredByButton: Bool = false
    private var hasSongToPlay: Bool = false
    
    public override init() {
        super.init()
        SpotifyMusicPlayer.player.playbackDelegate = self
    }
    
    private func startPlayer(){
        try? SpotifyMusicPlayer.player.start(withClientId: SPTAuth.defaultInstance().clientID)
        SpotifyMusicPlayer.player.login(withAccessToken: SPTAuth.defaultInstance().session.accessToken)
        self.delegate?.hasValidSession()
        self.hasStarted = true
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
    
    public func hasSong() -> Bool {
        return hasSongToPlay
    }
    
    
    public func play(song: Song, autoplay: Bool) {
        hasSongToPlay = true
        SpotifyMusicPlayer.player.playSpotifyURI(song.songURL, startingWith: 0, startingWithPosition: 0) { (error) in
            guard error == nil else {
                self.delegate?.didReceiveError(error!)
                return
            }
            if !autoplay {
                self.pause()
            }
        }
    }
    
    public func resume() {
        guard hasSongToPlay else { return }
        triggeredByButton = true
        SpotifyMusicPlayer.player.setIsPlaying(true) { (error) in
            guard error == nil else {
                self.delegate?.didReceiveError(error!)
                return
            }
        }
    }
    
    public func pause() {
        guard hasSongToPlay else { return }
        triggeredByButton = true
        SpotifyMusicPlayer.player.setIsPlaying(false) { (error) in
            guard error == nil else {
                self.delegate?.didReceiveError(error!)
                return
            }
        }
    }
    
    public func stop(){
        self.pause()
        hasSongToPlay = false
    }
    
    public func getCurrentStatus() -> PlaybackStatus {
        if SpotifyMusicPlayer.player.playbackState == nil {
            return .paused
        }
        return SpotifyMusicPlayer.player.playbackState.isPlaying ? .playing : .paused
    }
    
}


extension SpotifyMusicPlayer: SPTAudioStreamingPlaybackDelegate {
    public func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        delegate?.playerDidChange(to: isPlaying ? .playing : .paused)
        
        if !triggeredByButton && !isPlaying {
            hasSongToPlay = false
            delegate?.playerDidFinishPlaying(songID: audioStreaming.metadata.currentTrack?.uri)
        }
        
        triggeredByButton = false
        //Allows audio to be played in background
        if isPlaying {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .allowBluetooth)
            try? AVAudioSession.sharedInstance().setActive(true)
        } else {
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }
}

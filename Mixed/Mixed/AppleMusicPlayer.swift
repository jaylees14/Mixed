//
//  AppleMusicPlayer.swift
//  Mixed
//
//  Created by Jay Lees on 03/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation
import MediaPlayer

public class AppleMusicPlayer: MusicPlayer {
    private let player: MPMusicPlayerController
    private var hasSetInitialQueue = false
    private var delegate: PlayerDelegate?
    
    public init(){
        player = .systemMusicPlayer
        player.beginGeneratingPlaybackNotifications()
        player.repeatMode = .none
        player.shuffleMode = .off
        
        // Subscribe to updates
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(nowPlayingChanged),
                                               name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(nowPlayingStateChanged),
                                               name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange,
                                               object: nil)
    }
    
    public func setDelegate(_ delegate: PlayerDelegate) {
        self.delegate = delegate
    }

    
    // MARK: - Music Player
    public func validateSession() {
        // Not needed for AM
    }
    
    public func play() {
        guard hasSetInitialQueue else {
            //TODO: Throw an error
            return
        }
        
        player.prepareToPlay { (error) in
            guard error == nil else {
                self.delegate?.didReceiveError(error!)
                return
            }
            self.player.play()
        }
    }
    
    public func pause() {
        player.pause()
    }
    
    //TODO: If next on last song, remove has set inital queue
    public func next() {
        guard hasSetInitialQueue else {
            return
        }
        
        player.skipToNextItem()
    }
    
    public func clearQueue() {
        self.hasSetInitialQueue = false
    }

    public func enqueue(song: Song) {
        let storeID = song.songURL.components(separatedBy: "?i=")[1]
        if !hasSetInitialQueue {
            self.player.setQueue(with: MPMusicPlayerStoreQueueDescriptor(storeIDs: [storeID]))
            self.delegate?.playerDidStartPlaying(songID: storeID)
            hasSetInitialQueue = true
        } else {
            self.player.append(MPMusicPlayerStoreQueueDescriptor(storeIDs: [storeID]))
        }
    }
    
    public func getCurrentStatus() -> PlaybackStatus {
        return player.playbackState == .playing ? PlaybackStatus.playing : PlaybackStatus.paused
    }
    
    
    // MARK: - Player Notifications
    @objc private func nowPlayingChanged(){
        delegate?.playerDidStartPlaying(songID: player.nowPlayingItem?.playbackStoreID)
    }
    
    @objc private func nowPlayingStateChanged(){
        switch player.playbackState {
        case .stopped:
            delegate?.playerDidChange(to: .stopped)
        case .playing:
            delegate?.playerDidChange(to: .playing)
        case .paused:
            delegate?.playerDidChange(to: .paused)
        default:
            break
        }
    }
}

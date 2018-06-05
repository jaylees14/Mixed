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
                print("!!!!!!!!! \(error)")
                // TODO: Throw?
                return
            }
            self.player.play()
        }
    }
    
    public func pause() {
        player.pause()
    }
    
    public func next() {
        player.skipToNextItem()
    }
    
    public func clearQueue(){
        // We mock clearing the queue by forcing the next song in the queue to be "set queue"
        hasSetInitialQueue = false
    }
    
    public func enqueue(song: String) {
        if !hasSetInitialQueue {
             self.player.setQueue(with: MPMusicPlayerStoreQueueDescriptor(storeIDs: [song]))
            hasSetInitialQueue = true
        } else {
            self.player.append(MPMusicPlayerStoreQueueDescriptor(storeIDs: [song]))
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

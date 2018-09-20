//
//  AppleMusicPlayer.swift
//  Mixed
//
//  Created by Jay Lees on 03/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation
import MediaPlayer

public enum AppleMusicPlayerError: Error {
    case notSignedIn
    case noSubscription
}

public class AppleMusicPlayer: MusicPlayer {
    private let player: MPMusicPlayerController
    private var hasSetInitialQueue = false
    public var delegate: PlayerDelegate?
    
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
    
    // MARK: - Music Player
    public func validateSession(for player: PlayerType) {
        if player == .attendee {
            self.delegate?.hasValidSession()
            return
        }
        SKCloudServiceController.requestAuthorization { status in
            switch status {
            case .authorized:
                SKCloudServiceController().requestCapabilities(completionHandler: { (capability, error) in
                    guard error == nil else {
                        Logger.log(error!, type: .error)
                        self.delegate?.didReceiveError(error!)
                        return
                    }
                    if capability.contains(SKCloudServiceCapability.musicCatalogPlayback) {
                        Logger.log("Has an AM subscription and can playback music!", type: .debug)
                        self.delegate?.hasValidSession()
                    } else if  capability.contains(SKCloudServiceCapability.addToCloudMusicLibrary) {
                        Logger.log("Has an AM subscription, can playback music AND can add to the Cloud Music Library", type: .debug)
                        self.delegate?.hasValidSession()
                    } else {
                        Logger.log("Has no AM subscription", type: .debug)
                        self.delegate?.didReceiveError(AppleMusicPlayerError.noSubscription)
                    }
                })
                break
            default:
                self.delegate?.didReceiveError(AppleMusicPlayerError.notSignedIn)
            }
        }
    }
    
    public func hasValidSession() -> Bool {
        return true
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
    
    public func stop(){
        player.stop()
    }
    
    public func clearQueue() {
        self.hasSetInitialQueue = false
    }
    
    public func enqueue(song: Song) {
        if !hasSetInitialQueue {
            self.player.setQueue(with: MPMusicPlayerStoreQueueDescriptor(storeIDs: [song.songURL]))
            self.delegate?.playerDidStartPlaying(songID: song.songURL)
            hasSetInitialQueue = true
        } else {
            self.player.append(MPMusicPlayerStoreQueueDescriptor(storeIDs: [song.songURL]))
        }
    }
    
    public func getCurrentStatus() -> PlaybackStatus {
        return player.playbackState == .playing ? PlaybackStatus.playing : PlaybackStatus.paused
    }
    
    public func unsubscribeFromUpdates() {
        self.delegate = nil
        NotificationCenter.default.removeObserver(self)
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

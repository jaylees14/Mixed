//
//  SpotifyMusicPlayer.swift
//  Mixed
//
//  Created by Jay Lees on 03/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

class SpotifyMusicPlayer: MusicPlayer {
    let player: SPTAudioStreamingController
    
    init() {
        player = SPTAudioStreamingController.sharedInstance()
    }
    
    func setDelegate(_ delegate: PlayerDelegate) {
        //self.delegate = delegate
    }
    
    func play() {
        
    }
    
    func pause() {
        
    }
    
    func next() {
        
    }
    
    func clearQueue() {
        
    }
    
    func enqueue(song: String) {
        
    }
    
    func getCurrentStatus() -> PlaybackStatus {
        return .playing
    }
    
}

//MARK: - Provider setup
//    func setupSpotify(){
//        if let session = SPTAuth.defaultInstance().session {
//            if session.isValid() {
//                createNewSpotifySession()
//                observeDatabase()
//            } else {
//                requestSpotifyAuth()
//                return
//            }
//        } else {
//            requestSpotifyAuth()
//            return
//        }
//    }
//
//    @objc func sessionSuccess(){
//        safariViewController?.dismiss(animated: true, completion: nil)
//        createNewSpotifySession()
//        observeDatabase()
//    }
//
//    func requestSpotifyAuth(){
//        let alert = UIAlertController(title: "You need to sign in with Spotify.", message: "Clicking OK will take you to a sign in page for Spotify. You are required to sign in even if you're not the host, but you are not required to have a premium account.", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
//            alert.dismiss(animated: true, completion: {
//                self.navigationController?.popViewController(animated: true)
//            })
//        }))
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
//            let URLAuth = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
//            self.safariViewController = SFSafariViewController(url: URLAuth!)
//            self.safariViewController!.delegate = self
//            self.present(self.safariViewController!, animated: true, completion: nil)
//        }))
//       present(alert, animated: true, completion: nil)
//    }


//MARK: - Spotify Session
//    func createNewSpotifySession(){
//        if spotifyPlayer == nil {
//            do {
//                self.spotifyPlayer = SPTAudioStreamingController.sharedInstance()
//                self.spotifyPlayer!.playbackDelegate = self
//                try self.spotifyPlayer?.start(withClientId: SPTAuth.defaultInstance().clientID)
//                self.spotifyPlayer?.login(withAccessToken: SPTAuth.defaultInstance().session.accessToken)
//                self.spotifyPlayer?.setIsPlaying(false, callback: { (error) in
//
//                })
//            } catch let error {
//                print("Error whilst trying to log in handle new session: \(error.localizedDescription)")
//                //self.closeSpotifySession()
//            }
//        }
//    }
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

//extension PlayerViewController: SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
//    //If an error was formed from the server, display it to the user in an altert conroller
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
//        let alert = UIAlertController(title: "Message from Spotify", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    //Did switch between playing and not playing
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
////        if !isPlaying && songQueue.count == 1 && spotifyPlayer?.metadata.currentTrack != nil && !spotifyTappedPause {
////            spotifyDidFinish = true
////            Database.database().reference().child("parties").child(self.partyID).child("queue").child(String(self.playedSongs.count)).child("played").setValue(true)
////            self.playedSongs.append(self.songQueue[0])
////            self.songQueue.remove(at: 0)
////            self.tableView.reloadData()
////        }
////
////        if isPlaying {
////            playButton.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
////            self.activateAudioSession()
////        } else  {
////            playButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
////            self.deactivateAudioSession()
////        }
//    }
//
//    // If metadata changes then update the UI
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
////        if isQueueing {
////            isQueueing = false
////            return
////        }
////        if spotifyPlayer?.metadata.prevTrack != nil {
////            Database.database().reference().child("parties").child(partyID).child("queue").child(String(playedSongs.count)).child("played").setValue(true)
////            playedSongs.append(songQueue[0])
////            songQueue.remove(at: 0)
////            tableView.reloadData()
////        }
//    }
//
//    //If user did logout, close session
//    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
//        //self.closeSpotifySession()
//    }
//
//    //If recieve error, show error
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
//        print("Recieved error: \(error!)")
//        showError(title: "Error!", withMessage: "There was an error whilst trying to process your request: \(error!.localizedDescription)", fromController: self)
//    }
//
//    func queueSong(uri: String){
//        isQueueing = true
////        spotifyPlayer?.queueSpotifyURI(uri, callback: { (error) in
////            if error != nil {
////                showError(title: "Whoops!", withMessage: "Look's like there's a problem with your Spotify account. Remember, party hosts need to have a Spotify Premium subscription.", fromController: self)
////            }
////        })
//    }
//
//    // MARK: Activate audio session
//
//    func activateAudioSession() {
//        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//        try? AVAudioSession.sharedInstance().setActive(true)
//    }
//
//    // MARK: Deactivate audio session
//
//    func deactivateAudioSession() {
//        try? AVAudioSession.sharedInstance().setActive(false)
//    }
//}


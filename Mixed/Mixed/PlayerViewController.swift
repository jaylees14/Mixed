//
//  PlayerViewController.swift
//  Mixed
//
//  Created by Jay Lees on 16/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import StoreKit
import MediaPlayer
import SafariServices
import Firebase

class PlayerViewController: MixedViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addToQueueButton: UIButton!
    @IBOutlet weak var partyTitle: UILabel!
    @IBOutlet weak var partyTitleView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var codeText: UILabel!
    var partyID: String!
    var partyProvider: MusicProvider = MusicProvider.appleMusic
    var spotifyDidFinish = false
    var spotifyTappedPause = true
    var appleMusicPreviousItem: MPMediaItem? = nil
    var safariViewController: SFSafariViewController?
    
    let appleMusicPlayer = MPMusicPlayerController.systemMusicPlayer
    var spotifyPlayer: SPTAudioStreamingController?
    
    var songQueue = [Song]()
    var playedSongs = [Song]()
    
    var isQueueing = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPartyTitle()
        
        codeText.text = "Code: \(partyID!)"
        addToQueueButton.layer.cornerRadius = 35
        addToQueueButton.backgroundColor = UIColor.mixedRed
        addToQueueButton.layer.shadowOpacity = 0.5
        addToQueueButton.layer.shadowColor = UIColor.black.cgColor
        addToQueueButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        switch partyProvider {
        case .appleMusic: setupAppleMusic()
        case .spotify: setupSpotify()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(sessionSuccess), name: NSNotification.Name.init("spotifySessionUpdated"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        style(view: partyTitleView)
    }
    
    
    //MARK: - Provider setup
    func setupAppleMusic(){
        appleMusicPlayer.beginGeneratingPlaybackNotifications()
        appleMusicPlayer.repeatMode = .none
        appleMusicPlayer.shuffleMode = .off
        clearAppleMusicQueue()
        NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingStateChanged), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        setupDatabase()
    }
    
    func setupSpotify(){
        if let session = SPTAuth.defaultInstance().session {
            if session.isValid() {
                createNewSpotifySession()
                setupDatabase()
            } else {
                requestSpotifyAuth()
                return
            }
        } else {
            requestSpotifyAuth()
            return
        }
    }
    
    @objc func sessionSuccess(){
        safariViewController?.dismiss(animated: true, completion: nil)
        createNewSpotifySession()
        setupDatabase()
    }
    
    func requestSpotifyAuth(){
        let alert = UIAlertController(title: "You need to sign in with Spotify.", message: "Clicking OK will take you to a sign in page for Spotify. You are required to sign in even if you're not the host, but you are not required to have a premium account.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: { 
                self.navigationController?.popViewController(animated: true)
            })
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            let URLAuth = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
            self.safariViewController = SFSafariViewController(url: URLAuth!)
            self.safariViewController!.delegate = self
            self.present(self.safariViewController!, animated: true, completion: nil)
        }))
       present(alert, animated: true, completion: nil)
    }
    

    //MARK: - View and database setup
    func setupPartyTitle(){
        let _ = Database.database().reference().child("parties").child(partyID).child("hostName").observeSingleEvent(of: .value, with: { (snapshot) in
            if let hostName = snapshot.value as? String {
                let attributedText = NSMutableAttributedString(string: "\(hostName)'s Party", attributes: [:])
                attributedText.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: self.partyTitle.font.pointSize), range: NSRange(location: 0, length: hostName.characters.count + 2))
                self.partyTitle.attributedText = attributedText
            } else {
                self.partyTitle.text = "Party"
            }
        })
        
    }
    
    func setupDatabase(){
        Database.database().reference().child("parties").child(partyID).child("queue").observe(.childAdded , with: { (snapshot) in
            let data = snapshot.value as! [String:Any]
            let songURL = data["songURL"] as! String
            let artist = data["artistName"] as! String
            let songName = data["songName"] as! String
            let imageURL = data["imageURL"] as! String
            let imageWidth = data["imageWidth"] as! CGFloat
            let imageHeight = data["imageHeight"] as! CGFloat
            let addedBy = data["addedBy"] as! String
            let newSong = Song(artist: artist, songName: songName, songURL: songURL, imageURL: imageURL, imageSize: CGSize(width: imageWidth, height: imageHeight) , image: nil)
            newSong.addedBy = addedBy
            self.songQueue.append(newSong)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                if self.partyProvider == .appleMusic {
                    let newStoreID = self.songQueue[self.songQueue.count-1].songURL.components(separatedBy: "?i=")[1]
                    self.appleMusicPlayer.append(MPMusicPlayerStoreQueueDescriptor(storeIDs: [newStoreID]))
                } else {
                    self.queueSong(uri: newSong.songURL)
                }
            }
        })
    }
    

    //MARK: - Apple Music Player State
    @objc func nowPlayingStateChanged(){
        if songQueue.count == 1 && appleMusicPlayer.playbackState == .stopped {
            Database.database().reference().child("parties").child(partyID).child("queue").child(String(playedSongs.count)).child("played").setValue(true)
            playedSongs.append(songQueue[0])
            songQueue.remove(at: 0)
            clearAppleMusicQueue()
            tableView.reloadData()
            appleMusicPreviousItem = nil
        }
        
        //ICON Change
        if appleMusicPlayer.playbackState == .playing {
            playButton.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else if appleMusicPlayer.playbackState == .paused || appleMusicPlayer.playbackState == .stopped {
           playButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    
    @objc func nowPlayingChanged(){
        if songQueue.count == 0 {
            clearAppleMusicQueue()
            tableView.reloadData()
            appleMusicPreviousItem = nil
            return
        }
        
        if appleMusicPreviousItem == nil || appleMusicPreviousItem == appleMusicPlayer.nowPlayingItem {
            appleMusicPreviousItem = appleMusicPlayer.nowPlayingItem
            return
        }

        Database.database().reference().child("parties").child(partyID).child("queue").child(String(playedSongs.count)).child("played").setValue(true)
        
        let justPlayed = songQueue[0]
        playedSongs.append(justPlayed)
        songQueue.remove(at: 0)
        
        let remainingSongIDs = songQueue.map{$0.songURL.components(separatedBy: "?i=")[1]}
        appleMusicPlayer.setQueue(with: remainingSongIDs)
        
        tableView.reloadData()
        
    }
    
    func clearAppleMusicQueue(){
        let query = MPMediaQuery()
        let newPredicate = MPMediaPropertyPredicate(value: "NAME_WHERE_THIS_DOENST_EXIST", forProperty: MPMediaItemPropertyTitle)
        query.addFilterPredicate(newPredicate)
        appleMusicPlayer.setQueue(with: query)
        appleMusicPlayer.nowPlayingItem = nil
        appleMusicPlayer.stop()
    }
    
    
    //MARK: - Spotify Session
    func createNewSpotifySession(){
        if spotifyPlayer == nil {
            do {
                self.spotifyPlayer = SPTAudioStreamingController.sharedInstance()
                self.spotifyPlayer!.playbackDelegate = self
                try self.spotifyPlayer?.start(withClientId: SPTAuth.defaultInstance().clientID)
                self.spotifyPlayer?.login(withAccessToken: SPTAuth.defaultInstance().session.accessToken)
                self.spotifyPlayer?.setIsPlaying(false, callback: { (error) in
                    
                })
            } catch let error {
                print("Error whilst trying to log in handle new session: \(error.localizedDescription)")
                //self.closeSpotifySession()
            }
        }
    }
    
    func closeSpotifySession(){
        spotifyPlayer?.setIsPlaying(false, callback: { (_) in
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (_) in
                self.spotifyPlayer?.logout()
                
                do {
                 try self.spotifyPlayer?.stop()
                } catch let error {
                    print(error)
                }
                
                self.navigationController?.popViewController(animated: true)
            })
        })
    }
    
    
    //MARK: - Button Methods
    @IBAction func addToQueueTapped(_ sender: Any) {
        performSegue(withIdentifier: "toSearchFromPlayer", sender: self)
    }
    
    @IBAction func userDidTapPlay(_ sender: Any) {
        if partyProvider == .appleMusic {
            if appleMusicPlayer.playbackState == .playing {
                appleMusicPlayer.pause()
            } else {
                appleMusicPlayer.play()
            }
        } else {
            guard songQueue.count > 0 else { return }
            if spotifyPlayer?.playbackState != nil {
                if spotifyPlayer?.metadata.currentTrack == nil || spotifyDidFinish {
                    spotifyPlayer?.playSpotifyURI(songQueue[0].songURL, startingWith: 0, startingWithPosition: 0, callback: { (error) in
                        if let error = error {
                            print(error)
                        }
                    })
                    spotifyDidFinish = false
                }
                
                spotifyPlayer?.setIsPlaying(!(spotifyPlayer?.playbackState.isPlaying)!, callback: { (error) in
                    if let error = error {
                        print(error)
                    }
                })

                spotifyTappedPause = !spotifyTappedPause
                
            }
        }
    }
    
    @IBAction func userDidTapBack(_ sender: Any) {
        if partyProvider == .spotify {
            closeSpotifySession()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func userDidTapNext(_ sender: Any) {
        if partyProvider == .appleMusic {
            if songQueue.count == 1 {
                clearAppleMusicQueue()
                Database.database().reference().child("parties").child(partyID).child("queue").child(String(playedSongs.count)).child("played").setValue(true)
                playedSongs.append(songQueue[0])
                songQueue.remove(at: 0)
                tableView.reloadData()
            } else {
                appleMusicPlayer.skipToNextItem()
            }
        } else {
            spotifyPlayer?.skipNext({ (error) in
                if let error = error {
                    print(error)
                }
            })
            if self.songQueue.count == 1 {
                spotifyDidFinish = true
                Database.database().reference().child("parties").child(self.partyID).child("queue").child(String(self.playedSongs.count)).child("played").setValue(true)
                self.playedSongs.append(self.songQueue[0])
                self.songQueue.remove(at: 0)
                self.tableView.reloadData()
            }

        }
    }
    
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchFromPlayer" {
            if let dest = segue.destination as? SearchViewController {
                dest.partyID = partyID
                dest.currentProvider = partyProvider
                dest.fromQueue = false
            }
        }
    }
    
}

extension PlayerViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension PlayerViewController: UITableViewDataSource, UITableViewDelegate {
    //MARK: - TableView methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return songQueue.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "queueCell", for: indexPath)
        cell.layer.shadowColor = UIColor.hexToRGB(hex: "626262")!.cgColor
        cell.layer.shadowOpacity = 0.3
        cell.layer.shadowPath = CGPath(rect: CGRect(x: cell.bounds.origin.x + 10, y: cell.bounds.origin.y + 10, width: cell.bounds.width - 20, height: cell.bounds.height), transform: nil)
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = false
        cell.layer.masksToBounds = false
        
        let song = songQueue[indexPath.section]
        let songName = cell.viewWithTag(200) as! UILabel
        let artistName = cell.viewWithTag(201) as! UILabel
        let addedBy = cell.viewWithTag(202) as! UILabel
        let albumArtwork = cell.viewWithTag(203) as! UIImageView
        
        if indexPath.section == 0 {
            songName.textColor = .white
            artistName.textColor = .white
            addedBy.textColor = .white
            cell.backgroundColor = .mixedBlue
        } else {
            songName.textColor = .mixedBlue
            artistName.textColor = .mixedBlue
            addedBy.textColor = .mixedBlue
            cell.backgroundColor = .white
        }
        
        songName.text = song.songName
        artistName.text = song.artist
        
        addedBy.text = "Added by \(song.addedBy ?? "someone")"
        getImage(url: song.imageURL, size: song.imageSize, forImageView: albumArtwork)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension PlayerViewController: SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    //If an error was formed from the server, display it to the user in an altert conroller
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveMessage message: String) {
        let alert = UIAlertController(title: "Message from Spotify", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Did switch between playing and not playing
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChangePlaybackStatus isPlaying: Bool) {
        if !isPlaying && songQueue.count == 1 && spotifyPlayer?.metadata.currentTrack != nil && !spotifyTappedPause {
            spotifyDidFinish = true
            Database.database().reference().child("parties").child(self.partyID).child("queue").child(String(self.playedSongs.count)).child("played").setValue(true)
            self.playedSongs.append(self.songQueue[0])
            self.songQueue.remove(at: 0)
            self.tableView.reloadData()
        }
        
        if isPlaying {
            playButton.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.activateAudioSession()
        } else  {
            playButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.deactivateAudioSession()
        }
    }
    
    // If metadata changes then update the UI
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didChange metadata: SPTPlaybackMetadata) {
        if isQueueing {
            isQueueing = false
            return
        }
        if spotifyPlayer?.metadata.prevTrack != nil {
            Database.database().reference().child("parties").child(partyID).child("queue").child(String(playedSongs.count)).child("played").setValue(true)
            playedSongs.append(songQueue[0])
            songQueue.remove(at: 0)
            tableView.reloadData()
        }
    }
    
    //If user did logout, close session
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController) {
        self.closeSpotifySession()
    }
    
    //If recieve error, show error
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController, didReceiveError error: Error?) {
        print("Recieved error: \(error!)")
        showError(title: "Error!", withMessage: "There was an error whilst trying to process your request: \(error!.localizedDescription)", fromController: self)
    }
    
    func queueSong(uri: String){
        isQueueing = true
        spotifyPlayer?.queueSpotifyURI(uri, callback: { (error) in
            if error != nil {
                showError(title: "Whoops!", withMessage: "Look's like there's a problem with your Spotify account. Remember, party hosts need to have a Spotify Premium subscription.", fromController: self)
            }
        })
    }
    
    // MARK: Activate audio session
    
    func activateAudioSession() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    // MARK: Deactivate audio session
    
    func deactivateAudioSession() {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

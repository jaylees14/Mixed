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
    
    var musicPlayer: MusicPlayer!
    
    var songQueue = [Song]()
    var playedSongs = 0
    
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
        
        musicPlayer = MusicPlayerFactory.generatePlayer(for: partyProvider)
        musicPlayer.setDelegate(self)
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(sessionSuccess),
//                                               name: NSNotification.Name.init("spotifySessionUpdated"),
//                                               object: nil)
        observeDatabase()
    }
    
    override func viewDidLayoutSubviews() {
        style(view: partyTitleView)
    }
    
    
    
    

    //MARK: - View and database setup
    func setupPartyTitle(){
        let _ = Database.database().reference().child("parties").child(partyID).child("hostName").observeSingleEvent(of: .value, with: { (snapshot) in
            if let hostName = snapshot.value as? String {
                let attributedText = NSMutableAttributedString(string: "\(hostName)'s Party", attributes: [:])
                attributedText.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: self.partyTitle.font.pointSize), range: NSRange(location: 0, length: hostName.count + 2))
                self.partyTitle.attributedText = attributedText
            } else {
                self.partyTitle.text = "Party"
            }
        })
    }
    
    func observeDatabase(){
        Database.database().reference().child("parties").child(partyID).child("queue").observe(.childAdded , with: { (snapshot) in
            print("Child added")
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
                    let id = self.extractAppleMusicID(from: self.songQueue[self.songQueue.count-1].songURL)
                    self.musicPlayer.enqueue(song: id)
                  
                } else {
                    //self.queueSong(uri: newSong.songURL)
                }
            }
        })
    }
    
    func extractAppleMusicID(from url: String) -> String {
        return url.components(separatedBy: "?i=")[1]
    }

    
    //MARK: - Button Methods
    @IBAction func addToQueueTapped(_ sender: Any) {
        performSegue(withIdentifier: "toSearchFromPlayer", sender: self)
    }
    
    @IBAction func userDidTapPlay(_ sender: Any) {
        if musicPlayer.getCurrentStatus() == .playing {
            musicPlayer.pause()
        } else {
            musicPlayer.play()
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
    }
    
    @IBAction func userDidTapBack(_ sender: Any) {
        if partyProvider == .spotify {
            //closeSpotifySession()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func userDidTapNext(_ sender: Any) {
        musicPlayer.next()
        
        // If they next on last song, clear queue and reset view
        if songQueue.count <= 1 {
            removeTopSong()
            musicPlayer.clearQueue()
            songQueue = []
            tableView.reloadData()
        }
        
//            spotifyPlayer?.skipNext({ (error) in
//                if let error = error {
//                    print(error)
//                }
//            })
//            if self.songQueue.count == 1 {
//                spotifyDidFinish = true
//                Database.database().reference().child("parties").child(self.partyID).child("queue").child(String(self.playedSongs.count)).child("played").setValue(true)
//                self.playedSongs.append(self.songQueue[0])
//                self.songQueue.remove(at: 0)
//                self.tableView.reloadData()
//            }

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


extension PlayerViewController: PlayerDelegate {
    func playerDidStartPlaying(songID: String?) {
        guard let id = songID, !id.isEmpty else {
            return
        }
        
        if partyProvider == .appleMusic {
            if let currentURL = songQueue.first?.songURL {
                let topID = extractAppleMusicID(from: currentURL)
                if topID != id {
                    removeTopSong()
                }
            }
        }

    }
    
    func playerDidChange(to state: PlaybackStatus) {
        print("Did change to \(state)")
        switch state {
        case .playing:
            playButton.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
        default:
            playButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    
    private func removeTopSong(){
        Database.database().reference().child("parties").child(partyID).child("queue").child("\(playedSongs)").child("played").setValue(true)
        songQueue = Array(songQueue.dropFirst())
        playedSongs += 1
        tableView.reloadData()
    }
}

//
//  QueueViewController.swift
//  Mixed
//
//  Created by Jay Lees on 16/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import Firebase

class QueueViewController: MixedViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var partyTitle: UILabel!
    @IBOutlet weak var titleBackground: UIView!
    @IBOutlet weak var tableView: UITableView!
    var partyID: String!
    var songQueue = Queue<Song>()
    var partyProvider: MusicProvider = .appleMusic
    var playedSongs = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPartyTitle()
        observeNewSongs()
        observePlayComplete()
        style(view: titleBackground)
        
        plusButton.layer.cornerRadius = 35
        plusButton.backgroundColor = UIColor.mixedRed
        plusButton.layer.shadowOpacity = 0.5
        plusButton.layer.shadowColor = UIColor.black.cgColor
        plusButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        if partyProvider == .spotify {
            setupSpotify()
        }
        
    }
    
    
    func setupSpotify(){
        if let session = SPTAuth.defaultInstance().session {
            if !session.isValid() {
                requestSpotifyAuth()
            }
        } else {
            requestSpotifyAuth()
        }
    }
    
    func requestSpotifyAuth(){
        let URLAuth = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URLAuth!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URLAuth!)
        }
    }

    
    
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
    
    //MARK: - Observe database
    func observeNewSongs(){
        Database.database().reference().child("parties").child(partyID).child("queue").observe(.childAdded, with: { (snapshot) in
            let data = snapshot.value as! [String:Any]
            if data["played"] == nil {
                let songURL = data["songURL"] as! String
                let artist = data["artistName"] as! String
                let songName = data["songName"] as! String
                let imageURL = data["imageURL"] as! String
                let imageWidth = data["imageWidth"] as! CGFloat
                let imageHeight = data["imageHeight"] as! CGFloat
                let addedBy = data["addedBy"] as! String
                
                let newSong = Song(artist: artist, songName: songName, songURL: songURL, imageURL: imageURL, imageSize: CGSize(width: imageWidth, height: imageHeight) , image: nil)
                newSong.addedBy = addedBy
                self.songQueue.enqueue(newSong)
                self.tableView.reloadData()
            }
        })
    }
    

    func observePlayComplete(){
        Database.database().reference().child("parties").child(partyID).child("queue").observe(.childChanged, with: { (snapshot) in
            guard let justPlayed = self.songQueue.dequeue() else {
                return
            }
            self.playedSongs.append(justPlayed)
            self.tableView.reloadData()
        })
            
    }
    
    //MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return songQueue.size
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
        
        let song = songQueue.getAll()[indexPath.row]
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearchFromQueue" {
            if let dest = segue.destination as? SearchViewController {
                dest.partyID = partyID
                dest.currentProvider = partyProvider
                dest.fromQueue = true
            }
        }
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func userTappedAddNew(_ sender: Any) {
        self.performSegue(withIdentifier: "toSearchFromQueue", sender: self)
    }
}

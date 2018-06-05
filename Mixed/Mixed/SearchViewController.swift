//
//  ViewController.swift
//  Mixed
//
//  Created by Jay Lees on 13/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class SearchViewController: MixedViewController, AppleMusicDelegate, SpotifyDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var songsTableView: UITableView!
    @IBOutlet weak var searchText: UITextField!
    
    var songs = [Song]()
    var appleMusic: AppleMusic!
    var spotify: Spotify!
    var currentProvider: MusicProvider = .appleMusic
    var partyID: String!
    var loadingView: NVActivityIndicatorView!
    var fromQueue = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mixedBlue
        songsTableView.isHidden = true
        searchText.layer.cornerRadius = 10
        searchText.layer.borderWidth = 0
        
        if currentProvider == .appleMusic {
            appleMusic = AppleMusic(delegate: self)
        } else {
            spotify = Spotify(delegate: self)
        }
        
        searchText.delegate = self
    }
    
    //MARK: - Apple Music Delegate
    func queryDidReturn(_ songs: [Song]) {
        self.songs = songs
        
        for song in self.songs {
//            let formattedURL = song.imageURL.replacingOccurrences(of: "{w}", with: "\(Int(song.imageSize.width))").replacingOccurrences(of: "{h}", with: "\(Int(song.imageSize.height))")
            
//            do {
//                let data = try Data(contentsOf: URL(string: formattedURL)!)
//                song.image = UIImage(data: data)
//                DispatchQueue.main.async {
//                    self.songsTableView.reloadData()
//                }
//            } catch let error {
//                print(error)
//            }
            
        }
        
        hideLoadingView()
        songsTableView.reloadData()
    }
    
    func permissionDenied() {
        let alertView = UIAlertController(title: "Permission Denied", message: "Please allow us access to your Apple Music library in Settings.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Okay", style: .default)
        alertView.addAction(okButton)
        DispatchQueue.main.async {
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    func noSubscription() {
        guard !fromQueue else { return }
        let alertView = UIAlertController(title: "Apple Music Subscription Required", message: "Sorry, but in order to continue you require a paid Apple Music subscription.", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Okay", style: .default)
        alertView.addAction(okButton)
        DispatchQueue.main.async {
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    func appleMusicError(code: Int){
        showError(title: "Error", withMessage: "Code \(code): Error whilst trying to get data from Apple Music", fromController: self)
    }
    
    
    //MARK: - Spotify Delegate
    func spotifyQueryDidReturn(_ songs: [Song]) {
        self.songs = songs
        
        for song in self.songs {
            do {
                let data = try Data(contentsOf: URL(string: song.imageURL)!)
                song.image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.songsTableView.reloadData()
                }
            } catch let error {
                print(error)
            }
        }
        
        hideLoadingView()
        songsTableView.reloadData()
    }
    
    func spotifyError(code: Int){
        showError(title: "Error", withMessage: "Code \(code): Error whilst trying to get data from Spotify", fromController: self)
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        showLoadingView()
        switch currentProvider {
            case .appleMusic: appleMusic.makeSearchRequest(query: searchText.text!)
            case .spotify: spotify.makeSearchRequest(query: searchText.text!)
        }
        searchText.resignFirstResponder()
        return true
    }
    
    
    //MARK: TableView Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = songs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        cell.backgroundColor = .clear
        
        //Artwork
        let albumArt = cell.viewWithTag(300) as! UIImageView
        albumArt.image = song.image
        
        //Song name
        let titleLabel = cell.viewWithTag(301) as! UILabel
        titleLabel.text = song.songName
        
        let artistLabel = cell.viewWithTag(302) as! UILabel
        artistLabel.text = song.artist
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertView = UIAlertController(title: "Are you sure?", message: "Are you sure you want to add \(songs[indexPath.row].songName) to the party queue?", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alertView.dismiss(animated: true, completion: nil)
        }))
        
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.addSongToQueue(self.songs[indexPath.row])
            alertView.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }))
        present(alertView, animated: true, completion: nil)
    }
    
    //MARK: Loading View
    func showLoadingView(){
        songsTableView.isHidden = true
        loadingView = NVActivityIndicatorView(frame: CGRect(x: view.frame.width/2-40, y: view.frame.height/2-40, width: 80, height: 80), type: NVActivityIndicatorType.pacman, color: UIColor.white, padding: nil)
        loadingView.startAnimating()
        view.addSubview(loadingView)
        view.bringSubview(toFront: loadingView)
    }
    
    func hideLoadingView(){
        songsTableView.isHidden = false
        loadingView.removeFromSuperview()
    }
    
    
    //MARK: - Add to queue
    func addSongToQueue(_ song: Song){
        Database.database().reference().child("parties").child(partyID).child("queue").observeSingleEvent(of: .value, with: { (snapshot) in
            var username = ""
            if let user = Auth.auth().currentUser {
                if let splitNames = user.displayName?.components(separatedBy: " ") {
                    username = splitNames[0]
                }
            } else {
                username = UserDefaults.standard.string(forKey: "MixedUserName") ?? ""
            }
    
            let newSongInfo = ["songName": song.songName, "songURL": song.songURL, "imageURL": song.imageURL, "artistName": song.artist, "addedBy": username, "imageWidth": song.imageSize.width, "imageHeight": song.imageSize.height] as [String: Any]
            if let currentQueue = snapshot.value as? NSArray {
                Database.database().reference().child("parties").child(self.partyID).child("queue").child("\(currentQueue.count)").setValue(newSongInfo)
            } else {
                Database.database().reference().child("parties").child(self.partyID).child("queue").child("0").setValue(newSongInfo)
            }
        })
    }
    
    private func getDocumentsDirectory() -> URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    @IBAction func userTappedBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}


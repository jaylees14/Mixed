//
//  PartyPlayerViewController.swift
//  Mixed
//
//  Created by Jay Lees on 25/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit
import SafariServices

class PartyPlayerViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var discView: DiscView!
    @IBOutlet private weak var nowPlayingSong: UILabel!
    @IBOutlet private weak var nowPlayingArtist: UILabel!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var centerButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var upcomingTableView: UITableView!
    @IBOutlet private weak var centerButtonHeight: NSLayoutConstraint!
    
    fileprivate enum PlayerViewState {
        case full
        case condensed
    }
    
    public enum PlayerType {
        case host
        case attendee
    }
    
    // Set before segue to view
    public var playerType: PlayerType!
    public var partyID: String!
    
    private let imageDispatchQueue = DispatchQueue(label: "com.jaylees.mixed-imagedownload")
    private let datastore = Datastore.instance
    private var safariViewController: SFSafariViewController!
    private var party: Party?
    private var lastContentOffset: CGFloat = 0
    private var animator: UIViewPropertyAnimator?
    private var playerViewState: PlayerViewState!
    private var musicPlayer: MusicPlayer?
    private var songQueue = Queue<Song>()
    private var currentSong: Song? {
        didSet {
            nowPlayingSong.text = currentSong?.songName ?? "Nothing is playing ☹️"
            nowPlayingArtist.text = currentSong?.artist
            currentSong?.downloadImage(on: imageDispatchQueue, then: discView.updateArtwork)
        }
    }
    

    override func viewDidLoad() {
        nowPlayingSong.textColor = UIColor.mixedPrimaryBlue
        nowPlayingArtist.textColor = UIColor.mixedSecondaryBlue
        
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        upcomingTableView.dataSource = self
        upcomingTableView.delegate = self
        upcomingTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        upcomingTableView.isScrollEnabled = false
        playerViewState = .full
        
        // Note: Set delegate before joining so we can receive all added songs!
        datastore.delegate = self
        datastore.joinParty(with: partyID) { (party) in
            guard let party = party else {
                print("Unable to create party")
                //TODO: throw
                return
            }
        
            self.party = party
            self.setupNavigationBar(title: "\(party.partyHost)'s Party")
            self.musicPlayer = MusicPlayerFactory.generatePlayer(for: party.streamingProvider)
            self.musicPlayer?.setDelegate(self)
            self.musicPlayer?.validateSession()
            // We have to do this after we've created the player!
            self.datastore.subscribeToUpdates(for: party.partyID)
        }
        
        // Notification when Spotify sends callback
        let callback = { () in
            
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(spotifySessionUpdated),
                                               name: NSNotification.Name.init("spotifySessionUpdated"),
                                               object: nil)
        
        if playerType == .host {
            leftButton.setBackgroundImage(#imageLiteral(resourceName: "plus"), for: .normal)
            centerButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
            rightButton.setBackgroundImage(#imageLiteral(resourceName: "next"), for: .normal)
            leftButton.addTarget(self, action: #selector(toSearch), for: .touchUpInside)
            rightButton.addTarget(self, action: #selector(nextSong), for: .touchUpInside)
            centerButton.addTarget(self, action: #selector(playSong), for: .touchUpInside)
        } else {
            leftButton.isHidden = true
            rightButton.isHidden = true
            centerButton.setBackgroundImage(#imageLiteral(resourceName: "plus"), for: .normal)
            centerButtonHeight.constant = 45
            centerButton.addTarget(self, action: #selector(toSearch), for: .touchUpInside)
        }
        [leftButton, centerButton, rightButton].forEach({$0?.backgroundColor = .clear})
        
        
        navigationController?.navigationBar.items?.first?.leftBarButtonItem =
            UIBarButtonItem(title: "X", style: .plain, target: self, action: #selector(didTapClose))
        navigationController?.navigationBar.items?.first?.rightBarButtonItem =
            UIBarButtonItem(title: "QR", style: .plain, target: self, action: #selector(didTapQR))
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        // Fix a bug where the disc view would be correctly sized on first load
        discView.resize(to: discView.frame)
        discView.startRotating()
        
        animator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) {
            self.upcomingTableView.frame.origin = CGPoint(x: 0, y: 440)
            self.discView.resize(to: CGRect(x: 32, y: 275, width: 50, height: 50))
            self.nowPlayingSong.frame.origin = CGPoint(x: 82 + 28, y: 275)
            self.nowPlayingArtist.frame.origin = CGPoint(x: 82 + 28, y: self.nowPlayingSong.frame.height + 275 + 8)
            self.leftButton.frame.origin.y = 365
            self.rightButton.frame.origin.y = 365
            self.centerButton.frame.origin.y = 350
        }
    }
    
    
    // MARK: - Button actions
    @objc private func toSearch(){
        self.performSegue(withIdentifier: "toSearch", sender: self)
    }
    
    @objc private func playSong() {
        if musicPlayer?.getCurrentStatus() == .playing {
            musicPlayer?.pause()
        } else {
            musicPlayer?.play()
        }
    }
    
    @objc private func nextSong() {
        musicPlayer?.next()
    }
    
    @objc private func didTapQR(){
        self.performSegue(withIdentifier: "toShowCode", sender: self)
    }
    
    @objc private func didTapClose(){
        let title = "Close the party"
        var message = "Are you sure you want to quit? "
        if playerType == .host {
            message += "As the host, leaving now will close the party and all of the queued songs will be lost."
        } else {
            message += "Leaving now will mean you'll have to request to join the party again in order to add songs."
        }
        askQuestion(title: title, message: message, controller: self, acceptCompletion: {
            self.dismiss(animated: true, completion: nil)
        }, cancelCompletion: nil)
    }
    
    // MARK: - Spotify Callback
    @objc private func spotifySessionUpdated(){
        safariViewController.dismiss(animated: true, completion: nil)
        musicPlayer?.validateSession()
    }
    
    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSearch" {
            guard let destination = segue.destination as? SongSearchViewController else {
                fatalError("Invalid segue")
            }
            
            guard let party = party else {
                //TODO: Throw
                return
            }
            destination.party = party
        } else if segue.identifier == "toShowCode"{
            guard let destination = segue.destination as? PartyCodeViewController else {
                fatalError("Invalid segue")
            }
            guard let party = party else {
                //TODO: Throw
                return
            }
            destination.party = party
        }
    }
}

// MARK: - Table View Delegate & Data Source
extension PartyPlayerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songQueue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongTableViewCell
        let song = songQueue[indexPath.row]
        cell.title.text = song.songName
        cell.subtitle.text = "\(song.artist) - Added by \(song.addedBy ?? "someone")."
        cell.albumArtwork.image = song.image
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100))
        
        let title = UILabel(frame: CGRect(x: 32, y: 15, width: tableView.frame.width, height: 20))
        title.text = "👇  Up Next"
        title.font = UIFont.mixedFont(size: 18)
        view.addSubview(title)
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.lightGray.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -5)
        view.layer.shadowOpacity = 0.3
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("woo")
        }
    }
}

// MARK: - UIScrollViewDelegate
extension PartyPlayerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxY: CGFloat = 250.0
        if scrollView.contentOffset.y < maxY {
            animator?.fractionComplete = scrollView.contentOffset.y / maxY
        }
    }
}

extension PartyPlayerViewController: PlayerDelegate {
    func playerDidStartPlaying(songID: String?) {
        if songID == currentSong?.songURL {
            return
        }
        
        currentSong = songQueue.dequeue()
        if currentSong?.songURL != songID {
            print("Huston, we have a problem! \(songID)")
        }
        
        upcomingTableView.reloadData()
    }
    
    func playerDidChange(to state: PlaybackStatus) {
        if state == .playing {
            discView.startRotating()
        } else {
            discView.stopRotating()
        }
    }
    
    func requestAuth(to url: URL) {
        safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    func didReceiveError(_ error: Error) {
        print(error)
    }
}

extension PartyPlayerViewController: DatastoreDelegate {
    func didAddSong(_ song: Song) {
        musicPlayer?.enqueue(song: song)
        if currentSong == nil {
            currentSong = song
        } else {
            songQueue.enqueue(song)
            song.downloadImage(on: imageDispatchQueue, then: { _ in self.upcomingTableView.reloadData() })
        }
    }
    
    func topSongDidChange(to song: Song) {

    }
}

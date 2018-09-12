//
//  PartyPlayerViewController.swift
//  Mixed
//
//  Created by Jay Lees on 25/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit
import SafariServices
import AVKit

public enum PlayerType: Int {
    case host = 0
    case attendee = 1
}

class PartyPlayerViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var discBackgroundView: UIView!
    @IBOutlet private weak var nowPlayingSong: UILabel!
    @IBOutlet private weak var nowPlayingArtist: UILabel!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var centerButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var outputSelector: UIView!
    @IBOutlet private weak var authenticateButton: OnboardingButton!
    @IBOutlet private weak var upcomingTableView: UITableView!
    @IBOutlet private weak var centerButtonHeight: NSLayoutConstraint!
    @IBOutlet private weak var tableViewHeight: NSLayoutConstraint!
    
    // Set before segue to view
    public var playerType: PlayerType!
    public var partyID: String!
    
    private var tableViewMinHeight: CGFloat = 0.0
    private var discView: DiscView?
    private let imageDispatchQueue = DispatchQueue(label: "com.jaylees.mixed-imagedownload")
    private let datastore = Datastore.instance
    private var safariViewController: SFSafariViewController?
    private var party: Party?
    private var lastContentOffset: CGFloat = 0
    private var musicPlayer: MusicPlayer?
    private var songQueue: Queue<Song>!
    private var songsPlayed = 0
    private var animator: UIViewPropertyAnimator!
    private var currentSong: Song? {
        didSet {
            nowPlayingSong.text = currentSong?.songName ?? "Nothing is playing ☹️"
            nowPlayingArtist.text = currentSong?.artist ?? "Add some songs below!"
            if let song = currentSong {
                song.downloadImage(on: imageDispatchQueue, then: discView?.updateArtwork ?? nil)
            } else {
                discView?.updateArtwork(image: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        discBackgroundView.backgroundColor = .clear
        songQueue = Queue()
        nowPlayingSong.textColor = UIColor.mixedPrimaryBlue
        nowPlayingArtist.textColor = UIColor.mixedSecondaryBlue
        
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        upcomingTableView.dataSource = self
        upcomingTableView.delegate = self
        upcomingTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        upcomingTableView.isScrollEnabled = false
    
        currentSong = nil
        tableViewMinHeight = tableViewHeight.constant
        setTableViewHeight()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(spotifySessionUpdated),
                                               name: NSNotification.Name.init("spotifySessionUpdated"),
                                               object: nil)
        
        let volumeView = AVRoutePickerView(frame: CGRect(origin: .zero, size: outputSelector.frame.size))
        outputSelector.addSubview(volumeView)
        
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
            outputSelector.isHidden = true
            centerButton.setBackgroundImage(#imageLiteral(resourceName: "plus"), for: .normal)
            centerButtonHeight.constant = 45
            centerButton.addTarget(self, action: #selector(toSearch), for: .touchUpInside)
        }
        [leftButton, centerButton, rightButton, outputSelector].forEach({$0?.backgroundColor = .clear})
        
        authenticateButton.isHidden = true
        authenticateButton.addTarget(self, action: #selector(didTapAuth), for: .touchUpInside)
        authenticateButton.setTitleColor(.black, for: .normal)
        authenticateButton.layer.borderColor = UIColor.black.cgColor
        
        navigationController?.navigationBar.tintColor = .black
        let resized = UIImage(named: "back")?.resize(to: CGSize(width: 13, height: 22))
        let resizedQR = UIImage(named: "qrcode")?.resize(to: CGSize(width: 20, height: 20))
        
        navigationController?.navigationBar.items?.first?.leftBarButtonItem =
            UIBarButtonItem(image: resized, style: .plain, target: self, action: #selector(didTapClose))
        navigationController?.navigationBar.items?.first?.rightBarButtonItem =
            UIBarButtonItem(image: resizedQR, style: .plain, target: self, action: #selector(didTapQR))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if discView == nil {
            discView = DiscView(frame: CGRect(origin: .zero, size: discBackgroundView.frame.size))
            discBackgroundView.addSubview(discView!)
        }
        
        if party == nil {
            // Set delegate before joining so we can receive all added songs
            datastore.delegate = self
            datastore.joinParty(with: partyID) { (party) in
                guard let party = party else {
                    //TODO: throw
                    return
                }
                self.party = party
                self.setupNavigationBar(title: "\(party.partyHost)'s Party")
                self.musicPlayer = MusicPlayerFactory.generatePlayer(for: party.streamingProvider)
                self.musicPlayer?.setDelegate(self)
                self.musicPlayer?.validateSession(for: self.playerType)
            }
        }
        // Fix a bug where the disc view would be correctly sized on first load
        if currentSong == nil && discView != nil {
            discView!.resize(to: discView!.frame)
            discView!.updateArtwork(image: nil)
        } else if playerType == .attendee || musicPlayer?.getCurrentStatus() == .playing {
            discView?.startRotating()
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
            if self.musicPlayer?.hasValidSession() ?? false {
                // FIXME: This will not let you exit if nothing is playing :(
                 self.musicPlayer?.stop()
            }
            self.datastore.unsubscribeFromUpdates()
            SessionManager.shared.clearActiveSession()
            self.dismiss(animated: true, completion: nil)
        }, cancelCompletion: nil)
    }
    
    @objc private func didTapAuth(){
        self.musicPlayer?.validateSession(for: playerType)
    }
    
    // MARK: - Spotify Callback
    @objc private func spotifySessionUpdated(){
        DispatchQueue.main.async {
            self.safariViewController?.dismiss(animated: true, completion: nil)
            if self.playerType == .host {
                [self.leftButton, self.centerButton, self.rightButton, self.outputSelector].forEach({ (button) in
                    button?.isHidden = false
                })
            } else {
                self.centerButton.isHidden = false
            }
            self.authenticateButton.isHidden = true
            self.musicPlayer?.validateSession(for: self.playerType)
        }
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
    
    //MARK: - UI
    func setTableViewHeight() {
        if tableViewMinHeight <= CGFloat((songQueue.count + 1) * 60) {
            tableViewHeight.constant = CGFloat((songQueue.count + 1) * 60)
        } else {
            tableViewHeight.constant = tableViewMinHeight
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
        cell.subtitle.text = "\(song.artist) - Added by \(song.addedBy ?? "someone")"
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UIScrollViewDelegate
extension PartyPlayerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //TODO: Support in a later release
        let maxY: CGFloat = 250.0
        if scrollView.contentOffset.y < maxY {
            //animator.fractionComplete = scrollView.contentOffset.y / maxY
        }
    }
}

extension PartyPlayerViewController: PlayerDelegate {
    func playerDidStartPlaying(songID: String?) {
        guard let party = party else { return }
        if songID == currentSong?.songURL || songID == "" {
            return
        }
        
        datastore.didFinish(song: songsPlayed, party: party.partyID)
        songsPlayed += 1
        currentSong = songQueue.dequeue()
        if currentSong == nil {
            discView?.updateArtwork(image: nil)
            musicPlayer?.clearQueue()
        }
        
        upcomingTableView.reloadData()
    }
    
    func playerDidChange(to state: PlaybackStatus) {
        if state == .playing {
            discView?.startRotating()
        } else {
            discView?.stopRotating()
        }
        
        if playerType == .host {
            centerButton.setBackgroundImage(state == .playing ? UIImage(named: "pause") : UIImage(named: "play"), for: .normal)
        }
    }
    
    func requestAuth(to url: URL) {
        safariViewController = SFSafariViewController(url: url)
        safariViewController?.delegate = self
        DispatchQueue.main.async {
            self.present(self.safariViewController!, animated: true, completion: nil)
        }
    }
    
    // When we have a valid session, we can enqueue songs!
    func hasValidSession() {
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                self.datastore.subscribeToUpdates(for: self.party!.partyID)
            }
        }
    }
    
    func didReceiveError(_ error: Error) {
        func hidePlayerShowAuth(){
            [self.leftButton, self.centerButton, self.rightButton, self.outputSelector].forEach({ (button) in
                button?.isHidden = true
            })
            self.authenticateButton.isHidden = false
        }
        
        switch error {
        case AppleMusicPlayerError.noSubscription, AppleMusicPlayerError.notSignedIn:
            showError(title: "Not able to use Apple Music.", message: "Please ensure you have a valid Apple Music subscription and Mixed is allowed access to your music library in settings.", controller: self, completion: hidePlayerShowAuth)
        case SpotifyPlayerError.invalidSignIn:
        showError(title: "Unable to sign in to Spotify", message: "Please try logging in with Spotify again.", controller: self, completion: hidePlayerShowAuth)
        case SpotifyPlayerError.noSubscription:
            // Should extract this away
            showError(title: "Premium subscription required", message: "You must have a premium Spotify account in order to be a party host.", controller: self, completion: {
                hidePlayerShowAuth()
                self.requestAuth(to: SPTAuth.defaultInstance().spotifyWebAuthenticationURL())
            })
        default:
            Logger.log(error, type: .error)
            showError(title: "Whoops", message: "Looks like we encountered an error. Please try again.", controller: self)
        }
    }
}

extension PartyPlayerViewController: DatastoreDelegate {
    func duplicateSongAdded(_ song: Song) {
        showError(title: "Whoops.", message: "Looks like that song is already queued. Please try again.", controller: self)
    }
    
    func didAddSong(_ song: Song) {
        Logger.log("Did add \(song.songName)", type: .debug)
        guard !song.played else { return }
        if currentSong == nil {
            currentSong = song
        } else {
            songQueue.enqueue(song)
        }
        if playerType == .host {
            musicPlayer?.enqueue(song: song)
        }
        song.downloadImage(on: imageDispatchQueue, then: { _ in self.upcomingTableView.reloadData() })
    }
    
    func queueDidChange(songs: [Song]) {
        Logger.log("Did change to \(songs)", type: .debug)
        self.songQueue.clear()
        let toPlay = songs.filter({!$0.played})
        
        if currentSong?.songURL != toPlay.first?.songURL {
            currentSong = toPlay.first
        }
        
        toPlay.forEach({
            $0.downloadImage(on: imageDispatchQueue, then: { _ in self.upcomingTableView.reloadData()})
        })
        self.songQueue.setTo(Array(toPlay.dropFirst()))
        setTableViewHeight()
    }
}

extension PartyPlayerViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        guard let musicPlayer = musicPlayer else { return }
        if !musicPlayer.hasValidSession(){
            DispatchQueue.main.async {
                showError(title: "Authentication Error", message: "You are required to sign in to use Spotify, even if you're a party guest.", controller: self)
                [self.leftButton, self.centerButton, self.rightButton].forEach({ (button) in
                    button?.isHidden = true
                })
                self.authenticateButton.isHidden = false
            }
        }
    }
}

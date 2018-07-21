//
//  PartyPlayerViewController.swift
//  Mixed
//
//  Created by Jay Lees on 25/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit



class PartyPlayerViewController: UIViewController {
    fileprivate enum PlayerViewState {
        case full
        case condensed
    }
    
    fileprivate enum PlayerType {
        case host
        case attendee
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var discView: DiscView!
    @IBOutlet weak var nowPlayingSong: UILabel!
    @IBOutlet weak var nowPlayingArtist: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var upcomingTableView: UITableView!
    @IBOutlet weak var centerButtonHeight: NSLayoutConstraint!
    
    private var lastContentOffset: CGFloat = 0
    private var forwardAnimator: UIViewPropertyAnimator?
    private var backwardAnimator: UIViewPropertyAnimator?
    private var playerType: PlayerType = .host
    private var playerViewState: PlayerViewState!

    override func viewDidLoad() {
        nowPlayingSong.text = "A very long song name by someone"
        nowPlayingArtist.text = "Another very long artist name"

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
        
        if playerType == .host {
            leftButton.setBackgroundImage(#imageLiteral(resourceName: "plus"), for: .normal)
            centerButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
            rightButton.setBackgroundImage(#imageLiteral(resourceName: "next"), for: .normal)
            leftButton.addTarget(self, action: #selector(toSearch), for: .touchUpInside)
        } else {
            leftButton.isHidden = true
            rightButton.isHidden = true
            centerButton.setBackgroundImage(#imageLiteral(resourceName: "plus"), for: .normal)
            centerButtonHeight.constant = 45
            centerButton.addTarget(self, action: #selector(toSearch), for: .touchUpInside)
        }
        [leftButton, centerButton, rightButton].forEach({$0?.backgroundColor = .clear})
        setupNavigationBar(title: "Jay's Party")
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        // Fix a bug where the disc view would be correctly sized on first load
        discView.resize(to: discView.frame)
        discView.startRotating()
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
            self.discView.updateArtwork(image: #imageLiteral(resourceName: "gradient"))
        }
        forwardAnimator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) {
            self.upcomingTableView.frame.origin = CGPoint(x: 0, y: 340)
            self.discView.resize(to: CGRect(x: 32, y: 175, width: 50, height: 50))
            self.nowPlayingSong.frame.origin = CGPoint(x: 82 + 28, y: 175)
            self.nowPlayingArtist.frame.origin = CGPoint(x: 82 + 28, y: self.nowPlayingSong.frame.height + 175 + 8)
            self.leftButton.frame.origin.y = 265
            self.rightButton.frame.origin.y = 265
            self.centerButton.frame.origin.y = 250
        }
    }
    
    
    // MARK: - Button actions
    @objc func toSearch(){
        self.performSegue(withIdentifier: "toSearch", sender: self)
    }
}

// MARK: - Table View Delegate & Data Source
extension PartyPlayerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongTableViewCell
        cell.title.text = "Song title"
        cell.subtitle.text = "Greg James - Added by Jay"
        cell.albumArtwork.image = #imageLiteral(resourceName: "gradient")
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
}

extension PartyPlayerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let maxY: CGFloat = 150.0
        if scrollView.contentOffset.y >= maxY {
            //scrollView.contentOffset.y = maxY
        } else {
            forwardAnimator?.fractionComplete = scrollView.contentOffset.y / maxY
        }
    }
}

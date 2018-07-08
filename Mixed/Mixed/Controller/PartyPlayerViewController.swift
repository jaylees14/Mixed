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
    
    @IBOutlet weak var discView: DiscView!
    @IBOutlet weak var partyTitle: UILabel!
    @IBOutlet weak var nowPlayingSong: UILabel!
    @IBOutlet weak var nowPlayingArtist: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var upcomingTableView: UITableView!
    @IBOutlet weak var tableViewToTop: NSLayoutConstraint!
    
    private var lastContentOffset: CGFloat = 0
    private var forwardAnimator: UIViewPropertyAnimator?
    private var backwardAnimator: UIViewPropertyAnimator?
    private var playerType: PlayerType = .host
    private var playerViewState: PlayerViewState! {
        didSet {
            upcomingTableView.isScrollEnabled = playerViewState == .condensed
        }
    }

    override func viewDidLoad() {
        partyTitle.text = "Really long name's Party"
        nowPlayingSong.text = "A very long song name by someone"
        nowPlayingArtist.text = "Another very long artist name"
        
        partyTitle.textColor = UIColor.mixedPrimaryBlue
        nowPlayingSong.textColor = UIColor.mixedPrimaryBlue
        nowPlayingArtist.textColor = UIColor.mixedSecondaryBlue
        
        upcomingTableView.dataSource = self
        upcomingTableView.delegate = self
        upcomingTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        playerViewState = .full
        
        if playerType == .host {
            leftButton.setBackgroundImage(#imageLiteral(resourceName: "plus"), for: .normal)
            centerButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
            rightButton.setBackgroundImage(#imageLiteral(resourceName: "next"), for: .normal)
            [leftButton, centerButton, rightButton].forEach({$0?.backgroundColor = .clear})
        }
        

        let panGestureRecogniser = UIPanGestureRecognizer(target: self, action: #selector(userDidSwipe))
        self.view.addGestureRecognizer(panGestureRecogniser)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Fix a bug where the disc view would be correctly sized on first load
        discView.resize(to: discView.frame)
        discView.startRotating()
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (_) in
            self.discView.updateArtwork(image: #imageLiteral(resourceName: "gradient"))
        }
    }
}

// MARK: - Pan Gesture Recogniser
extension PartyPlayerViewController {
    
    @objc func userDidSwipe(sender: UIPanGestureRecognizer){
        let minSwipeDistance = 50.0
        let minToComplete = 200.0
    
        let translation = sender.translation(in: self.view)
        let verticalPan = Double(translation.y)
        let percentageComplete = CGFloat((abs(verticalPan) - minSwipeDistance) / minToComplete) // convert the amount of "swipe" to a percentage
        
        switch sender.state {
        case .began:
            if playerViewState == .full {
                forwardAnimator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) {
                    self.upcomingTableView.frame.origin = CGPoint(x: 0, y: 300)
                    self.upcomingTableView.frame.size = CGSize(width: self.upcomingTableView.frame.width, height: self.view.frame.height - 300)
                    self.discView.resize(to: CGRect(x: 32, y: 125, width: 50, height: 50))
                    self.nowPlayingSong.frame.origin = CGPoint(x: 82 + 28, y: 125)
                    self.nowPlayingArtist.frame.origin = CGPoint(x: 82 + 28, y: self.nowPlayingSong.frame.height + 125 + 8)
                    self.leftButton.frame.origin.y = 225
                    self.rightButton.frame.origin.y = 225
                    self.centerButton.frame.origin.y = 215
                }
                forwardAnimator?.addCompletion({ _ in
                    self.playerViewState = .condensed
                })
                forwardAnimator?.isUserInteractionEnabled = true
            } else {
                backwardAnimator = UIViewPropertyAnimator(duration: 1, curve: .easeInOut) {
                    let viewHeight = self.view.frame.height
                    let viewCenterX = self.view.center.x
                    let safeAreaTop: CGFloat = self.view.safeAreaInsets.top
                
                    self.upcomingTableView.frame.origin = CGPoint(x: 0, y: 550 + safeAreaTop)
                    self.upcomingTableView.frame.size = CGSize(width: self.upcomingTableView.frame.width, height: self.view.frame.height - (550 + safeAreaTop))
                    self.discView.resize(to: CGRect(x: viewCenterX - ((viewHeight * 0.25) / 2) , y: 80 + safeAreaTop, width: viewHeight * 0.25, height: viewHeight * 0.25 ))
                    self.nowPlayingSong.frame.origin = CGPoint(x: viewCenterX - (self.nowPlayingSong.frame.width / 2), y: self.discView.frame.maxY + 32)
                    self.nowPlayingArtist.frame.origin = CGPoint(x:viewCenterX - (self.nowPlayingArtist.frame.width / 2), y: self.nowPlayingSong.frame.maxY + 8)
                    self.leftButton.frame.origin.y = self.nowPlayingArtist.frame.maxY + 50
                    self.rightButton.frame.origin.y = self.nowPlayingArtist.frame.maxY + 50
                    self.centerButton.frame.origin.y = self.nowPlayingArtist.frame.maxY + 40
                }
                backwardAnimator?.addCompletion({ _ in
                    self.playerViewState = .full
                })
                backwardAnimator?.isUserInteractionEnabled = true
            }
        case .changed:
            // Vertical pan is -ve when swiping up, +ve when swiping down
            let dampeningFactor: CGFloat = 0.5
            
            if verticalPan < 0 && verticalPan <= -minSwipeDistance && playerViewState == .full {
                forwardAnimator?.fractionComplete = percentageComplete * dampeningFactor
            } else if verticalPan > 0 && verticalPan >= minSwipeDistance && playerViewState == .condensed {
                backwardAnimator?.fractionComplete = percentageComplete * dampeningFactor
            }
        case .ended, .cancelled:
            if playerViewState == .full {
                forwardAnimator?.startAnimation()
            } else if playerViewState == .condensed {
                backwardAnimator?.startAnimation()
            }
        default:
            break
        }
    }
}

// MARK: - Table View Delegate & Data Source
extension PartyPlayerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
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

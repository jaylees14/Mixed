//
//  PartyPlayerViewController.swift
//  Mixed
//
//  Created by Jay Lees on 25/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class PartyPlayerViewController: UIViewController {

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
    private var animator: UIViewPropertyAnimator?
    
    override func viewDidLoad() {
        partyTitle.text = "Really long name's Party"
        nowPlayingSong.text = "A very long song name by someone"
        nowPlayingArtist.text = "Another very long artist name"
        
        partyTitle.textColor = UIColor.mixedPrimaryBlue
        nowPlayingSong.textColor = UIColor.mixedPrimaryBlue
        nowPlayingArtist.textColor = UIColor.mixedSecondaryBlue
        
        upcomingTableView.dataSource = self
        upcomingTableView.delegate = self
        upcomingTableView.layer.shadowOffset = CGSize(width: 0, height: -5)
        upcomingTableView.layer.shadowColor = UIColor.gray.cgColor
        upcomingTableView.layer.shadowOpacity = 0.3
        upcomingTableView.clipsToBounds = false
        
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
            self.upcomingTableView.frame.origin = CGPoint(x: 0, y: 300)
            self.upcomingTableView.frame.size = CGSize(width: self.upcomingTableView.frame.width, height: self.view.frame.height - 300)
            self.discView.resize(to: CGRect(x: 32, y: 125, width: 50, height: 50))
            self.nowPlayingSong.frame.origin = CGPoint(x: 82 + 28, y: 125)
            self.nowPlayingArtist.frame.origin = CGPoint(x: 82 + 28, y: self.nowPlayingSong.frame.height + 125 + 8)
            self.leftButton.frame.origin.y = 225
            self.rightButton.frame.origin.y = 225
            self.centerButton.frame.origin.y = 215
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        discView.startRotating()
        
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (_) in
            self.discView.updateArtwork(image: #imageLiteral(resourceName: "gradient"))
        }
    }
}

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
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.lastContentOffset < scrollView.contentOffset.y {
            animator?.isReversed = false
        
            
        } else if self.lastContentOffset > scrollView.contentOffset.y {
            animator?.isReversed = true
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        animator?.startAnimation()
    }

}

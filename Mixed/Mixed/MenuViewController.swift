//
//  MenuViewController.swift
//  Mixed
//
//  Created by Jay Lees on 15/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import Firebase
import FacebookCore

class MenuViewController: MixedViewController {

    @IBOutlet weak var startPartyButton: UIButton!
    @IBOutlet weak var joinPartyButton: UIButton!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.layer.borderWidth = 4
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.clipsToBounds = true
        
        nameLabel.text = Auth.auth().currentUser?.displayName
        
        style(button: startPartyButton, fontSize: 36)
        style(button: joinPartyButton, fontSize: 36)
        getImageFromFacebook()
        getAppleMusicToken()
        style(view: titleView)
        
        guard hasNetworkConnection() else {
            showError(title: "No Network Connection", withMessage: "In order to use this app fully you need a valid internet connection. Please check your settings and try again", fromController: self)
            return
        }
        
        let startParty = UIApplicationShortcutItem(type: "com.jaylees.mixed.startParty", localizedTitle: "Start a Party", localizedSubtitle: nil, icon: nil, userInfo: nil)
        let joinParty = UIApplicationShortcutItem(type: "com.jaylees.mixed.joinParty", localizedTitle: "Join a Party", localizedSubtitle: nil, icon: nil, userInfo: nil)
        UIApplication.shared.shortcutItems = [startParty, joinParty]

    }
    
    func getImageFromFacebook(){
        guard let user = Auth.auth().currentUser else { return }
        
        if let photo = getFromCache(name: user.uid){
            profileImageView.image = photo
        } else if let photoURL = user.photoURL {
            URLSession.shared.dataTask(with: photoURL, completionHandler: { (data, response, error) in
                guard error == nil else { return }
                DispatchQueue.main.async {
                    guard let data = data else { return }
                    guard let image = UIImage(data: data) else { return }
                    self.profileImageView.image = image
                    cacheImage(image: image, name: user.uid)
                }
            }).resume()
        }
    }
    
    func getAppleMusicToken(){
        Database.database().reference().child("appleMusic").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotVal = snapshot.value as? [String: String]{
                let token = snapshotVal["token"]
                UserDefaults.standard.setValue(token, forKey: "AMTOKEN")
            }
        })
    }
    
    //MARK: - Button Methods
    @IBAction func newPartyTapped(_ sender: Any) {
        //TODO: Add in animation
        performSegue(withIdentifier: "toNew", sender: nil)
    }
    
    @IBAction func joinPartyTapped(_ sender: Any) {
        //TODO: Add in animation
        performSegue(withIdentifier: "toExisting", sender: nil)
    }

}

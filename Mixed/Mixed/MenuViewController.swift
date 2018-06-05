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
    @IBOutlet weak var nameLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = Auth.auth().currentUser {
            nameLabel.text = user.displayName
        } else {
            let name = UserDefaults.standard.string(forKey: "MixedUserName")
            nameLabel.text = name
        }
        
        
        style(button: startPartyButton, fontSize: 36)
        style(button: joinPartyButton, fontSize: 36)
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

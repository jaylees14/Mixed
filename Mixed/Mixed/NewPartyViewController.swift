//
//  NewPartyViewController.swift
//  Mixed
//
//  Created by Jay Lees on 16/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import Firebase

class NewPartyViewController: MixedViewController {

    @IBOutlet weak var appleMusicButton: UIButton!
    @IBOutlet weak var spotifyButton: UIButton!
    @IBOutlet weak var titleBackground: UIView!
    var provider: MusicProvider!
    
    var ref = Database.database().reference()
    let partyID = randomString(length: 6)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style(button: appleMusicButton, fontSize: 36)
        style(button: spotifyButton, fontSize: 36)
        style(view: titleBackground)
    }
    
       
    @IBAction func appleMusicTapped(_ sender: Any) {
        let standardRef = ref.child("parties").child(partyID)
        standardRef.child("partyType").setValue("AppleMusic")
        standardRef.child("creationDate").setValue(getCurrentDate())
        standardRef.child("hostName").setValue(Auth.auth().currentUser?.displayName?.components(separatedBy: " ")[0])
        provider = MusicProvider.appleMusic
        performSegue(withIdentifier: "toPlayer", sender: self)
    }
    
    @IBAction func spotifyTapped(_ sender: Any) {
        let standardRef = ref.child("parties").child(partyID)
        standardRef.child("partyType").setValue("Spotify")
        standardRef.child("creationDate").setValue(getCurrentDate())
        standardRef.child("hostName").setValue(Auth.auth().currentUser?.displayName?.components(separatedBy: " ")[0])
        provider = MusicProvider.spotify
        performSegue(withIdentifier: "toPlayer", sender: self)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! PlayerViewController
        dest.partyID = partyID
        dest.partyProvider = provider
    }

}

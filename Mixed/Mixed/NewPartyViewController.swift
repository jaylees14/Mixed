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
    var username: String!
    
    var ref = Database.database().reference()
    var partyID: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style(button: appleMusicButton, fontSize: 36)
        style(button: spotifyButton, fontSize: 36)
        style(view: titleBackground)
        
        if let user = Auth.auth().currentUser {
            username = user.displayName
        } else {
            let name = UserDefaults.standard.string(forKey: "MixedUserName")
            username = name
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if partyID == nil {
            generateNewPartyID { (id) in
                print("got id \(id)")
                self.partyID = id
            }
        }
    }
    
    fileprivate func generateNewPartyID(callback: @escaping (String) -> Void){
        let id = randomString(length: 6)
        ref.child("parties").child(id).observe(.value) { (snapshot) in
            if !snapshot.exists() {
                callback(id)
            } else {
                self.generateNewPartyID(callback: callback)
            }
        }
    }
    
       
    @IBAction func appleMusicTapped(_ sender: Any) {
        guard let partyID = partyID else {
            showError(title: "Whoops", withMessage: "Error while generating party ID. Please try again.", fromController: self)
            return
        }
        
        let standardRef = ref.child("parties").child(partyID)
        standardRef.child("partyType").setValue("AppleMusic")
        standardRef.child("creationDate").setValue(getCurrentDate())
        standardRef.child("hostName").setValue(username)
        provider = MusicProvider.appleMusic
        performSegue(withIdentifier: "toPlayer", sender: self)
    }
    
    @IBAction func spotifyTapped(_ sender: Any) {
        guard let partyID = partyID else {
            showError(title: "Whoops", withMessage: "Error while generating party ID. Please try again.", fromController: self)
            return
        }
        
        let standardRef = ref.child("parties").child(partyID)
        standardRef.child("partyType").setValue("Spotify")
        standardRef.child("creationDate").setValue(getCurrentDate())
        standardRef.child("hostName").setValue(username)
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

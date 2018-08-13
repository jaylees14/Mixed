//
//  MainMenuViewController.swift
//  Mixed
//
//  Created by Jay Lees on 25/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit
import Firebase

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var joinPartyButton: MixedButton!
    @IBOutlet weak var spotifyButton: MixedButton!
    @IBOutlet weak var appleMusicButton: MixedButton!
    
    private var partyID: String!
    private var playerType: PartyPlayerViewController.PlayerType!
    
    public var isFirstLogin = false
    
    override func viewDidLoad() {
        [joinPartyButton, spotifyButton, appleMusicButton].forEach { (button) in
            button?.alpha = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getAppleMusicToken()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startAnimation()
    }
    
    private func startAnimation(){
        // Account for top spacing - devices with different safe areas run > iOS 11
        // This is only available once the view has loaded r
        var topSpacing: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            topSpacing = view.safeAreaInsets.top
        }
        
        let soundWave = SoundWave(origin: CGPoint(x: 0, y: (view.frame.height / 2) - 50), width: view.frame.width)
        view.addSubview(soundWave)
        soundWave.animate(duration: 3)
        
        let mixedLogo = LogoView(center: CGPoint(x: view.center.x, y: topSpacing + 50), scale: 1, isInitiallyHidden: false, backgroundGradient: true)
        view.addSubview(mixedLogo)
        
        if !isFirstLogin {
            mixedLogo.alpha = 0
            UIView.animate(withDuration: 1, delay: 3, options: .curveEaseInOut, animations: {
                mixedLogo.alpha = 1
            }, completion: nil)
        } else {
            mixedLogo.alpha = 1
        }
        
        UIView.animate(withDuration: 1, delay: 3.2, options: .curveEaseInOut, animations: {
            self.joinPartyButton.alpha = 1
        }, completion:  nil)
        UIView.animate(withDuration: 1, delay: 3.4, options: .curveEaseInOut, animations: {
            self.spotifyButton.alpha = 1
        }, completion:  nil)
        UIView.animate(withDuration: 1, delay: 3.6, options: .curveEaseInOut, animations: {
            self.appleMusicButton.alpha = 1
        }, completion:  nil)
    }
    
    
    //TODO: REFACTOR THIS!!!!
    func getAppleMusicToken(){
        Database.database().reference().child("appleMusic").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotVal = snapshot.value as? [String: String]{
                let token = snapshotVal["token"]
                UserDefaults.standard.setValue(token, forKey: "AMTOKEN")
            }
        })
    }
    
    @IBAction func didTapJoinParty(_ sender: Any) {
        guard hasNetworkConnection() else {
            showError(title: "No Network Connection", message: "Please check your connection and try again.", controller: self)
            return
        }
        performSegue(withIdentifier: "toScanCode", sender: self)
    }
    
    @IBAction func didTapSpotify(_ sender: Any) {
        guard hasNetworkConnection() else {
            showError(title: "No Network Connection", message: "Please check your connection and try again.", controller: self)
            return
        }
        partyID = Datastore.instance.createNewParty(with: .spotify)
        playerType = .host
        performSegue(withIdentifier: "toPlayer", sender: self)
    }
    
    @IBAction func didTapAppleMusic(_ sender: Any) {
        guard hasNetworkConnection() else {
            showError(title: "No Network Connection", message: "Please check your connection and try again.", controller: self)
            return
        }
        partyID = Datastore.instance.createNewParty(with: .appleMusic)
        playerType = .host
        performSegue(withIdentifier: "toPlayer", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayer" {
            guard let navigation = segue.destination as? UINavigationController,
                  let dest = navigation.topViewController as? PartyPlayerViewController else {
                fatalError("Invalid Segue")
            }
            dest.partyID = partyID
            dest.playerType = playerType
        }
    }
}

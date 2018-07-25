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
    
    override func viewWillAppear(_ animated: Bool) {
        let soundWave = SoundWave(origin: CGPoint(x: 0, y: (view.frame.height / 2) - 50), width: view.frame.width)
        view.addSubview(soundWave)
        soundWave.animate(duration: 3)
        
        getAppleMusicToken()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Account for top spacing - devices with different safe areas run > iOS 11
        // This is only available once the view has loaded r
        var topSpacing: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            topSpacing = view.safeAreaInsets.top
        }
        
        let mixedLogo = LogoView(center: CGPoint(x: view.center.x, y: topSpacing + 50), scale: 1, isInitiallyHidden: false, backgroundGradient: true)
        view.addSubview(mixedLogo)
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
        
    }
    
    @IBAction func didTapSpotify(_ sender: Any) {
    }
    
    @IBAction func didTapAppleMusic(_ sender: Any) {
        Datastore.instance.createNewParty()
    }
}

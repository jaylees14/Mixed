//
//  LoginViewController.swift
//  Mixed
//
//  Created by Jay Lees on 13/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import Firebase

class LoginOnboardingViewController: MixedViewController {
    
    @IBOutlet weak var waveView: UIView!
    @IBOutlet weak var facebookButton: UIView!
    override func viewDidLoad(){
        super.viewDidLoad()
        facebookButton.layer.cornerRadius = 7
        facebookButton.layer.borderColor = UIColor.mixedRed.cgColor
        facebookButton.layer.borderWidth = 3
        
        setupView(self.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let waves = SoundWave(x: 0, y: 0, width: waveView.frame.width)
        waveView.addSubview(waves)
        waves.animateWave(duration: 2)
    }

    @IBAction func loginWithFacebookTapped(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(_, _, _):
                let credential = FacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        print("Error whilst signing in with Facebook to firebase: ", error)
                        return
                    }
                    print("Firebase login was a success")
                    self.performSegue(withIdentifier: "toMenu", sender: self)
                }
            }
        }
    }
}

//
//  OpeningViewController.swift
//  Mixed
//
//  Created by Jay Lees on 07/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class OpeningViewController: UIViewController {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mixedLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var startPartyButton: OnboardingButton!
    
    private var logo: LogoView!
    private var gradient: MixedGradient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subtitleLabel.alpha = 0
        mixedLabel.alpha = 0
        startPartyButton.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        logo = LogoView(center: view.center, scale: 1, isInitiallyHidden: true)
        view.addSubview(logo)
        
        gradient = MixedGradient(in: self.backgroundView.frame)
        gradient.animate()
        backgroundView.layer.addSublayer(gradient)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.logo.animate(duration: 1.5, then: self.beginAnimation)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    // TODO: Can this be refactored in a cleaner way
    private func beginAnimation(){
        UIView.animate(withDuration: 1, animations: {
            self.logo.center.y = self.mixedLabel.frame.origin.y - (self.logo.frame.height + 16)
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                self.mixedLabel.alpha = 1
            }, completion: { (_) in
                UIView.animate(withDuration: 1, animations: {
                    self.subtitleLabel.alpha = 1
                }, completion: { (_) in
                    UIView.animate(withDuration: 1, animations: {
                        self.startPartyButton.alpha = 1
                    })
                })
            })
        }
    }
    
    // MARK: - Button Actions
    @IBAction func startPartyTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toNameInput", sender: self)
    }
    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNameInput" {
            guard let destination = segue.destination as? NameViewController else {
                return
            }
            destination.gradient = gradient
        }
    }
}

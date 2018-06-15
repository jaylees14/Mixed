//
//  OpeningViewController.swift
//  Mixed
//
//  Created by Jay Lees on 07/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class OpeningViewController: UIViewController {
    @IBOutlet weak var welcomeToLabel: UILabel!
    @IBOutlet weak var mixedLabel: UILabel!
    
    private var logo: LogoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        welcomeToLabel.alpha = 0
        mixedLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        logo = LogoView(center: view.center, scale: 1)
        view.addSubview(logo)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.logo.animate(duration: 1.5, then: self.beginAnimation)
        }
    }

    private func beginAnimation(){
        UIView.animate(withDuration: 1, animations: {
            self.logo.center.y = self.welcomeToLabel.frame.origin.y - (self.logo.frame.height + 16)
        }) { (_) in
            UIView.animate(withDuration: 0.5, animations: {
                self.welcomeToLabel.alpha = 1
            }, completion: { (_) in
                UIView.animate(withDuration: 1, animations: {
                    self.mixedLabel.alpha = 1
                })
            })
        }
    }
}

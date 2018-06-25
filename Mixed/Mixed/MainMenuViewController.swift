//
//  MainMenuViewController.swift
//  Mixed
//
//  Created by Jay Lees on 25/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let soundWave = SoundWave(origin: CGPoint(x: 0, y: 300), width: view.frame.width)
        view.addSubview(soundWave)
        soundWave.animate(duration: 3)
        
        let mixedLogo = LogoView(center: CGPoint(x: view.center.x, y: 100), scale: 1, isInitiallyHidden: false, backgroundGradient: true)
        view.addSubview(mixedLogo)
    }

}

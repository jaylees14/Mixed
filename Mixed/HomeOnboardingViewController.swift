//
//  HomeOnboardingViewController.swift
//  Mixed
//
//  Created by Jay Lees on 29/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import MKTween
import FacebookCore

class HomeOnboardingViewController: UIViewController {

    @IBOutlet weak var waveView: UIView!
    @IBOutlet weak var takeTheTourButton: UIButton!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mixedBlue
        titleView.alpha = 0
        subtitle.alpha = 0
        
        takeTheTourButton.layer.cornerRadius = takeTheTourButton.frame.height / 2
        takeTheTourButton.setTitleColor(.mixedBlue, for: .normal)
        takeTheTourButton.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        let _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(startAnimation), userInfo: nil, repeats: false)
    }
    
    @objc func startAnimation(){
        let waves = SoundWave(x: 0, y: 0, width: waveView.frame.width)
        waveView.addSubview(waves)
        waves.animateWave(duration: 2)
        animateText()
        animateButton()
    }

    func animateText(){
        UIView.animate(withDuration: 1.5, delay: 2, options: .curveEaseInOut, animations: {
            self.titleView.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 1, delay: 0 , options: .curveEaseInOut, animations: {
                self.subtitle.alpha = 1
            }, completion: nil)
        }
    }
    
    func animateButton(){
       UIView.animate(withDuration: 1, delay: 5, options: .curveEaseInOut, animations: { 
        self.takeTheTourButton.alpha = 1
       }, completion: nil)
    }
    
    @IBAction func takeTheTourTapped(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.init("TakeTheTour"), object: nil)
    }
}

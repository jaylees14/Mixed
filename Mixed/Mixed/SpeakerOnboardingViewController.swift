//
//  SpeakerOnboardingViewController.swift
//  Mixed
//
//  Created by Jay Lees on 29/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import MKTween

class SpeakerOnboardingViewController: UIViewController {

    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var speakerImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var continueButtonToCenter: NSLayoutConstraint!
    
    
    var backgroundCircle: UIView!
    var hasAnimated = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mixedBlue
        continueButton.layer.cornerRadius = continueButton.frame.height / 2
        continueButton.setTitleColor(.mixedBlue, for: .normal)
        iconView.backgroundColor = .clear
        setupImage()
    }
    
    func setupImage(){
        backgroundCircle = UIView(frame: CGRect(x: 0, y: 0, width: iconView.frame.width, height: iconView.frame.height))
        backgroundCircle.backgroundColor = .mixedRed
        backgroundCircle.layer.cornerRadius = iconView.frame.width / 2
        iconView.insertSubview(backgroundCircle, at: 0)
        backgroundCircle.frame.origin = CGPoint(x: backgroundCircle.frame.origin.x, y: -500)
        self.speakerImage.alpha = 0
        self.titleLabel.alpha = 0
        self.subtitle.alpha = 0
        continueButton.alpha = 0
        continueButtonToCenter.constant = -500
    }

    override func viewDidAppear(_ animated: Bool) {
        if !hasAnimated {
            animateCircle()
            hasAnimated = true
        }
    }
    
    //MARK: - Animation Methods
    func animateCircle(){
        let period = MKTweenPeriod(duration: 1.5, delay: 0, startValue: -500, endValue: 0)
        let operation = MKTweenOperation(period: period, updateBlock: { (period) in
            let progress = CGFloat(period.progress)
            self.backgroundCircle.frame.origin = CGPoint(x: self.backgroundCircle.frame.origin.x, y: progress)
        }, completeBlock: { () in
            self.animateSpeaker()
        }, timingFunction: MKTweenTiming.BounceOut)
        
        MKTween.shared.addTweenOperation(operation)
    }
    
    func animateSpeaker(){
        UIView.animate(withDuration: 0.5, animations: {
            self.speakerImage.alpha = 1
        }, completion: {(_) in
            UIView.animate(withDuration: 1, animations: { 
                self.titleLabel.alpha = 1
                self.subtitle.alpha = 1
            }, completion: { (_) in
                self.animateButton()
            })
        })
    }
    
    func animateButton(){
        continueButton.alpha = 1
        let period = MKTweenPeriod(duration: 1, delay: 0, startValue: -500, endValue: 0)
        let operation = MKTweenOperation(period: period, updateBlock: { (period) in
            let progress = CGFloat(period.progress)
            self.continueButtonToCenter.constant = progress
        }, completeBlock: { () in
        }, timingFunction: MKTweenTiming.BackOut)
        
        MKTween.shared.addTweenOperation(operation)

    }
    
    
    @IBAction func continueTapped(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.init("ToBeer"), object: nil)
    }

}

//
//  TapOnboardingViewController.swift
//  Mixed
//
//  Created by Jay Lees on 29/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import MKTween

class TapOnboardingViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var iconView: UIView!

    @IBOutlet weak var phoneImage: UIImageView!
    @IBOutlet weak var handImage: UIImageView!
    @IBOutlet weak var tapCircle: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var continueButtonToBottom: NSLayoutConstraint!
    
    var backgroundCircle: CircleView!
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
        // Generate circle view
        backgroundCircle = CircleView(diameter: iconView.frame.width)
        iconView.insertSubview(backgroundCircle, at: 0)
        
        // Hide all graphics
        titleLabel.alpha = 0
        subtitle.alpha = 0
        phoneImage.alpha = 0
        handImage.alpha = 0
        
        // Move continue button off screen
        continueButtonToBottom.constant = -200

        // Shrink circles
        backgroundCircle.layer.transform = CATransform3DMakeScale(0, 0, 0)
        tapCircle.layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        // Offset hand
        handImage.frame.origin = CGPoint(x: self.handImage.frame.origin.x - 10, y: self.handImage.frame.origin.y)
        
        iconView.bringSubview(toFront: handImage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard !hasAnimated else {
            return
        }
        animateCircle()
        hasAnimated = true
    }
    
    
    //MARK: - Animation Methods
    func animateCircle(){
        let period = MKTweenPeriod(duration: 1, delay: 0, startValue: 0, endValue: 1)
        let operation = MKTweenOperation(period: period, updateBlock: { (period) in
            self.backgroundCircle.layer.transform = CATransform3DMakeScale(CGFloat(period.progress), CGFloat(period.progress), 0)
        }, completeBlock: { () in
            self.animatePhone()
            UIView.animate(withDuration: 0.5, animations: { 
                self.titleLabel.alpha = 1
                self.subtitle.alpha = 1
            })
        }, timingFunction: MKTweenTiming.BackOut)
        
        MKTween.shared.addTweenOperation(operation)
    }
    
    func animatePhone(){
        UIView.animate(withDuration: 0.5, animations: {
            self.phoneImage.alpha = 1
        }, completion:{ (_) in
            self.animateHand()
        })
    }
    
    func animateHand(){
        UIView.animate(withDuration: 0.5, animations: { 
            self.handImage.alpha = 1
        }, completion: {(_) in
            UIView.animate(withDuration: 0.5, animations: { 
                self.handImage.frame.origin = CGPoint(x: self.handImage.frame.origin.x + 10, y: self.handImage.frame.origin.y)
            }, completion: { (_) in
                self.animateTap()
            })
        })
    }
    
    func animateTap(){
        let period = MKTweenPeriod(duration: 0.2, delay: 0, startValue: 0, endValue: 1)
        let operation = MKTweenOperation(period: period, updateBlock: { (period) in
            let progress = CGFloat(period.progress)
            self.tapCircle.layer.transform = CATransform3DMakeScale(progress, progress, 0)
        }, completeBlock: { () in
            self.animateButton()
        }, timingFunction: MKTweenTiming.BackOut)
        
        MKTween.shared.addTweenOperation(operation)
    }
    
    func animateButton(){
        let period = MKTweenPeriod(duration: 1, delay: 0, startValue: -200, endValue: 35)
        let operation = MKTweenOperation(period: period, updateBlock: { (period) in
            self.continueButtonToBottom.constant = CGFloat(period.progress)
        }, completeBlock: { () in
        }, timingFunction: MKTweenTiming.BackOut)
        
        MKTween.shared.addTweenOperation(operation)
    }
    
    
    @IBAction func continueTapped(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.init("ToSpeaker"), object: nil)
    }

}

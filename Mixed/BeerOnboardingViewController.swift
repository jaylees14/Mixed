//
//  BeerOnboardingViewController.swift
//  Mixed
//
//  Created by Jay Lees on 29/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import MKTween

class BeerOnboardingViewController: UIViewController {

    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var beerImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var getStartedToCenter: NSLayoutConstraint!
    var backgroundCircle: UIView!
    var hasAnimated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mixedBlue
        getStartedButton.layer.cornerRadius = getStartedButton.frame.height / 2
        getStartedButton.setTitleColor(.mixedBlue, for: .normal)
        iconView.backgroundColor = .clear
        
        setupImage()
    }
    
    func setupImage(){
        backgroundCircle = UIView(frame: CGRect(x: 0, y: 0, width: iconView.frame.width, height: iconView.frame.height))
        backgroundCircle.backgroundColor = .mixedRed
        backgroundCircle.layer.cornerRadius = iconView.frame.width / 2
        iconView.insertSubview(backgroundCircle, at: 0)
        backgroundCircle.frame.origin = CGPoint(x: 0, y: view.frame.height + 200)
        getStartedToCenter.constant = -500
        getStartedButton.alpha = 0
        titleLabel.alpha = 0
        subtitle.alpha = 0
        beerImage.alpha = 0
    }

    
    override func viewDidAppear(_ animated: Bool) {
        if !hasAnimated {
            animateCircle()
            hasAnimated = true
        }
    }
    
    //MARK: - Animation Methods
    func animateCircle(){
        let period = MKTweenPeriod(duration: 1.5, delay: 0, startValue: Double(view.frame.height + 200), endValue: 0)
        let operation = MKTweenOperation(period: period, updateBlock: { (period) in
            let progress = CGFloat(period.progress)
            self.backgroundCircle.frame.origin = CGPoint(x: self.backgroundCircle.frame.origin.x, y: progress)
        }, completeBlock: { () in
            UIView.animate(withDuration: 1, animations: { 
                self.beerImage.alpha = 1
            }, completion: { (_) in
                self.animateText()
            })
        }, timingFunction: MKTweenTiming.BackOut)
        
        MKTween.shared.addTweenOperation(operation)
    }
    
    func animateText(){
        UIView.animate(withDuration: 1, animations: { 
            self.titleLabel.alpha = 1
            self.subtitle.alpha = 1
        }) { (_) in
            self.animateButton()
        }
    }
    
    func animateButton(){
        getStartedButton.alpha = 1
        let period = MKTweenPeriod(duration: 1, delay: 0, startValue: -500, endValue: 0)
        let operation = MKTweenOperation(period: period, updateBlock: { (period) in
            let progress = CGFloat(period.progress)
            self.getStartedToCenter.constant = progress
        }, completeBlock: { () in
        }, timingFunction: MKTweenTiming.BackOut)
        
        MKTween.shared.addTweenOperation(operation)
    }
    
    @IBAction func getStartedTapped(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.init("ToLogin"), object: nil)
        
    }
    
}

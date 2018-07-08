//
//  OnboardingButton.swift
//  Mixed
//
//  Created by Jay Lees on 15/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class OnboardingButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        style()
    }
    
    fileprivate func style() {
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = self.frame.height / 2
        self.titleLabel?.font = UIFont.mixedFont(size: 18, weight: .regular)
        self.setTitleColor(.white, for: .normal)
    }
    
}

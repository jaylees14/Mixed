//
//  MixedButton.swift
//  Mixed
//
//  Created by Jay Lees on 25/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

class MixedButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        style()
    }
    
    private func style(){
        self.layer.cornerRadius = 5
        self.layer.borderColor = UIColor.mixedPrimaryBlue.cgColor
        self.layer.borderWidth = 1
        self.titleLabel?.font = UIFont.mixedFont(size: 18, weight: .bold)
        self.setTitleColor(UIColor.mixedPrimaryBlue, for: .normal)
    }
}

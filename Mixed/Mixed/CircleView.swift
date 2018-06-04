//
//  CircleView.swift
//  Mixed
//
//  Created by Jay Lees on 02/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

public class CircleView: UIView {
    public init(diameter: CGFloat){
        super.init(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        self.backgroundColor = .mixedRed
        self.layer.cornerRadius = diameter / 2
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

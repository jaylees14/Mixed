//
//  MixedGradient.swift
//  Mixed
//
//  Created by Jay Lees on 15/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

class MixedGradient: CALayer {
    private var baseLayer: CAGradientLayer!
    
    init(in frame: CGRect) {
        baseLayer = CAGradientLayer()
        baseLayer.colors = [UIColor.create(hex: "#E37B7E").cgColor,  UIColor.create(hex: "#AEA1FB").cgColor]
        baseLayer.locations = [0, 0.8]
        baseLayer.startPoint = CGPoint(x: 0, y: 1)
        baseLayer.endPoint = CGPoint(x: 1, y: 0)
        
        super.init()
        baseLayer.frame = frame
        self.addSublayer(baseLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        baseLayer = CAGradientLayer()
        baseLayer.colors = [UIColor.create(hex: "#E37B7E").cgColor,  UIColor.create(hex: "#AEA1FB").cgColor]
        baseLayer.locations = [0, 0.8]
        baseLayer.startPoint = CGPoint(x: 0, y: 1)
        baseLayer.endPoint = CGPoint(x: 1, y: 0)
        
        super.init(coder: aDecoder)
        baseLayer.frame = frame
        self.addSublayer(baseLayer)
    }
    
    override init(layer: Any) {
        baseLayer = CAGradientLayer()
        baseLayer.colors = [UIColor.create(hex: "#E37B7E").cgColor,  UIColor.create(hex: "#AEA1FB").cgColor]
        baseLayer.locations = [0, 0.8]
        baseLayer.startPoint = CGPoint(x: 0, y: 1)
        baseLayer.endPoint = CGPoint(x: 1, y: 0)
        
        super.init(layer: layer)
        baseLayer.frame = frame
        self.addSublayer(baseLayer)
    }
    
    public func animate() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            
            // We want a random number between about 0.4 and 0.9
            let location = arc4random_uniform(50) + 40
            let newLocations = [0, NSNumber(value: Double(location)/100.0)]
            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = self.baseLayer.locations
            animation.toValue = newLocations
            animation.duration = 2
            self.baseLayer.locations = newLocations
            self.baseLayer.add(animation, forKey: animation.keyPath)
        }
    }

}

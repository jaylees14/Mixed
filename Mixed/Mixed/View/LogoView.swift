//
//  LogoView.swift
//  Mixed
//
//  Created by Jay Lees on 07/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class LogoView: UIView {
    private let height: CGFloat = 50.0
    private let width: CGFloat = 95.0
    private var scaledHeight: CGFloat
    private var scaledWidth: CGFloat
    private var logoLayer: CAShapeLayer
    private var gradient: MixedGradient
    
    init(center: CGPoint, scale: CGFloat, isInitiallyHidden: Bool, backgroundGradient: Bool = false) {
        self.scaledHeight = scale * height
        self.scaledWidth = scale * width

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: scaledHeight))
        path.addLine(dx: scaledWidth / 4, dy: -scaledHeight)
        path.addLine(dx: scaledWidth / 4, dy: scaledHeight)
        path.addLine(dx: scaledWidth / 4, dy: -scaledHeight)
        path.addLine(dx: scaledWidth / 4, dy: scaledHeight)
        
        logoLayer = CAShapeLayer()
        logoLayer.path = path.cgPath
        logoLayer.strokeColor = UIColor.white.cgColor
        logoLayer.strokeEnd = isInitiallyHidden ? 0.0 : 1.0
        logoLayer.fillColor = UIColor.clear.cgColor
        logoLayer.lineCap = CAShapeLayerLineCap.round
        logoLayer.lineJoin = CAShapeLayerLineJoin.round
        logoLayer.lineWidth = 27.0
        
        gradient = MixedGradient(in: CGRect(origin: CGPoint(x: -50, y: -50),
                                            size: CGSize(width: scaledWidth + 100, height: scaledHeight + 100)))
        gradient.mask = logoLayer
        
        super.init(frame: CGRect(x: center.x - scaledWidth / 2,
                                 y: center.y - scaledHeight / 2,
                                 width: scaledWidth,
                                 height: scaledHeight))

        
        if backgroundGradient {
            layer.addSublayer(gradient)
            gradient.animate()
        } else {
            self.layer.addSublayer(logoLayer)
        }
    }
    
    public func animate(duration: Double, then callback: (() -> Void)? = nil) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    
        logoLayer.strokeEnd = 1.0
        logoLayer.add(animation, forKey: "animateLogo")
        
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            callback?()
        }
    }
    
    public func showGradient(){
        layer.addSublayer(gradient)
        gradient.mask = logoLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

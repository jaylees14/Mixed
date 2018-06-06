//
//  SoundWave.swift
//  Mixed
//
//  Created by Jay Lees on 29/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import Foundation
import UIKit

class SoundWave: UIView{
    
    var waveLayer: CAShapeLayer!
    
    init(x: CGFloat, y: CGFloat, width: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: width, height: 150))
        let path = getPath()
        
        waveLayer = CAShapeLayer()
        waveLayer.path = path.cgPath
        waveLayer.fillColor = UIColor.clear.cgColor
        waveLayer.strokeColor = UIColor.mixedRed.cgColor
        waveLayer.lineWidth = 3.0
        waveLayer.strokeEnd = 0.0
        waveLayer.lineJoin = kCALineJoinRound
        layer.addSublayer(waveLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animate(duration: TimeInterval){
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        waveLayer.strokeEnd = 1.0
        waveLayer.add(animation, forKey: "animateWave")
    }
    
    
    func getPath() -> UIBezierPath {
        let path = UIBezierPath()
        let width = frame.width
        let midHeight: CGFloat = 75
        path.move(to: CGPoint(x: 0, y: midHeight))
        path.addLine(dx: width*0.07, dy: 0)
        path.addLine(dx: width*0.014, dy: 10)
        path.addLine(dx: width*0.03, dy: -30)
        path.addLine(dx: width*0.024, dy: 36)
        path.addLine(dx: width*0.044, dy: -24)
        path.addLine(dx: width*0.022, dy: 15)
        path.addLine(dx: width*0.04, dy: -86)
        path.addLine(dx: width*0.06, dy: 115)
        path.addLine(dx: width*0.03, dy: -56)
        path.addLine(dx: width*0.024, dy: 24)
        path.addLine(dx: width*0.02, dy: -42)
        path.addLine(dx: width*0.042, dy: 46)
        path.addLine(dx: width*0.012, dy: -12)
        path.addLine(dx: width*0.022, dy: 19)
        path.addLine(dx: width*0.04, dy: -23)
        path.addLine(dx: width*0.022, dy: 73)
        path.addLine(dx: width*0.06, dy: -128)
        path.addLine(dx: width*0.054, dy: 98)
        path.addLine(dx: width*0.036, dy: -68)
        path.addLine(dx: width*0.054, dy: 51)
        path.addLine(dx: width*0.026, dy: -16)
        path.addLine(dx: width*0.026, dy: 15)
        path.addLine(dx: width*0.044, dy: -31)
        
        path.addLine(dx: width*0.034, dy: 31)
        path.addLine(dx: width*0.022, dy: -19)
        path.addLine(dx: width*0.022, dy: 18)
        path.addLine(to: CGPoint(x: path.currentPoint.x + width * 0.08, y: midHeight))
        path.addLine(to: CGPoint(x: frame.width , y: midHeight))
        
        path.lineJoinStyle = .round
        
        return path
        
    }
}


extension UIBezierPath {
    func addLine(dx: CGFloat, dy: CGFloat){
        return addLine(to: CGPoint(x: currentPoint.x + dx, y: currentPoint.y + dy))
    }
}

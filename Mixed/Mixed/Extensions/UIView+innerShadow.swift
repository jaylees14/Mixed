//
//  UIView+innerShadow.swift
//  Mixed
//
//  Created by Jay Lees on 24/08/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

extension UIView {
    public func addInnerShadow(color: UIColor, size: CGFloat, cornerRadius: CGFloat = 0.0, opacity: Float) {
        let shadowLayer = CAShapeLayer()
        shadowLayer.frame = bounds
        shadowLayer.shadowColor = color.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = size
        shadowLayer.fillRule = CAShapeLayerFillRule.evenOdd
        shadowLayer.cornerRadius = cornerRadius
        
        let shadowPath = CGMutablePath()
        let insetRect = bounds.insetBy(dx: -size * 2.0, dy: -size * 2.0)
        let innerFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        shadowPath.addEllipse(in: insetRect)
        shadowPath.addEllipse(in: innerFrame)
        shadowLayer.path = shadowPath
        layer.addSublayer(shadowLayer)
        clipsToBounds = true
    }
}

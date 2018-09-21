//
//  UIBezierPath+drawLine.swift
//  Mixed
//
//  Created by Jay Lees on 15/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

extension UIBezierPath {
    func addLine(dx: CGFloat, dy: CGFloat){
        return addLine(to: CGPoint(x: currentPoint.x + dx, y: currentPoint.y + dy))
    }
}

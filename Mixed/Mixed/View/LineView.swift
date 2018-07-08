//
//  LineView.swift
//  Mixed
//
//  Created by Jay Lees on 25/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

// Draw a horizontal line across the top edge of the rect
class LineView: UIView {
    private let color: UIColor
    
    init(frame: CGRect, color: UIColor = .white) {
        self.color = color
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.color = UIColor.clear
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.close()
        
        path.lineWidth = rect.height
        color.set()
        path.stroke()
    }
}

//
//  UIColorExtension.swift
//  OrbChat
//
//  Created by Jay Lees on 12/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {    
    public class var mixedBlue: UIColor {
        return hexToRGB(hex: "313357")!
    }
    
    public class var mixedRed: UIColor {
        return hexToRGB(hex: "D7445C")!
    }
    
    public class var mixedDirtyWhite: UIColor {
        return hexToRGB(hex: "F1F1F1")!
    }
    
    static func hexToRGB(hex: String) -> UIColor? {
        let array = hex.map { String($0) }
        if array.count == 6 {
            if let red = UInt8("\(array[0])\(array[1])", radix: 16), let green = UInt8("\(array[2])\(array[3])", radix: 16), let blue = UInt8("\(array[4])\(array[5])", radix: 16) {
                return UIColor(displayP3Red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
            }
        }
        return nil
    }
}

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
        return self.init(hex: "313357")
    }
    
    public class var mixedRed: UIColor {
        return self.init(hex: "D7445C")
    }
    
    public class var mixedDirtyWhite: UIColor {
        return self.init(hex: "F1F1F1")
    }
    
    /// Initalise a UIColor from a hex string formatted as RRGGBB or RRGGBBAA, with or without a leading #
    ///
    /// - Parameter hex: A hex string, formatted as above
    public convenience init(hex: String){
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        var rgb: UInt32 = 0
        
        let sanitisedHex = hex.replacingOccurrences(of: "#", with: "")
        if Scanner(string: sanitisedHex).scanHexInt32(&rgb) {
            if sanitisedHex.count == 6 {
                red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
                green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
                blue = CGFloat((rgb & 0x0000FF)) / 255.0
            } else if sanitisedHex.count == 8 {
                red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
                green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
                blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
                alpha = CGFloat((rgb & 0x000000FF)) / 255.0
            }
        }
        self.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
    }
}

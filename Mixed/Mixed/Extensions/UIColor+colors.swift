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

    @available(*, deprecated, message: "Use mixedPrimaryBlue instead")
    public class var mixedBlue: UIColor {
        return self.create(hex: "313357")
    }
    
    @available(*, deprecated, message: "Use new color scheme instead")
    public class var mixedRed: UIColor {
        return self.create(hex: "D7445C")
    }
    
    @available(*, deprecated, message: "Use new color scheme instead")
    public class var mixedDirtyWhite: UIColor {
        return self.create(hex: "F1F1F1")
    }
    
    public class var mixedPrimaryBlue: UIColor {
        return self.create(hex: "#0B132BFF")
    }
    
    public class var mixedSecondaryBlue: UIColor {
        return self.create(hex: "#0B132B99")
    }
    
    /// Initalise a UIColor from a hex string formatted as RRGGBB or RRGGBBAA, with or without a leading #
    ///
    /// - Parameter hex: A hex string, formatted as above
    public static func create(hex: String) -> UIColor {
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
        return UIColor.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
    }
}

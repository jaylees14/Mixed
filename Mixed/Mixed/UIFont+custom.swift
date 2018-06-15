//
//  UIFontExtension.swift
//  Mixed
//
//  Created by Jay Lees on 26/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    public enum FontWeight {
        case light
        case regular
        case bold
    }
    
    public static func mixedFont(size: CGFloat, weight: FontWeight = .regular) -> UIFont {
        switch weight {
        case .light: return UIFont(name: "Comfortaa-Light", size: size)!
        case .regular: return UIFont(name: "Comfortaa-Regular", size: size)!
        case .bold: return UIFont(name: "Comfortaa-Bold", size: size)!
        }
        
    }
}

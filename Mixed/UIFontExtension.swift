//
//  UIFontExtension.swift
//  Mixed
//
//  Created by Jay Lees on 26/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import Foundation
import UIKit

extension UIFont{
    public func mixedFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans", size: size)!
    }
    
    public func mixedFontLight(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Light", size: size)!
    }
}

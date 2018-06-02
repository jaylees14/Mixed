//
//  UITextFieldExtension.swift
//  Mixed
//
//  Created by Jay Lees on 26/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import Foundation
import UIKit

public extension UITextField {
    @IBInspectable public var leftSpacer: CGFloat {
        get {
            return leftView?.frame.size.width ?? 0
        } set {
            leftViewMode = .always
            leftView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
        }
    }
}

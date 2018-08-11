//
//  UIImage+resize.swift
//  Mixed
//
//  Created by Jay Lees on 11/08/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

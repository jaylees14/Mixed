//
//  UIApplication+version.swift
//  Mixed
//
//  Created by Jay Lees on 19/08/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

extension UIApplication {
    var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
}

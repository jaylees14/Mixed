//
//  Utils.swift
//  Mixed
//
//  Created by Jay Lees on 16/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

typealias EmptyCallback = () -> Void

func getCurrentDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
    return dateFormatter.string(from:Date())
}

//Standard error function
func showError(title: String, message: String, controller: UIViewController){
    let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okButton = UIAlertAction(title: "Okay", style: .default)
    alertView.addAction(okButton)
    controller.present(alertView, animated: true, completion: nil)
}

func askQuestion(title: String, message: String, controller: UIViewController, acceptCompletion: EmptyCallback? = nil, cancelCompletion: EmptyCallback? = nil){
    let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let positiveButton = UIAlertAction(title: "Okay", style: .destructive) { (_) in
        acceptCompletion?()
    }
    let cancelButton = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
        cancelCompletion?()
    }
    
    alertView.addAction(positiveButton)
    alertView.addAction(cancelButton)
    controller.present(alertView, animated: true, completion: nil)
}

//Checks if connected to network
func hasNetworkConnection() -> Bool {
    var baseAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    baseAddress.sin_len = UInt8(MemoryLayout.size(ofValue: baseAddress))
    baseAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &baseAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
        return false
    }
    
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    
    return isReachable && !needsConnection
}

func randomString(length: Int) -> String {
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString: NSMutableString = NSMutableString(capacity: length)
    
    for _ in 0..<length{
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    
    return randomString as String
}

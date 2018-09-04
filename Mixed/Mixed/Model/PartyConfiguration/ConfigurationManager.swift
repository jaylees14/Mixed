//
//  ConfigurationManager.swift
//  Mixed
//
//  Created by Jay Lees on 19/08/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation
import Firebase

class ConfigurationManager {
    public static let shared = ConfigurationManager()
    private(set) var appleMusicToken: String?
    
    private init(){
        self.configure()
    }
    
    public func configure(){
        Database.database().reference().child("appleMusic").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotVal = snapshot.value as? [String: String] {
                let token = snapshotVal["token"]
                self.appleMusicToken = token
            }
        })
    }
}

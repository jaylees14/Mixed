//
//  SessionManager.swift
//  Mixed
//
//  Created by Jay Lees on 02/09/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

struct Session {
    let partyID : String
    let type : PlayerType
}

class SessionManager {
    public static let shared = SessionManager()
    private let defaultsKey = "CURRENTMIXEDSESSION"
    private init() { }
    
    public func hasActiveSession() -> Bool {
        return UserDefaults.standard.dictionary(forKey: defaultsKey) != nil
    }
    
    public func getActiveSession() -> Session {
        let dict = UserDefaults.standard.dictionary(forKey: defaultsKey)!
        let partyID = dict["partyID"] as! String
        let typeRaw = dict["type"] as! Int
        let type = PlayerType(rawValue: typeRaw)!
        return Session(partyID: partyID, type: type)
    }
    
    public func setActiveSession(_ session: Session) {
        let dict: [String:Any] = ["partyID": session.partyID, "type": session.type.rawValue]
        UserDefaults.standard.set(dict, forKey: defaultsKey)
    }
    
    public func clearActiveSession() {
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }
}

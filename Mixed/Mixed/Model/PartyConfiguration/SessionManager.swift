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
    private let maxExpiry = 28800.0 // 8 hours
    private let dateFormat = "MM-dd-yyyy HH:mm"
    private let defaultsKey = "CURRENTMIXEDSESSION"
    private init() { }
    
    public func hasActiveSession() -> Bool {
        guard let session = UserDefaults.standard.object(forKey: defaultsKey) else {
            Logger.log("No session in defaults", type: .debug)
            return false
        }
        print(session)
        guard let dict = session as? [String:Any], let start = dict["start"] as? String else {
            Logger.log("No start found", type: .debug)
            return false
        }
        let startDate = date(of: start)
        guard startDate > Date().addingTimeInterval(-maxExpiry) else {
            Logger.log("Start was too long ago... clearing", type: .debug)
            clearActiveSession()
            return false
        }
        return true
    }
    
    public func getActiveSession() -> Session {
        let dict = UserDefaults.standard.dictionary(forKey: defaultsKey)!
        let partyID = dict["partyID"] as! String
        let typeRaw = dict["type"] as! Int
        let type = PlayerType(rawValue: typeRaw)!
        return Session(partyID: partyID, type: type)
    }
    
    public func setActiveSession(_ session: Session) {
        let dict: [String:Any] = ["partyID": session.partyID,
                                  "type": session.type.rawValue,
                                  "start": string(of: Date())]
        Logger.log("Setting active session for \(session.partyID)", type: .debug)
        UserDefaults.standard.set(dict, forKey: defaultsKey)
    }
    
    public func clearActiveSession() {
        Logger.log("Clearing active session", type: .debug)
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }
    
    private func string(of date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    private func date(of string: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: string)!
    }
}

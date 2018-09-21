//
//  CurrentUser.swift
//  Mixed
//
//  Created by Jay Lees on 22/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation


enum UserLoginError: Error {
    case notLoggedIn
}

extension UserLoginError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case.notLoggedIn:
            return "No user is currently logged in."
        }
    }
}

public class CurrentUser {
    public static let shared = CurrentUser()
    private let defaultsKey = "Mixed-CurrentUser"
    
    private init() { }
    
    public func isLoggedIn() -> Bool {
        return UserDefaults.standard.string(forKey: defaultsKey) != nil
    }
    
    public func setName(_ name: String) {
        UserDefaults.standard.set(name, forKey: defaultsKey)
    }
    
    public func getFullName() throws -> String {
        if let name = UserDefaults.standard.string(forKey: defaultsKey) {
            return name
        } else {
            throw UserLoginError.notLoggedIn
        }
    }
    
    public func getShortName() throws -> String {
        if let name = UserDefaults.standard.string(forKey: defaultsKey),
            let firstName = name.split(separator: " ").first {
            return String(firstName)
        } else {
            throw UserLoginError.notLoggedIn
        }
    }
}

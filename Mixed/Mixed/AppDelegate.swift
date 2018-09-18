//
//  AppDelegate.swift
//  Mixed
//
//  Created by Jay Lees on 13/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var player: SPTAudioStreamingController?
    let kClientId = "755571f4ec784d0d83e0824ecc9d293f"
    let kCallbackURL = "com-jaylees-mixed-spotify://returnafterlogin"
    let kTokenSwapURL = "http://localhost:1234/swap"
    let kTokenRefreshServiceURL = "http://localhost:1234/refresh"
    let kSessionUserDefaultsKey = "SpotifySession"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        SPTAuth.defaultInstance().clientID = kClientId
        SPTAuth.defaultInstance().redirectURL = URL(string:kCallbackURL)
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthUserReadPrivateScope]
        SPTAuth.defaultInstance().sessionUserDefaultsKey = kSessionUserDefaultsKey
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if SPTAuth.defaultInstance().canHandle(url) {
            SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url) { error, session in
                if let error = error {
                    Logger.log(error, type: .error)
                    return
                } else {
                    SPTAuth.defaultInstance().session = session
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "spotifySessionUpdated"), object: self)
                }
            }
        } else if url.scheme == "mixed" {
            guard CurrentUser.shared.isLoggedIn() else {
                Logger.log("Tried to open mixed:// url without logging in", type: .debug)
                return false
            }
            
            guard let query = url.query?.components(separatedBy: "&") else { return false }
            let id = query[0].components(separatedBy: "=")[1]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let menu = storyboard.instantiateViewController(withIdentifier: "MainMenuViewController")
                as! MainMenuViewController
            menu.didJoinRemoteParty(id: id)
            
            self.window?.rootViewController = menu
            self.window?.makeKeyAndVisible()
            
        }
        return true
    }
}


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
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        SPTAuth.defaultInstance().clientID = kClientId
        SPTAuth.defaultInstance().redirectURL = URL(string:kCallbackURL)
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope]
        SPTAuth.defaultInstance().sessionUserDefaultsKey = kSessionUserDefaultsKey
        
        //SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("YAS")
        if SPTAuth.defaultInstance().canHandle(url) {
            SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: url) { error, session in
                if let error = error {
                    print("*** Auth error: \(error)")
                    return
                } else {
                    SPTAuth.defaultInstance().session = session
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "spotifySessionUpdated"), object: self)
                }
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == "com.jaylees.mixed.startParty" {
            //guard AccessToken.current != nil else { return }
            let storyboard = UIStoryboard(name: "Main", bundle:nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController
            let startPartyViewController = storyboard.instantiateViewController(withIdentifier: "StartParty")
            navigationController.pushViewController(startPartyViewController, animated: false)
            self.window?.rootViewController = navigationController
            
            
            completionHandler(true)
        } else if shortcutItem.type == "com.jaylees.mixed.joinParty"{
            //guard AccessToken.current != nil else { return }
            let storyboard = UIStoryboard(name: "Main", bundle:nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController
            let startPartyViewController = storyboard.instantiateViewController(withIdentifier: "JoinParty")
            navigationController.pushViewController(startPartyViewController, animated: false)
            self.window?.rootViewController = navigationController
            completionHandler(true)
        }
        
        completionHandler(false)
    }

}


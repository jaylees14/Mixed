//
//  SearchCacher.swift
//  Mixed
//
//  Created by Jay Lees on 19/08/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

public class SearchCacher {
    private static let defaultsKey = "RECENT-SEARCHES"
    private init() {}
    
    public static func cache(song: String) {
        guard var currentSongs = UserDefaults.standard.array(forKey: defaultsKey) else {
            UserDefaults.standard.set([song], forKey: defaultsKey)
            return
        }
        
        if currentSongs.count >= 3 {
            currentSongs = Array(currentSongs.dropFirst())
        }
        currentSongs.append(song)
        UserDefaults.standard.set(currentSongs, forKey: defaultsKey)
    }
    
    public static func getLastThree() -> [String] {
        return (UserDefaults.standard.array(forKey: defaultsKey) as? [String])?.reversed() ?? []
    }
}

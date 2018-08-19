//
//  Autocompleter.swift
//  Mixed
//
//  Created by Jay Lees on 19/08/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

class Autocompleter {
    private init() { }
    
    public static func getSearchHints(for query: String, callback: @escaping ([String]) -> Void) {
        let formattedQuery = query.replacingOccurrences(of: " ", with: "+").lowercased()
        let url = URL(string: "https://api.music.apple.com/v1/catalog/gb/search/hints?term=\(formattedQuery)&limit=10")
        let token = ConfigurationManager.shared.appleMusicToken!
        
        NetworkRequest.getRequest(to: url!, bearer: token) { (results, error) in
            guard error == nil, let results = results else {
                print("Error getting search suggestions")
                callback([])
                return
            }
            if let terms = results["results"] as? [String: [String]],
               let suggestions = terms["terms"] {
                callback(suggestions)
            }
        }
    }
}

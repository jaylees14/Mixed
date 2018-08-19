//
//  NetworkRequest.swift
//  Mixed
//
//  Created by Jay Lees on 29/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

public class NetworkRequest {
    public static func getRequest(to url: URL, bearer: String, callback: @escaping ([String: Any]?, Error?) -> Void) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                callback(nil, error)
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse else {
                // TODO: Pass to callback
                print("Data returned is nil?")
                return
            }
            
            guard response.statusCode == 200 else {
                //TODO: Pass to callback
                print("Unknown error")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    callback(json, nil)
                }
            } catch let e {
                callback(nil, e)
            }
            
        }.resume()
    }
}

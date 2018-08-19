//
//  Song.swift
//  SV
//
//  Created by Jay Lees on 09/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import Foundation
import UIKit

public class Song: Codable {
    
    // Ignore image from encoding
    enum CodingKeys: String, CodingKey {
        case artist = "artist"
        case songName = "songName"
        case songURL = "songURL"
        case imageURL = "imageURL"
        case imageSize = "imageSize"
        case addedBy = "addedBy"
        case played = "played"
    }
    
    public let artist: String
    public let songName: String
    public let songURL: String
    public let imageURL: String
    public let imageSize: CGSize
    public let played: Bool
    public var image: UIImage?
    public var addedBy: String?
    
    public init (artist: String, songName: String, songURL: String, imageURL: String, imageSize: CGSize, image: UIImage?, addedBy: String?, played: Bool) {
        self.artist = artist
        self.songName = songName
        self.songURL = songURL
        self.imageURL = imageURL
        self.imageSize = imageSize
        self.played = played
        self.image = image
        self.addedBy = addedBy
    }
 
    public func downloadImage(on queue: DispatchQueue, then callback: @escaping (UIImage?) -> Void ) {
        let formattedURL =
            imageURL.replacingOccurrences(of: "{w}", with: "\(200)")
                    .replacingOccurrences(of: "{h}", with: "\(200)")
        
        queue.async {
            do {
                let data = try Data(contentsOf: URL(string: formattedURL)!)
                self.image = UIImage(data: data)
                DispatchQueue.main.async {
                    callback(self.image)
                }
            } catch let error {
                print("Error whilst downloading image - \(error)")
            }
        }
    }

}

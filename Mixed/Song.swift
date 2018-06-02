//
//  Song.swift
//  SV
//
//  Created by Jay Lees on 09/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import Foundation
import UIKit

public class Song {
    public let artist: String
    public let songName: String
    public let songURL: String
    public let imageURL: String
    public let imageSize: CGSize
    public var image: UIImage?
    public var addedBy: String?
    
    init(artist: String, songName: String, songURL: String, imageURL: String, imageSize: CGSize, image: UIImage?){
        self.artist = artist
        self.songName = songName
        self.songURL = songURL
        self.imageURL = imageURL
        self.imageSize = imageSize
        self.image = image
        self.addedBy = nil
    }
    
}

//
//  SongTableViewCell.swift
//  Mixed
//
//  Created by Jay Lees on 25/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var albumArtwork: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title.textColor = UIColor.mixedSecondaryBlue
        subtitle.textColor = UIColor.mixedSecondaryBlue
        
        albumArtwork.layer.cornerRadius = albumArtwork.frame.height / 2
        albumArtwork.clipsToBounds = true
        
        let width = albumArtwork.frame.width * 0.15
        let height = albumArtwork.frame.height * 0.15
        let centerView = UIView(frame: CGRect(x: albumArtwork.frame.width/2 - width/2 , y: albumArtwork.frame.height/2 - height/2, width: width, height: height))
        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = height / 2
        albumArtwork.addSubview(centerView)
    }

}

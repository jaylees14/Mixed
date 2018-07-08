//
//  SongSearchField.swift
//  Mixed
//
//  Created by Jay Lees on 08/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

class SongSearchField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        style()
    }
    
    private func style(){
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.4
        self.leftSpacer = self.frame.height + 10
        self.font = UIFont.mixedFont(size: 16, weight: .regular)
        self.textColor = UIColor.mixedPrimaryBlue
        self.placeholder = "Search"
        self.text = ""
        
        // Add the magnifying glass
        let searchImage = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: self.frame.height, height: self.frame.height)))
        searchImage.backgroundColor = UIColor.blue
        self.addSubview(searchImage)
    }
}

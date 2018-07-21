//
//  SongSearchField.swift
//  Mixed
//
//  Created by Jay Lees on 08/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

public protocol SongSearchDelegate {
    func didRequestSearch(with text: String)
    func didStartSearching()
    func didCancelSearch()
}

class SongSearchField: UITextField {
    public var searchDelegate: SongSearchDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
        self.returnKeyType = .search
        self.autocapitalizationType = .sentences
        self.clearButtonMode = .whileEditing
        
        // Add the magnifying glass
        let searchImage = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: self.frame.height, height: self.frame.height)))
        searchImage.backgroundColor = UIColor.blue
        self.addSubview(searchImage)
    }
}

// MARK: - UITextFieldDelegate
extension SongSearchField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {
            return false
        }
        self.searchDelegate?.didRequestSearch(with: text)
        self.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.searchDelegate?.didCancelSearch()
        return true
    }

    @objc func textFieldDidChange() {
        if self.text?.count == 0 {
            self.searchDelegate?.didCancelSearch()
        } else {
            self.searchDelegate?.didStartSearching()
        }
    }
}

//
//  SongSearchField.swift
//  Mixed
//
//  Created by Jay Lees on 08/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

public protocol SongSearchViewDelegate {
    func currentSearchQuery(_ text: String?)
    func didRequestSearch(with text: String)
    func didStartSearching()
    func didCancelSearch()
}

class SongSearchField: UITextField {
    public var searchDelegate: SongSearchViewDelegate?
    
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
        let searchImage = UIImageView(frame: CGRect(x: self.frame.height / 2 - self.frame.height / 4 , y: self.frame.height / 2 - self.frame.height / 4 , width: self.frame.height/2, height: self.frame.height/2))
        searchImage.image = UIImage(named: "search")
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
            self.searchDelegate?.currentSearchQuery(self.text)
        }
    }
}

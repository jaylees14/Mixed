//
//  UIViewController+MixedNav.swift
//  Mixed
//
//  Created by Jay Lees on 18/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

extension UIViewController {
    func setupNavigationBar(title: String){
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        label.text = title
        label.font = UIFont.mixedFont(size: 18, weight: .bold)
        navigationItem.titleView = label
    }
}

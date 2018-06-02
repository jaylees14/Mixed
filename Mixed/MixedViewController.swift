//
//  MixedViewController.swift
//  Mixed
//
//  Created by Jay Lees on 16/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit

class MixedViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mixedDirtyWhite
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    

    func setupButton(_ button: UIButton, fontSize: CGFloat){
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.white
        button.setTitleColor(.mixedBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        button.layer.shadowColor = UIColor.hexToRGB(hex: "626262")?.cgColor
        button.layer.shadowOffset = CGSize(width: 5, height: 5)
        button.layer.shadowOpacity = 0.2
    }
    
    func setupView(_ view: UIView){
        view.backgroundColor = .mixedBlue
        view.layer.shadowColor = UIColor.hexToRGB(hex: "626262")!.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowPath = CGPath(rect: CGRect(x: view.bounds.origin.x + 10, y: view.bounds.origin.y + 10, width: view.bounds.width - 20, height: view.bounds.height), transform: nil)
    }
    
}

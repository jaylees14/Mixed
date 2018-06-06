//
//  AutoLoginViewController.swift
//  Mixed
//
//  Created by Jay Lees on 29/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import FacebookCore

class AutoLoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mixedBlue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        performSegue(withIdentifier:
            AccessToken.current == nil && UserDefaults.standard.string(forKey: "MixedUserName") == nil
            ? "toLogin"
            : "toMenu", sender: nil)
    }
}

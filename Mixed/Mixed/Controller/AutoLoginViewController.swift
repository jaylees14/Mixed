//
//  AutoLoginViewController.swift
//  Mixed
//
//  Created by Jay Lees on 29/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit

class AutoLoginViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let destination =  CurrentUser.shared.isLoggedIn() ? "toMenu" : "toLogin"
        performSegue(withIdentifier: destination, sender: nil)
    }
}

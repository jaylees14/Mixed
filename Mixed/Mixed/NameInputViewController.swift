//
//  NameInputViewController.swift
//  Mixed
//
//  Created by Jay Lees on 05/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class NameInputViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.mixedBlue
    }
    
    @IBAction func userDidTapSubmit(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else {
            showError(title: "Invalid name", withMessage: "Please enter a valid name in the text field", fromController: self)
            return
        }
        
        UserDefaults.standard.set(name, forKey: "MixedUserName")
        self.performSegue(withIdentifier: "toMainMenu", sender: nil)
    }
    
}

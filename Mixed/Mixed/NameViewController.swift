//
//  NameViewController.swift
//  Mixed
//
//  Created by Jay Lees on 16/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class NameViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    
    // Gradient shared between view controllers
    public var gradient: MixedGradient!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundView.layer.addSublayer(gradient)
        self.nameTextField.backgroundColor = .clear
        self.nameTextField.textColor = UIColor.white
        
        let placeholder = NSAttributedString(string: "Add your name...",
                                             attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        self.nameTextField.attributedPlaceholder = placeholder
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let lineView = LineView(frame: CGRect(x: nameTextField.frame.origin.x, y: nameTextField.frame.origin.y + nameTextField.frame.height - 5, width: nameTextField.frame.width, height: 3))
        view.addSubview(lineView)
        
        let logo = LogoView(center: CGPoint(x: view.center.x, y: 100), scale: 1, isInitiallyHidden: false)
        view.addSubview(logo)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func continueTapped(_ sender: Any) {
        guard let name = nameTextField.text, name.count >= 2 else {
            showError(title: "Enter a valid name", withMessage: "Please enter your name and then tap continue.", fromController: self)
            return
        }
        
        print("Proceeding with name: \(name)")
        self.performSegue(withIdentifier: "toMainMenu", sender: self)
    }
    
    
}

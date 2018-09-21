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
    public var logo: LogoView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundView.layer.addSublayer(gradient)
        self.nameTextField.backgroundColor = .clear
        self.nameTextField.textColor = UIColor.white
        
        let placeholder = NSAttributedString(string: "Add your name...",
                                             attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        self.nameTextField.attributedPlaceholder = placeholder
        self.nameTextField.returnKeyType = .go
        self.nameTextField.delegate = self
        
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapRecogniser)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let lineView = LineView(frame: CGRect(x: nameTextField.frame.origin.x, y: nameTextField.frame.origin.y + nameTextField.frame.height - 5, width: nameTextField.frame.width, height: 3))
        view.addSubview(lineView)
        
        let safeAreaTop = view.safeAreaInsets.top
        logo = LogoView(center: CGPoint(x: view.center.x, y: safeAreaTop + 50), scale: 1, isInitiallyHidden: false)
        view.addSubview(logo)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func dismissKeyboard(){
        self.nameTextField.resignFirstResponder()
    }

    @IBAction func continueTapped(_ sender: Any) {
        guard let name = nameTextField.text, name.count >= 2 else {
            showError(title: "Enter a valid name", message: "Please enter your name and then tap continue.", controller: self)
            return
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.logo.showGradient()
            self.view.backgroundColor = .white
            self.backgroundView.alpha = 0
        }, completion: { _ in
            CurrentUser.shared.setName(name)
            self.performSegue(withIdentifier: "toMainMenu", sender: self)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMainMenu" {
            let destination = segue.destination as! MainMenuViewController
            destination.isFirstLogin = true
        }
    }
}

extension NameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

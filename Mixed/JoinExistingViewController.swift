//
//  JoinExistingViewController.swift
//  Mixed
//
//  Created by Jay Lees on 16/07/2017.
//  Copyright © 2017 Jay Lees. All rights reserved.
//

import UIKit
import Firebase

class JoinExistingViewController: MixedViewController, UITextFieldDelegate {

    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var codeTextField: UITextField!
    @IBOutlet weak var textBackground: UIView!
    var partyProvider: MusicProvider = .appleMusic
    override func viewDidLoad() {
        super.viewDidLoad()
        codeTextField.delegate = self
        setupCodeText()
        setupView(textBackground)
        
        goButton.setTitleColor(.white, for: .normal)
        goButton.layer.cornerRadius = goButton.frame.height/2
        goButton.backgroundColor = .mixedBlue
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard(){
        codeTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        userTappedGo(self)
        return true
    }
    
    func setupCodeText(){
        codeTextField.layer.cornerRadius = 8
        let customPlaceholder = NSMutableAttributedString(string: "Enter Code", attributes: [:])
        customPlaceholder.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.hexToRGB(hex: "909090")!, range: NSRange(location: 0, length: customPlaceholder.length))
        codeTextField.attributedPlaceholder = customPlaceholder
        codeTextField.placeholderRect(forBounds: CGRect(x: 10, y: 0, width: codeTextField.bounds.width - 10, height: codeTextField.bounds.height))
    }
    
    @IBAction func userTappedGo(_ sender: Any) {
        Database.database().reference().child("parties").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshotVal = snapshot.value as? [String:Any]{
                if let val = snapshotVal[self.codeTextField.text!] as? [String:Any]{
                    if val["partyType"] as! String == "AppleMusic"{
                        self.partyProvider = .appleMusic
                    } else {
                       self.partyProvider = .spotify
                    }
                    self.performSegue(withIdentifier: "toQueue", sender: self)
                } else {
                    showError(title: "Error whilst finding party", withMessage: "It seems that a party with this ID doesn't exist. Please try again", fromController: self)
                }
            }
        })
    }
    
    @IBAction func tappedBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toQueue" {
            let dest = segue.destination as! QueueViewController
            dest.partyID = codeTextField.text
            dest.partyProvider = partyProvider
        }
    }
}

//
//  JoinPartyViewController.swift
//  Mixed
//
//  Created by Jay Lees on 31/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class JoinPartyViewController: UIViewController, ARSCNViewDelegate {
    
    private var blurView: UIVisualEffectView!
    private var codeTextField: UITextField!
    
    private var party: Party!
    private var manager = PartyManager()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let infoView = UILabel(frame: CGRect(x: 60,
                                             y: 50,
                                             width: view.frame.width - 120,
                                             height: 45))
        infoView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        infoView.text = "Scan the host device"
        style(infoView)
        view.addSubview(infoView)
        
        blurView = UIVisualEffectView()
        blurView.frame = view.frame
        view.addSubview(blurView)
    
        showPartyCodeEntry()
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapRecogniser)
    }
    
    // MARK: - UI Styling
    private func style(_ label: UILabel, size: CGFloat = 18){
        label.font = UIFont.mixedFont(size: size, weight: .bold)
        label.textColor = UIColor.white
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Actions
    @objc
    private func dismissKeyboard(){
        self.view.subviews.filter({$0 is UITextField}).forEach({$0.resignFirstResponder()})
    }
    
    @objc
    private func continueTapped(){
        dismissKeyboard()
        self.joinParty(with: codeTextField.text!)
    }
    
    @objc
    private func cancelTapped(){
        dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Join Party
    fileprivate func joinParty(with id: String){
        let invalidCharacters: Set<Character> = [".", "#", "$", "[", "]"]
        guard invalidCharacters.isDisjoint(with: id) && id != "" else {
            showError(title: "Invalid party ID", message: "Please enter a valid party ID and try again", controller: self)
            return
        }
        
        Datastore.instance.joinParty(with: id) { (party) in
            guard let party = party else {
                showError(title: "No party found!", message: "No party was found with this ID!", controller: self)
                return
            }
            self.party = party
            SessionManager.shared.setActiveSession(Session(partyID: party.partyID, type: .attendee))
            self.performSegue(withIdentifier: "toPlayer", sender: self)
        }
    }
    
    func showPartyCodeEntry(){
        codeTextField = UITextField(frame: CGRect(x: 30, y: view.frame.height / 2 - 25, width: view.frame.width - 60, height: 50))
        let title = UILabel(frame: CGRect(x: 60, y: 60, width: view.frame.width - 120, height: 64))
        
        let lineView = LineView(frame: CGRect(x: codeTextField.frame.origin.x, y: codeTextField.frame.origin.y + codeTextField.frame.height - 5, width: codeTextField.frame.width, height: 3))
        let placeholder = NSAttributedString(string: "What's the party code?", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
        let button = OnboardingButton(frame: CGRect(x: 100, y: view.frame.height - 150, width: view.frame.width - 200, height: 55))
        button.setTitle("CONTINUE", for: .normal)
        button.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        
        let cancel = UIButton(frame: CGRect(x: 24, y: 75, width: 18, height: 30))
        cancel.setBackgroundImage(UIImage(named: "back")?.tint(color: .white), for: .normal)
        cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        style(title, size: 24)
        title.text = "Enter code to join party"
        title.numberOfLines = 2
        
        codeTextField.font = UIFont.mixedFont(size: 24)
        codeTextField.textColor = UIColor.white
        codeTextField.attributedPlaceholder = placeholder
        codeTextField.returnKeyType = .go
        codeTextField.delegate = self
        codeTextField.autocorrectionType = .no
        codeTextField.autocapitalizationType = .none
        
        self.blurView.effect = UIBlurEffect(style: .dark)
        
        [codeTextField, lineView, title, button, cancel].forEach { v in
            v?.alpha = 1
            view.addSubview(v!)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlayer" {
            let nav = segue.destination as! UINavigationController
            let destination = nav.topViewController as! PartyPlayerViewController
            destination.partyID = party.partyID
            destination.playerType = .attendee
        }
    }
}

extension JoinPartyViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        self.joinParty(with: textField.text!)
        return true
    }
}


func degreesToRadians(_ deg: Float) -> Float {
    return deg * (.pi / 180)
}


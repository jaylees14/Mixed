//
//  PartyCodeViewController.swift
//  Mixed
//
//  Created by Jay Lees on 30/07/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class PartyCodeViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var partyCode: UILabel!
    @IBOutlet weak var joinLabel: UILabel!
    @IBOutlet weak var shareButton: OnboardingButton!
    
    public var party: Party!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.partyCode.text = party.partyID
        self.joinLabel.text = "Join \(party.partyHost)'s party by entering the code above."
        
        setupNavigationBar(title: "Join Party")
        let resized = UIImage(named: "back")?.resize(to: CGSize(width: 13, height: 22))
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(image: resized, style: .plain, target: self, action: #selector(didTapBackArrow))
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.shareButton.layer.borderColor = UIColor.black.cgColor
        self.shareButton.setTitleColor(.black, for: .normal)
    }
    
    // MARK: - Actions
    @objc func didTapBackArrow() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapShare(_ sender: UIButton) {
        let textToShare = """
        Come and join my Mixed party, you can collaborate on the party playlist!
        
        https://jaylees.me/mixed?i=\(party.partyID)&n=\(party.partyHost)
        """
        let share = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        share.popoverPresentationController?.sourceView = sender
        present(share, animated: true, completion: nil)
    }
}

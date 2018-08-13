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
    
    public var party: Party!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.partyCode.text = party.partyID
        self.joinLabel.text = "Join \(party.partyHost)'s party by enter the code above."
        
        setupNavigationBar(title: "Join Party")
        let resized = UIImage(named: "back")?.resize(to: CGSize(width: 13, height: 22))
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(image: resized, style: .plain, target: self, action: #selector(didTapBackArrow))
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        let manager = PartyManager()
        manager.delegate = self
        manager.advertiseParty()
    }
    
    // MARK: - Actions
    @objc func didTapBackArrow() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PartyCodeViewController: PartyManagerDelegate {
    
}

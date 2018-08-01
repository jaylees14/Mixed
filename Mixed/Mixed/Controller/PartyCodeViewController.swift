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
        self.joinLabel.text = "Join \(party.partyHost)'s party by scanning the code."
    }
}

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
    public var gradient: MixedGradient!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundView.layer.addSublayer(gradient)
    }


}

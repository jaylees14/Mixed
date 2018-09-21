//
//  FeedbackTableViewController.swift
//  Mixed
//
//  Created by Jay Lees on 19/08/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation
import SystemServices

class FeedbackTableViewController: UITableViewController {
    @IBOutlet weak var feedbackTextField: UITextField!
    
    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()
    }
    
    @IBAction func didTapSubmit(_ sender: Any) {
        askQuestion(title: "Submit feedback", message: "By submitting feedback you agree to have basic device information collected and stored.", controller: self, acceptCompletion: {
            let system = SystemServices.shared()
            var config = [String : Any]()
            config["device"] = system.systemDeviceTypeFormatted
            config["deviceName"] = system.deviceName
            config["orientation"] = system.deviceOrientation.rawValue
            config["appVersion"] = system.applicationVersion
            config["systemVersion"] = system.systemsVersion
            config["country"] = system.country
            config["username"] = try? CurrentUser.shared.getFullName()
        
            Datastore.instance.submitFeedback(self.feedbackTextField.text!, systemConfig: config)
            self.dismiss(animated: true, completion: nil)
        }, cancelCompletion: nil)
    }
    
}

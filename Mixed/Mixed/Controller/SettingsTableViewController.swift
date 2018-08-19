//
//  SettingsTableViewController.swift
//  Mixed
//
//  Created by Jay Lees on 19/08/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import Foundation

class SettingsTableViewController: UITableViewController {
    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            self.performSegue(withIdentifier: "toFeedback", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Settings"
        case 1: return "Mixed v\(UIApplication.shared.appVersion) (\(UIApplication.shared.appBuild))"
        default: return ""
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

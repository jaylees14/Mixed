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
        tableView.deselectRow(at: indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (0,0):
            // Change Name
            if let currentName = try? CurrentUser.shared.getFullName() {
                showTextFieldAlert(title: "Change Name", message: "Enter your new name below...", placeholder: currentName) { (name) in
                    if name == nil { return }
                    guard name != "" else {
                        showError(title: "Invalid name", message: "Please enter a valid name", controller: self)
                        return
                    }
                    CurrentUser.shared.setName(name!)
                }
            }
        case (1,0):
            self.performSegue(withIdentifier: "toFeedback", sender: self)
            // Feedback
        default:
            return
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Settings"
        case 2: return "Mixed v\(UIApplication.shared.appVersion) (\(UIApplication.shared.appBuild))"
        default: return ""
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    private func showTextFieldAlert(title: String, message: String, placeholder: String, completion: @escaping (_ userInput: String?) -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
            textField.clearButtonMode = .whileEditing
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            let userInput = alertController.textFields?.first?.text
            completion(userInput)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            completion(nil)
        }
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }

}

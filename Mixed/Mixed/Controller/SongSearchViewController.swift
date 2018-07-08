//
//  SongSearchViewController.swift
//  Mixed
//
//  Created by Jay Lees on 27/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class SongSearchViewController: UIViewController {

    @IBOutlet weak var searchField: SongSearchField!
    @IBOutlet weak var tableView: UITableView!
    let fakeData = ["Panic at the Disco", "Ed Sheeran", "Divide", "Happy", "Birthday"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
}

extension SongSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let label = UILabel(frame: CGRect(x: 15, y: 5, width: view.frame.width - 15, height: 40))
        label.text = title(for: section)
        label.font = UIFont.mixedFont(size: 22, weight: .bold)
        label.textColor = UIColor.mixedPrimaryBlue
        
        view.backgroundColor = .white
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        view.backgroundColor = .white
        return view
    }
    
    fileprivate func title(for section: Int) -> String {
        switch section {
        case 0:
            return "Recent Searches"
        case 1:
            return "Suggested"
        default:
            return ""
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 18.0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentSearchCell", for: indexPath) as! RecentSearchTableViewCell
        
        cell.title.text = fakeData[indexPath.row]
        return cell
        
    }
    
    
}

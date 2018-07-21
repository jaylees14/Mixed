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
    var recentSearches: [String] = []
    var suggested: [String] = []
    var searchResults: [String] = []
    var shouldDisplaySearchResults = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        // Demo Data
        recentSearches = ["Panic at the Disco", "Ed Sheeran", "Divide"]
        suggested = ["ABC", "DEF", "GEH"]
        searchResults = []
        
        searchField.searchDelegate = self
        
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //view.addGestureRecognizer(tapRecogniser)
        
        setupNavigationBar(title: "Search")
    }
    
    @objc private func dismissKeyboard(){
        self.searchField.resignFirstResponder()
    }
}

// MARK: - SongSearchDelegate
extension SongSearchViewController: SongSearchDelegate {
    func didRequestSearch(with text: String) {
        print("Did request search \(text)")
    }
    
    func didStartSearching() {
        shouldDisplaySearchResults = true
        tableView.reloadData()
    }
    
    func didCancelSearch() {
        print("CANCEL")
        shouldDisplaySearchResults = false
        tableView.reloadData()
    }
    
    
}

// MARK: - TableView Delegate & Data Source
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
        if shouldDisplaySearchResults {
            return searchResults.count > 0 ? "Results" : ""
        } else {
            switch section {
            case 0:
                return "Recent Searches"
            case 1:
                return "Suggested"
            default:
                return ""
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 18.0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldDisplaySearchResults {
            return searchResults.count
        } else if section == 0 {
            return recentSearches.count
        } else if section == 1 {
            return suggested.count
        }
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return shouldDisplaySearchResults ? 1 : 2
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Will probably need to interate on the cell, based on the type of result?
        let cell = tableView.dequeueReusableCell(withIdentifier: "recentSearchCell", for: indexPath) as! RecentSearchTableViewCell
        
        let cellText: String
        if shouldDisplaySearchResults {
            cellText = searchResults[indexPath.row]
        } else if indexPath.section == 0 {
            cellText = recentSearches[indexPath.row]
        } else if indexPath.section == 1 {
            cellText = suggested[indexPath.row]
        } else {
            cellText = ""
        }
        
        cell.title.text = cellText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedText: String
        if shouldDisplaySearchResults {
            selectedText = searchResults[indexPath.row]
        } else if indexPath.section == 0 {
            selectedText = recentSearches[indexPath.row]
        } else if indexPath.section == 1 {
            selectedText = suggested[indexPath.row]
        } else {
            selectedText = "what"
        }
        
        // Update UI and trigger request
        self.searchField.text = selectedText
        self.searchField.searchDelegate?.didRequestSearch(with: selectedText)
    }
    
}

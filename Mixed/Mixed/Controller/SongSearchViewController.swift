//
//  SongSearchViewController.swift
//  Mixed
//
//  Created by Jay Lees on 27/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class SongSearchViewController: UIViewController {

    @IBOutlet private weak var searchField: SongSearchField!
    @IBOutlet private weak var tableView: UITableView!
    
    private let imageDispatchQueue = DispatchQueue(label: "com.jaylees.mixed-imagedownload")
    
    // Data Sources
    private var recentSearches: [String] = []
    private var suggested: [String] = []
    private var searchResults: [Song] = []
    private var shouldDisplaySearchResults = false
    
    // Party settings
    public var party: Party!
    public var provider: MusicProvider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        // Demo Data
        recentSearches = ["Panic at the Disco", "Ed Sheeran", "Divide"]
        suggested = ["ABC", "DEF", "GEH"]

        provider = MusicProviderFactory.generateMusicProvider(for: party.streamingProvider, with: self)
        
        searchField.searchDelegate = self
        setupNavigationBar(title: "Search")
        let resized = UIImage(named: "back")?.resize(to: CGSize(width: 13, height: 22))
        self.navigationItem.leftBarButtonItem =
            UIBarButtonItem(image: resized, style: .plain, target: self, action: #selector(didTapBackArrow))
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        if !hasNetworkConnection() {
            self.tableView.isHidden = true
        }
    }
    
    @objc private func dismissKeyboard(){
        self.searchField.resignFirstResponder()
    }
    
    @objc private func didTapBackArrow(){
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - MusicProviderDelegate
extension SongSearchViewController: MusicProviderDelegate {
    func queryDidSucceed(_ songs: [Song]) {
        self.searchResults = songs
        self.searchResults.forEach { $0.downloadImage(on: imageDispatchQueue, then: { _ in self.tableView.reloadData() } )}
        tableView.reloadData()
    }
    
    func queryDidFail(_ error: Error) {
        print(error.localizedDescription)
    }
}

// MARK: - SongSearchDelegate
extension SongSearchViewController: SongSearchViewDelegate {
    func didRequestSearch(with text: String) {
        provider.search(for: text)
    }
    
    func didStartSearching() {
        shouldDisplaySearchResults = true
        tableView.reloadData()
    }
    
    func didCancelSearch() {
        shouldDisplaySearchResults = false
        searchResults = []
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
        view.backgroundColor = .clear
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return shouldDisplaySearchResults ? 65 : 45
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if shouldDisplaySearchResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongTableViewCell
            let song = searchResults[indexPath.row]
            cell.title.text = song.songName
            cell.subtitle.text = song.artist
            cell.albumArtwork.image = song.image
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recentSearchCell", for: indexPath) as! RecentSearchTableViewCell
            switch indexPath.section {
            case 0: cell.title.text = recentSearches[indexPath.row]
            case 1: cell.title.text = suggested[indexPath.row]
            default: break
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if shouldDisplaySearchResults {
            Datastore.instance.addSong(song: searchResults[indexPath.row], to: "abcdef")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let selectedText: String
        if indexPath.section == 0 {
            selectedText = recentSearches[indexPath.row]
        } else if indexPath.section == 1 {
            selectedText = suggested[indexPath.row]
        } else {
            return
        }
        
        // Update UI and trigger request
        self.searchField.text = selectedText
        self.shouldDisplaySearchResults = true
        self.searchField.textFieldShouldReturn(searchField)
        tableView.reloadData()
    }
    
}

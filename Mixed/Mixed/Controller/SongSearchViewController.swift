//
//  SongSearchViewController.swift
//  Mixed
//
//  Created by Jay Lees on 27/06/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class SongSearchViewController: UIViewController {
    
    private enum SearchState {
        case standard
        case autocomplete
        case results
    }

    @IBOutlet private weak var searchField: SongSearchField!
    @IBOutlet private weak var tableView: UITableView!
    
    private let imageDispatchQueue = DispatchQueue(label: "com.jaylees.mixed-imagedownload")
    
    // Data Sources
    private var recentSearches: [String] = []
    private var playlists: [Playlist] = []
    private var autocomplete: [String] = []
    private var searchResults: [Song] = []
    private var state: SearchState = .standard
    
    // Party settings
    public var party: Party!
    public var provider: MusicProvider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
       
        provider = MusicProviderFactory.generateMusicProvider(for: party.streamingProvider)
        recentSearches = SearchCacher.getLastThree()
        provider.getPlaylists { (playlists, error) in
            guard error == nil, let playlists = playlists else {
                Logger.log(error!, type: .debug)
                return
            }
            self.playlists = playlists
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        
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

// MARK: - SongSearchDelegate
extension SongSearchViewController: SongSearchViewDelegate {
    func currentSearchQuery(_ text: String?) {
        Autocompleter.getSearchHints(for: text!) { (results) in
            self.autocomplete = results
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func didRequestSearch(with text: String) {
        guard text != "" else { return }
        state = .results
        SearchCacher.cache(song: text)
        provider.search(for: text, callback: { (songs, error) in
            guard error == nil, let songs = songs else {
                Logger.log(error!, type: .error)
                showError(title: "Whoops", message: "Looks like we had a problem trying to connect to our service. Please check your connection and try again.", controller: self)
                return
            }
            self.searchResults = songs
            self.searchResults.forEach { $0.downloadImage(on: self.imageDispatchQueue, then: { _ in self.tableView.reloadData() } )}
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    func didStartSearching() {
        state = .autocomplete
        tableView.reloadData()
    }
    
    func didCancelSearch() {
        state = .standard
        searchResults = []
        recentSearches = SearchCacher.getLastThree()
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
        switch state {
        case .autocomplete:
            return "How about..."
        case .results:
            return searchResults.count > 0 ? "Results" : ""
        case .standard:
            switch section {
            case 0:
                return "Recent Searches"
            case 1:
                return "Your Playlists"
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
        switch state {
        case .autocomplete:
            return autocomplete.count
        case .results:
            return searchResults.count
        case .standard:
            switch section {
            case 0: return recentSearches.count
            case 1: return playlists.count
            default: return 0
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return state == .standard ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch state {
        case .standard: return 45
        case .results: return 65
        case .autocomplete: return 40
        }
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .autocomplete:
            let cell = tableView.dequeueReusableCell(withIdentifier: "recentSearchCell", for: indexPath) as! RecentSearchTableViewCell
            cell.title.text = autocomplete[indexPath.row]
            return cell
        case .results:
            let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongTableViewCell
            let song = searchResults[indexPath.row]
            cell.title.text = song.songName
            cell.subtitle.text = song.artist
            cell.albumArtwork.image = song.image
            return cell
        case .standard:
            let cell = tableView.dequeueReusableCell(withIdentifier: "recentSearchCell", for: indexPath) as! RecentSearchTableViewCell
            switch indexPath.section {
            case 0: cell.title.text = recentSearches[indexPath.row]
            case 1: cell.title.text = playlists[indexPath.row].name
            default: break
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch state {
        case .results:
            Datastore.instance.addSong(song: searchResults[indexPath.row], to: party.partyID)
            self.navigationController?.popViewController(animated: true)
            return
        case .standard:
            let selectedText: String
            if indexPath.section == 0 {
                selectedText = recentSearches[indexPath.row]
            } else if indexPath.section == 1 {
                // TODO: Deal with playlists
//                selectedText = suggested[indexPath.row]
                selectedText = ""
            } else {
                selectedText = ""
            }
            
            // Update UI and trigger request
            self.searchField.text = selectedText
        case .autocomplete:
            let selectedText = autocomplete[indexPath.row]
            self.searchField.text = selectedText
        }
    
        let _ = self.searchField.textFieldShouldReturn(searchField)
        tableView.reloadData()
    }
    
}

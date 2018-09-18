//
//  PlaylistViewController.swift
//  Mixed
//
//  Created by Jay Lees on 18/09/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectAllButton: OnboardingButton!
    
    var selectedPlaylist: Playlist!
    var selectedIndices = Set<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.selectAllButton.layer.borderColor = UIColor.black.cgColor
        self.selectAllButton.setTitleColor(.black, for: .normal)
    }
    
    @IBAction func didTapSelectAll(_ sender: Any) {
        self.selectedIndices.removeAll()
        for i in 0..<selectedPlaylist.songs.count {
            self.selectedIndices.insert(i)
            self.tableView.cellForRow(at: IndexPath(row: i, section: 0))?.accessoryType = .checkmark
        }
    }
}

extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedPlaylist.songs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell") as! SongTableViewCell
        let song = selectedPlaylist.songs[indexPath.row]
        cell.title.text = song.songName
        cell.subtitle.text = song.artist
        cell.albumArtwork.image = song.image
        return cell
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        let label = UILabel(frame: CGRect(x: 15, y: 5, width: view.frame.width - 15, height: 40))
        label.text = "Playlist: \(selectedPlaylist.playlistInfo.name)"
        label.font = UIFont.mixedFont(size: 22, weight: .bold)
        label.textColor = UIColor.mixedPrimaryBlue
        
        view.backgroundColor = .white
        view.addSubview(label)
        return view
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            cell?.accessoryType = .none
            selectedIndices.remove(indexPath.row)
        } else {
            cell?.accessoryType = .checkmark
            selectedIndices.insert(indexPath.row)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

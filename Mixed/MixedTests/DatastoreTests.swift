//
//  DatastoreTests.swift
//  MixedTests
//
//  Created by Jay Lees on 04/09/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import XCTest
@testable import Mixed

class DatastoreTests: XCTestCase {
    class MockDatastoreDelegate: DatastoreDelegate {
        public enum Result {
            case didAddSong(Song)
            case duplicateSongAdded(Song)
            case queueDidChange([Song])
        }
    
        public var result: Result?
        public var expectation: XCTestExpectation?
        
        func didAddSong(_ song: Song) {
            self.result = Result.didAddSong(song)
            expectation?.fulfill()
        }
        
        func duplicateSongAdded(_ song: Song) {
            self.result = Result.duplicateSongAdded(song)
            expectation?.fulfill()
        }
        
        func queueDidChange(songs: [Song]) {
            self.result = Result.queueDidChange(songs)
            expectation?.fulfill()
        }
    }
    
    var mockDelegate: MockDatastoreDelegate!
    var datastore: Datastore!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockDatastoreDelegate()
        datastore = Datastore.instance
    }
    
    override func tearDown() {
        datastore.delegate = nil
        datastore.unsubscribeFromUpdates()
    }

    func testNoDelegate() {
        XCTAssertNil(datastore.delegate)
    }
    
    func testJoinParty(){
        datastore.createNewParty(with: .appleMusic) { (partyID) in
            self.datastore.joinParty(with: partyID, callback: { (party) in
                XCTAssertNotNil(party)
                XCTAssert(party?.streamingProvider == .appleMusic)
                XCTAssert(party?.partyID == partyID)
            })
        }
    }
    
    func testAddSong(){
        let mockSong = Song(artist: "Foo",
                            songName: "Bar",
                            songURL: "https://www.google.com",
                            imageURL: "https://www.google.com/images",
                            imageSize: CGSize(width: 10, height: 10),
                            image: nil,
                            addedBy: "Alice",
                            played: false)
        
        let outcome = expectation(description: "Datastore should alert delegate a new song was added")
        mockDelegate.expectation = outcome
        datastore.delegate = mockDelegate
        datastore.createNewParty(with: .spotify) { (partyID) in
            self.datastore.subscribeToUpdates(for: partyID)
            self.datastore.addSong(song: mockSong, to: partyID)
        }
        
        waitForExpectations(timeout: 10) { (error) in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            guard let result = self.mockDelegate.result else {
                XCTFail("No result found.")
                return
            }
            switch result {
            case .didAddSong(let song):
                XCTAssert(song.artist == mockSong.artist)
                XCTAssert(song.songName == mockSong.songName)
                XCTAssert(song.imageURL == mockSong.imageURL)
                XCTAssert(song.imageSize == mockSong.imageSize)
                XCTAssert(song.addedBy == mockSong.addedBy)
                XCTAssert(song.played == mockSong.played)
                XCTAssert(song.image == mockSong.image)
            default:
                XCTFail("Incorrect delegate method called")
            }
        }
    }
}

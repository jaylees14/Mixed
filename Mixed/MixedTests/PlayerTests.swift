//
//  PlayerTests.swift
//  MixedTests
//
//  Created by Jay Lees on 04/09/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import XCTest
@testable import Mixed

class PlayerTests: XCTestCase {
    class MockDelegate: PlayerDelegate {
        enum Result {
            case playerDidStartPlaying(songID: String?)
            case playerDidChange(state: PlaybackStatus)
            case requestAuth(to: URL)
            case hasValidSession
            case didRecieveError(error: Error)
        }
        
        var result: Result?
        var expectation: XCTestExpectation?
        
        func playerDidStartPlaying(songID: String?) {
            result = Result.playerDidStartPlaying(songID: songID)
            expectation?.fulfill()
        }
        
        func playerDidChange(to state: PlaybackStatus) {
            result = Result.playerDidChange(state: state)
            expectation?.fulfill()
        }
        
        func requestAuth(to url: URL) {
            result = Result.requestAuth(to: url)
            expectation?.fulfill()
        }
        
        func hasValidSession() {
            result = Result.hasValidSession
            expectation?.fulfill()
        }
        
        func didReceiveError(_ error: Error) {
            result = Result.didRecieveError(error: error)
            expectation?.fulfill()
        }
    }
    
    var appleMusicPlayer: AppleMusicPlayer!
    var spotifyPlayer: SpotifyMusicPlayer!
    var mockDelegate: MockDelegate!
    
    override func setUp() {
        super.setUp()
        appleMusicPlayer = AppleMusicPlayer()
        spotifyPlayer = SpotifyMusicPlayer()
        mockDelegate = MockDelegate()
        appleMusicPlayer.setDelegate(mockDelegate)
        spotifyPlayer.setDelegate(mockDelegate)
    }

    
    // MARK: - Valid sessions
    func testAppleMusicSession() {
        if appleMusicPlayer.hasValidSession() {
            XCTAssert(mockDelegate.result == nil)
        }
    }
    
    func testSpotifySession() {
        mockDelegate.expectation = expectation(description: "Valid sessions handled correctly")
        spotifyPlayer.validateSession(for: .attendee)
        waitForExpectations(timeout: 2) { (error) in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            
            guard let result = self.mockDelegate.result else {
                XCTFail("No delegate method was called")
                return
            }
            
            switch result {
            case .requestAuth(to: _):
                XCTAssert(!self.spotifyPlayer.hasValidSession())
            case .hasValidSession:
                XCTAssert(self.spotifyPlayer.hasValidSession())
            default:
                XCTFail("Incorrect delegate method called")
            }
        }
    }
    
    func testAppleMusicNotifyAddSong() {
        mockDelegate.expectation = expectation(description: "Delegate informs subscriber a new song has been enqueued")
        let mockSongOne = Song(artist: "Foo", songName: "Bar", songURL: "Baz", imageURL: "invalid", imageSize: CGSize(width: 10, height: 1), image: nil, addedBy: nil, played: false)
        appleMusicPlayer.enqueue(song: mockSongOne)
        waitForExpectations(timeout: 2) { (error) in
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
            guard let result = self.mockDelegate.result else {
                XCTFail("No delegate method was called")
                return
            }
            switch result {
            case .playerDidStartPlaying(songID: let song):
                XCTAssert(song == mockSongOne.songURL)
            default:
                XCTFail("Incorrect delegate method called")
            }
        }
    }
}

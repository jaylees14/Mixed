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
    }

    func testAppleMusicSession() {
        XCTAssert(appleMusicPlayer.hasValidSession())
    }
    
    func testSpotifySession() {
        XCTAssert(spotifyPlayer.hasValidSession())
    }
    
}

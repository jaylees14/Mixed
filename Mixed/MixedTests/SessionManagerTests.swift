//
//  SessionManagerTests.swift
//  MixedTests
//
//  Created by Jay Lees on 04/09/2018.
//  Copyright © 2018 Jay Lees. All rights reserved.
//

import XCTest
@testable import Mixed

class SessionManagerTests: XCTestCase {
    var sessionManager: SessionManager!
    
    override func setUp() {
        self.sessionManager = SessionManager.shared
        self.sessionManager.clearActiveSession()
    }
    
    func testNoInitialActiveSession() {
        XCTAssert(!self.sessionManager.hasActiveSession())
    }
    
    func testCreateSession(){
        let mockSession = Session(partyID: "abcdef", type: .attendee)
        self.sessionManager.setActiveSession(mockSession)
        
        XCTAssert(sessionManager.hasActiveSession())
        XCTAssert(sessionManager.getActiveSession().partyID == mockSession.partyID)
        XCTAssert(sessionManager.getActiveSession().type == mockSession.type)
        
        self.sessionManager.clearActiveSession()
        XCTAssert(!sessionManager.hasActiveSession())
    }
}

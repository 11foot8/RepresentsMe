//
//  OfficialScraperTests.swift
//  RepresentsMeTests
//
//  Created by Michael Tirtowidjojo on 2/22/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import XCTest
@testable import RepresentsMe

class OfficialScraperTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    /// Test successful scraping of data
    func testScrapingData() {
        var error:ParserError?
        var officials:[Official]?
        
        // Make the request
        let expectation = self.expectation(description: "Scraping")
        do {
            try OfficialScraper.getForAddress(
                address: "2317 Speedway, Austin, TX 78712",
                apikey: civi_api_key) { o, e in
                    error = e
                    officials = o
                    expectation.fulfill()
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertNil(error)
        XCTAssertNotNil(officials)
        
        // Check that each Official is correct
        let expectedOfficials = OfficialScraperTestsData.expectedOfficials
        XCTAssertEqual(officials!.count, expectedOfficials.count)
        for (actual, expected) in zip(officials!, expectedOfficials) {
            XCTAssertEqual(actual, expected,
                           "\n" + actual.repr() + "\n" + expected.repr())
        }
    }
    
    /// Test that an error is received if an invalid address is given
    func testInvalidAddress() {
        var error:ParserError?
        var officials:[Official]?
        
        // Make the request
        let expectation = self.expectation(description: "Scraping")
        do {
            try OfficialScraper.getForAddress(
                address: "invalid",
                apikey: civi_api_key) { o, e in
                    error = e
                    officials = o
                    expectation.fulfill()
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        waitForExpectations(timeout: 10, handler: nil)
        XCTAssertNotNil(error)
        XCTAssertNil(officials)
    }
}

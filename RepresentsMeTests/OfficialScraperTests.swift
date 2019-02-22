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
        let result = makeRequest(address: "2317 Speedway, Austin, TX 78712",
                                 apikey: civic_api_key)
        let officials = result.0
        let error = result.1
        
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
        let result = makeRequest(address: "invalid", apikey: civic_api_key)
        let officials = result.0
        let error = result.1
        
        XCTAssertNotNil(error)
        XCTAssertNil(officials)
    }
    
    /// Test that an error is received if an invalid api key is given
    func testInvalidAPIKey() {
        let result = makeRequest(address: "2317 Speedway, Austin, TX 78712",
                                 apikey: "invalid")
        let officials = result.0
        let error = result.1
        
        XCTAssertNotNil(error)
        XCTAssertNil(officials)
    }
    
    /// Test that an error is thrown if a division is missing a name
    func testDivisionMissingName() {
        let json = OfficialScraperTestsData.invalid_division_json_string
        let data:Data = json.data(using: .utf8)!
        do {
            let _ = try JSONDecoder().decode(JSONDivision.self, from: data)
            XCTFail("Did not throw a ParserError.missingRequiredFieldError")
        } catch ParserError.missingRequiredFieldError(let message) {
            XCTAssertEqual(message, "JSONDivision missing required field 'name'")
        } catch {
            XCTFail("Did not throw a ParserError.missingRequiredFieldError")
        }
    }
    
    /// Test that an error is thrown if an office is missing a name
    func testOfficeMissingName() {
        let json = OfficialScraperTestsData.invalid_office_json_string
        let data:Data = json.data(using: .utf8)!
        do {
            let _ = try JSONDecoder().decode(JSONOffice.self, from: data)
            XCTFail("Did not throw a ParserError.missingRequiredFieldError")
        } catch ParserError.missingRequiredFieldError(let message) {
            XCTAssertEqual(message, "JSONOffice missing required field 'name'")
        } catch {
            XCTFail("Did not throw a ParserError.missingRequiredFieldError")
        }
    }
    
    /// Test that an error is thrown if an official is missing a name
    func testOfficialMissingName() {
        let json = OfficialScraperTestsData.invalid_official_json_string
        let data:Data = json.data(using: .utf8)!
        do {
            let _ = try JSONDecoder().decode(JSONOfficial.self, from: data)
            XCTFail("Did not throw a ParserError.missingRequiredFieldError")
        } catch ParserError.missingRequiredFieldError(let message) {
            XCTAssertEqual(message, "JSONOfficial missing required field 'name'")
        } catch {
            XCTFail("Did not throw a ParserError.missingRequiredFieldError")
        }
    }
    
    /// Makes the request.
    ///
    /// - Parameter address:    The address to request for
    /// - Parameter apikey:     The apikey to use
    ///
    /// - Returns: a tuple with the resulting Officials and errors if any
    func makeRequest(address:String, apikey:String,
                     timeout:Double = 10) -> ([Official]?, ParserError?) {
        var error:ParserError?
        var officials:[Official]?
        
        // Make the request
        let expectation = self.expectation(description: "Scraping")
        do {
            try OfficialScraper.getForAddress(
                address: address,
                apikey: apikey) { o, e in
                    error = e
                    officials = o
                    expectation.fulfill()
            }
        } catch {
            return (officials, error as? ParserError)
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
        return (officials, error)
    }
}

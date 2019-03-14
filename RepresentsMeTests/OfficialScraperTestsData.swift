//
//  OfficialScraperTestsData.swift
//  RepresentsMeTests
//
//  Created by Michael Tirtowidjojo on 2/22/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
@testable import RepresentsMe

class OfficialScraperTestsData {

    // The JSON string for testDivisionMissingName()
    static let invalid_division_json_string =
        """
        {
        "ocd-division/country:us/state:tx": {
           "officeIndices": [
            2,
            4,
            5,
            7,
            8,
            9,
            10,
            11
           ]
          }
        }
        """
    
    // The JSON string for testOfficeMissingName()
    static let invalid_office_json_string =
        """
        {
          "divisionId": "ocd-division/country:us",
          "levels": [
           "country"
          ],
          "roles": [
           "headOfState",
           "headOfGovernment"
          ],
          "officialIndices": [
           0
          ]
        }
        """
    
    // The JSON string for testOfficialMissingaName()
    static let invalid_official_json_string =
        """
        {
           "address": [
            {
             "line1": "The White House",
             "line2": "1600 Pennsylvania Avenue NW",
             "city": "Washington",
             "state": "DC",
             "zip": "20500"
            }
           ],
           "party": "Republican Party",
           "phones": [
            "(202) 456-1111"
           ],
           "urls": [
            "http://www.whitehouse.gov/"
           ],
           "photoUrl": "https://www.whitehouse.gov/sites/whitehouse.gov/files/images/45/PE%20Color.jpg",
           "channels": [
            {
             "type": "GooglePlus",
             "id": "+whitehouse"
            },
            {
             "type": "Facebook",
             "id": "whitehouse"
            },
            {
             "type": "Twitter",
             "id": "potus"
            },
            {
             "type": "YouTube",
             "id": "whitehouse"
            }
           ]
        }
        """
}

/// Extend Official with hardcoded values for creating officials when testing
extension Official {

    /// Creates an Official given the values for each field.
    ///
    /// - Parameter index:          The index of the official
    /// - Parameter name:           The name of the official
    /// - Parameter photoURL:       The URL to the photo of the official
    /// - Parameter party:          The political party of the official
    /// - Parameter addresses:      An Array of addresses for the official
    /// - Parameter phones:         An Array of phone numbers for the official
    /// - Parameter emails:         An Array of emails for the official
    /// - Parameter urls:           An Array of URLs for the official
    /// - Parameter socialMedia:    An Array of social media accounts
    /// - Parameter office:         The name of the official's office
    /// - Parameter division:       The name of the office's division
    convenience init(_ index:Int, _ name:String, _ photoURL:String,
                     _ party:String, _ addresses:[[String: String]],
                     _ phones:[String], _ urls:[String], _ emails:[String],
                     _ socialMedia:[[String: String]], _ office:String,
                     _ division:String) {
        self.init()
        self.index = index
        self.name = name
        self.photoURL = URL(string: photoURL)
        self.party = PoliticalParty.determine(for: party)
        self.addresses = addresses
        self.phones = phones
        self.emails = emails
        self.urls = urls.map {URL(string: $0)}
        self.socialMedia = socialMedia
        self.office = office
        self.division = division
    }
}

//
//  Official.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 2/21/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit

/// Class containing the information avaliable for a government official.
class Official: Equatable, CustomStringConvertible {
    var index:Int                       // The order of the official. Closer to
                                        // zero means covers larger population
    var name:String                     // The name of the official
    var photo:UIImage?                  // The cached photo of the official
    var photoURL:URL?                   // The photo url of the official
    var party:String                    // The political party of the official
    var addresses:[[String: String]]    // The addresses for the official
    var phones:[String]                 // The phones for the official
    var urls:[URL?]                     // The urls for the official
    var emails:[String]                 // The emails for the official
    var socialMedia:[[String: String]]  // The social media profiles
    var office:String                   // The name of the official's office
    var division:String                 // The name of the official's division

    var description:String {            // Returns textual representation of the
        return repr()                   // official. Conforms class to
    }                                   // CustomStringConvertible protocol.
    
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
    init(_ index:Int, _ name:String, _ photoURL:String, _ party:String,
         _ addresses:[[String: String]], _ phones:[String], _ urls:[String],
         _ emails:[String], _ socialMedia:[[String: String]],
         _ office:String, _ division:String) {
        self.index = index
        self.name = name
        self.photoURL = URL(string: photoURL)
        self.party = party
        self.addresses = addresses
        self.phones = phones
        self.emails = emails
        self.urls = urls.map {URL(string: $0)}
        self.socialMedia = socialMedia
        self.office = office
        self.division = division
    }
    
    /// Builds an Official
    ///
    /// - Parameter index:      the index of this Official in the JSON
    /// - Parameter division:   the division information for this Official
    /// - Parameter office:     the office information for this Official
    /// - Parameter official:   the information for this Official
    init(index:Int, division:JSONDivision, office:JSONOffice,
         official:JSONOfficial) {
        self.index = index
        self.name = official.name
        self.photoURL = URL(string: official.photoUrl)
        self.party = official.party
        self.addresses = official.address
        self.phones = official.phones
        self.urls = official.urls.map{URL(string: $0)}
        self.emails = official.emails
        self.socialMedia = official.channels
        self.office = office.name
        self.division = division.name
    }
    
    /// Get a String representation of this Official
    ///
    /// - Returns: the representation
    public func repr() -> String {
        return "<Official " +
            "\(self.index)," +
            "\(self.name)," +
            "\(self.photoURL?.absoluteString ?? "")," +
            "\(self.party)," +
            "\(self.addresses)," +
            "\(self.phones)," +
            "\(self.urls)," +
            "\(self.emails)," +
            "\(self.socialMedia)," +
            "\(self.office)," +
            "\(self.division)," +
        "/>"
    }
    
    /// Factory method to build Officials given the JSON data
    ///
    /// - Parameter data:   the JSONData with the divisions, offices, and
    ///                     officials
    ///
    /// - Returns: an Array of Officials sorted based on their index
    public static func buildOfficials(data:JSONData) -> [Official] {
        var officials:[Official] = []
        
        // JSONDivisions have an Array of the indices of JSONOffices that belong
        // in that division and JSONOfficies have an Array of indices of
        // JSONOfficials that are in that office.
        for (_, division) in data.divisions {
            for officeIndex in division.officeIndices {
                let office = data.offices[officeIndex]
                for officialIndex in office.officialIndices {
                    officials.append(
                        Official(index: officialIndex,
                                 division: division,
                                 office: office,
                                 official: data.officials[officialIndex]))
                }
            }
        }
        
        // Sort based on the index of each Official
        return officials.sorted(by: {(lhs:Official, rhs:Official) -> Bool in
            lhs.index < rhs.index
            
        })
    }
    
    /// Checks if two Officials are equal.
    /// Two Officials are equal if all of their fields are equal.
    ///
    /// - Parameter lhs: an Official to check
    /// - Parameter rhs: an Official to check
    ///
    /// - Returns: true if all fields in lhs equal the fields in rhs, false
    ///            otherwise.
    static func == (lhs: Official, rhs: Official) -> Bool {
        return (
            lhs.index == rhs.index &&
            lhs.name == rhs.name &&
            lhs.photoURL == rhs.photoURL &&
            lhs.party == rhs.party &&
            lhs.addresses == rhs.addresses &&
            lhs.phones == rhs.phones &&
            lhs.urls == rhs.urls &&
            lhs.emails == rhs.emails &&
            lhs.socialMedia == rhs.socialMedia &&
            lhs.office == rhs.office &&
            lhs.division == rhs.division
        )
    }

    /// Returns Official's photo
    ///
    /// - Parameter completion:     the completion handler to use to return the
    ///                             downloaded photo.
    public func getPhoto (completion: @escaping (Official, UIImage?) -> ()) {

        // If the photo has been cached, return the cached photo
        if let photo = photo {
            return completion(self, photo)
        }

        DispatchQueue.global(qos: .background).async {
            if let photoURL = self.photoURL {
                
                // TODO: Handle Data error
                let data = try? Data(contentsOf: photoURL)
                
                if let imageData = data {
                    self.photo = UIImage(data: imageData)
                } else {
                    // If the photo does not exist or could not be downloaded,
                    // set photo to empty
                    self.photo = UIImage()
                }

                completion(self, self.photo)
            }
        }
    }
}

//
//  Official.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 2/21/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import UIKit

let DEFAULT_NOT_LOADED = UIImage.fontAwesomeIcon(
    name: .userCircle,
    style: .solid,
    textColor: .gray,
    size: PORTRAIT_SIZE)

/// Class containing the information avaliable for a government official.
class Official: Equatable, CustomStringConvertible {
    var index:Int                       // The order of the official. Closer to
                                        // zero means covers larger population
    var name:String                     // The name of the official
    var photo:UIImage?                  // The cached photo of the official
    var photoURL:URL?                   // The photo url of the official
    var party:PoliticalParty            // The political party of the official
    var addresses:[Address]    // The addresses for the official
    var phones:[String]                 // The phones for the official
    var urls:[URL?]                     // The urls for the official
    var emails:[String]                 // The emails for the official
    var facebookURL:URL?                // The official's Facebook account
    var twitterURL:URL?                 // The official's Twitter account
    var youtubeURL:URL?                 // The official's YouTube account
    var office:String                   // The name of the official's office
    var division:String                 // The name of the official's division
    var divisionOCDID:String            // The ID of the official's division

    var description:String {            // Returns textual representation of the
        return repr()                   // official. Conforms class to
    }                                   // CustomStringConvertible protocol.
    
    init() {
        self.index = -1
        self.name = ""
        self.party = PoliticalParty.unknown
        self.addresses = []
        self.phones = []
        self.urls = []
        self.emails = []
        self.office = ""
        self.division = ""
        self.divisionOCDID = ""
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
        self.party = PoliticalParty.determine(for: official.party)
        self.addresses = official.address.map({Address(with: $0)})
        self.phones = official.phones
        self.urls = official.urls.map{URL(string: $0)}
        self.emails = official.emails
        for dict in official.channels {
            if (facebookURL == nil && dict["type"] == "Facebook") {
                facebookURL = URL(string: "http://www.facebook.com/\(dict["id"]!)")
            } else if (twitterURL == nil && dict["type"] == "Twitter") {
                twitterURL = URL(string: "http://www.twitter.com/\(dict["id"]!)")
            } else if (youtubeURL == nil && dict["type"] == "YouTube") {
                youtubeURL = URL(string: "http://www.youtube.com/\(dict["id"]!)")
            }
        }
        self.office = office.name
        self.division = division.name
        self.divisionOCDID = office.divisionId
        self.photo = DEFAULT_NOT_LOADED
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
            "\(self.facebookURL?.absoluteString ?? "")," +
            "\(self.twitterURL?.absoluteString ?? "")," +
            "\(self.youtubeURL?.absoluteString ?? "")," +
            "\(self.office)," +
            "\(self.division)," +
            "\(self.divisionOCDID)" +
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
            lhs.facebookURL == rhs.facebookURL &&
            lhs.twitterURL == rhs.twitterURL &&
            lhs.twitterURL == rhs.twitterURL &&
            lhs.office == rhs.office &&
            lhs.division == rhs.division &&
            lhs.divisionOCDID == rhs.divisionOCDID
        )
    }

    /// Returns Official's photo
    ///
    /// - Parameter completion:     the completion handler to use to return the
    ///                             downloaded photo.
    public func getPhoto (completion: @escaping (Official, UIImage?) -> ()) {
        // If the photo has been cached, return the cached photo
        if photo != DEFAULT_NOT_LOADED {
            return completion(self, photo)
        }

        if let photoURL = photoURL,
            let image = AppState.imageCache.object(
                forKey: NSString(string: photoURL.absoluteString)) {
            self.photo = image
            return completion(self, self.photo)
        }

        DispatchQueue.global(qos: .background).async {
            if let photoURL = self.photoURL {
                if let imageData = try? Data(contentsOf: photoURL) {
                    if let image = UIImage(data: imageData) {
                        AppState.imageCache.setObject(
                            image, forKey: NSString(string: photoURL.absoluteString))
                        self.photo = image
                    }

                    return completion(self, self.photo)
                }
            }
            
            // If the photo does not exist or could not be downloaded,
            // set photo to empty
            self.photo = self.party.image

            return completion(self, self.photo)
        }
    }
}

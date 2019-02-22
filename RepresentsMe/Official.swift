//
//  Official.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 2/21/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

/// Class containing the information avaliable for a government official.
class Official {
    var index:Int                       // The order of the official. Closer to
                                        // zero means covers larger population
    var name:String                     // The name of the official
    var photoURL:String                 // The photo url of the official
    var party:String                    // The political party of the official
    var addresses:[[String :String]]    // The addresses for the official
    var phones:[String]                 // The phones for the official
    var urls:[String]                   // The urls for the official
    var socialMedia:[[String: String]]  // The social media profiles
    var office:String                   // The name of the official's office
    var division:String                 // The name of the official's division
    
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
        self.photoURL = official.photoUrl
        self.party = official.party
        self.addresses = official.address
        self.phones = official.phones
        self.urls = official.urls
        self.socialMedia = official.channels
        self.office = office.name
        self.division = division.name
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
}

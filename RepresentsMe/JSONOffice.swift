//
//  JSONOffice.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 2/21/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

/// Struct to represent an office listed in the JSON string. Used to build
/// Office objects.
struct JSONOffice: Decodable {
    var name:String             // The name of the office
    var divisionId:String       // The division of the office
    var levels:[String]         // The levels covered by the office
    var roles:[String]          // The roles covered by the office
    var officialIndices:[Int]   // The officials that belong in this office
    
    /// CodingKeys for decoding into an Office
    enum CodingKeys: String, CodingKey {
        case name
        case divisionId
        case levels
        case roles
        case officialIndices
    }
    
    /// Decodes the JSON for this Office defaulting attributes that are not
    /// present as keys in the JSON string.
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if values.contains(.name) {
            self.name = try values.decode(String.self, forKey: .name)
        } else {
            self.name = ""
            // TODO: raise error
        }
        
        if values.contains(.divisionId) {
            self.divisionId = try values.decode(String.self, forKey: .divisionId)
        } else {
            self.divisionId = ""
        }
        
        if values.contains(.levels) {
            self.levels = try values.decode([String].self, forKey: .levels)
        } else {
            self.levels = []
        }
        
        if values.contains(.roles) {
            self.roles = try values.decode([String].self, forKey: .roles)
        } else {
            self.roles = []
        }
        
        if values.contains(.officialIndices) {
            self.officialIndices = try values.decode([Int].self,
                                                     forKey: .officialIndices)
        } else {
            self.officialIndices = []
        }
    }
}

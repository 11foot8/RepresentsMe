//
//  JSONOfficial.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 2/21/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

/// Struct to represent an official from the JSON string. Used to build
/// Official objects.
struct JSONOfficial: Decodable {
    var name:String                     // The name of the offical
    var photoUrl:String                 // URL to photo
    var party:String                    // The party of the official
    var address:[[String: String]]      // Array of addresses for the official
    var phones:[String]                 // Array of phones for the official
    var urls:[String]                   // Array of urls for the official
    var channels:[[String: String]]     // Array of social media for the offical
    
    /// CodingKeys for decoding into an official
    enum CodingKeys: String, CodingKey {
        case name
        case photoUrl
        case address
        case party
        case phones
        case urls
        case channels
    }
    
    /// Decodes the JSON for this Official defaulting attributes that are not
    /// present as keys in the JSON string.
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if values.contains(.name) {
            self.name = try values.decode(String.self, forKey: .name)
        } else {
            // TODO: raise error
            self.name = ""
        }
        
        if values.contains(.photoUrl) {
            self.photoUrl = try values.decode(String.self, forKey: .photoUrl)
        } else {
            self.photoUrl = ""
        }
        
        if values.contains(.party) {
            self.party = try values.decode(String.self, forKey: .party)
        } else {
            self.party = ""
        }
        
        if values.contains(.address) {
            self.address = try values.decode([[String: String]].self,
                                             forKey: .address)
        } else {
            self.address = []
        }
        
        if values.contains(.phones) {
            self.phones = try values.decode([String].self, forKey: .phones)
        } else {
            self.phones = []
        }
        
        if values.contains(.urls) {
            self.urls = try values.decode([String].self, forKey: .urls)
        } else {
            self.urls = []
        }
        
        if values.contains(.channels) {
            self.channels = try values.decode([[String: String]].self,
                                              forKey: .channels)
        } else {
            self.channels = []
        }
    }
}

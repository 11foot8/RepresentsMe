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
    var name:String = ""                     // The name of the offical
    var photoUrl:String = ""                 // URL to photo
    var party:String = ""                    // The party of the official
    var address:[[String: String]] = []      // Array of addresses
    var phones:[String] = []                 // Array of phones for the official
    var urls:[String] = []                   // Array of urls for the official
    var emails:[String] = []                 // Array of emails for the official
    var channels:[[String: String]] = []     // Array of social media accounts
    
    /// CodingKeys for decoding into an official
    enum CodingKeys: String, CodingKey {
        case name
        case photoUrl
        case address
        case party
        case phones
        case urls
        case emails
        case channels
    }
    
    /// Decodes the JSON for this Official defaulting attributes that are not
    /// present as keys in the JSON string.
    ///
    /// - Throws: ParserError.missingRequiredField if name is not present.
    init(from decoder: Decoder) throws {
        let values = try decodeContainer(decoder: decoder)
        
        if values.contains(.name) {
            self.name = try values.decode(String.self, forKey: .name)
        } else {
            throw ParserError.missingRequiredFieldError(
                "JSONOfficial missing required field 'name'")
        }
        
        if values.contains(.photoUrl) {
            self.photoUrl = try values.decode(String.self, forKey: .photoUrl)
        }
        
        if values.contains(.party) {
            self.party = try values.decode(String.self, forKey: .party)
        }
        
        if values.contains(.address) {
            self.address = try values.decode([[String: String]].self,
                                             forKey: .address)
        }
        
        if values.contains(.phones) {
            self.phones = try values.decode([String].self, forKey: .phones)
        }
        
        if values.contains(.urls) {
            self.urls = try values.decode([String].self, forKey: .urls)
        }
        
        if values.contains(.emails) {
            self.emails = try values.decode([String].self, forKey: .emails)
        }
        
        if values.contains(.channels) {
            self.channels = try values.decode([[String: String]].self,
                                              forKey: .channels)
        }
    }
    
    /// Decodes the JSON into a container converting any thrown errors into
    /// a ParserError.
    ///
    /// - Parameter decoder:    the decoder to use
    ///
    /// - Returns: the KeyedDecodingContainer
    ///
    /// - Throws: ParserError.decodeError if failed to decode
    private func decodeContainer(decoder:Decoder) throws ->
        KeyedDecodingContainer<CodingKeys> {
            do {
                return try decoder.container(keyedBy: CodingKeys.self)
            } catch {
                throw ParserError.decodeError(error.localizedDescription)
            }
    }
}

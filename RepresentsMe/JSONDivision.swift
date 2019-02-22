//
//  JSONDivision.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 2/21/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

/// Struct to represent a division listed in the JSON string. Used to build
/// Division objects.
struct JSONDivision: Decodable {
    var name:String = ""          // The name of the division
    var officeIndices:[Int] = []  // The offices that belong in this division
    
    /// CodingKeys for decoding into a Division
    enum CodingKeys: String, CodingKey {
        case name
        case officeIndices
    }
    
    /// Decode the JSON for this Division defaulting attributes that are not
    /// present as keys in the JSON string.
    ///
    /// - Throws: ParserError.missingRequiredField if name is not present.
    init(from decoder: Decoder) throws {
        let values = try decodeContainer(decoder: decoder)
        
        if values.contains(.name) {
            self.name = try values.decode(String.self, forKey: .name)
        } else {
            throw ParserError.missingRequiredFieldError(
                "JSONDivision missing required field 'name'")
        }
        
        if values.contains(.officeIndices) {
            self.officeIndices = try values.decode([Int].self,
                                                   forKey: .officeIndices)
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

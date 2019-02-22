//
//  ParserErrors.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 2/21/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

/// Errors that can be thrown when parsing the API JSON
enum ParserError: Error {
    /// Thrown when the argument given to use in the request is invalid.
    case invalidArgumentError(String)
    
    /// Thrown when failed to decode the JSON string.
    case decodeError(String)
    
    /// Thrown when failed to make the request.
    case requestFailed(String)
}

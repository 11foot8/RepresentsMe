//
//  OfficialScraper.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 2/21/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation

/// Handles scraping the API and parsing the results into Official objects.
///
/// Example:
///
/// try OfficialScraper.getForAddress(
///     address: "my address", apikey: "my apikey") { officials, error in
///
///     if error == nil {
///         // Do stuff
///     }
/// }
class OfficialScraper {
    
    // The URL to request data from
    private static let url:String = "https://www.googleapis.com/civicinfo/v2/" +
        "representatives"
    
    /// Makes the request to get the Officials for the given address.
    ///
    /// - Parameter address:        The address to request the Officials of.
    /// - Parameter apikey:         The apikey to make the request with.
    /// - Parameter completion:     the completion handler to use to return the
    ///                             parsed Officials.
    ///
    /// - Throws: ParseError.invalidArgumentError if address cannot be formatted
    ///           as a URL query argument.
    public static func getForAddress(
        address:String,
        apikey:String,
        completion: @escaping ([Official]?, Error?) -> ()) throws {
        
        // TODO: remove, For commandline
        let runLoop = CFRunLoopGetCurrent()
        
        // Build the request
        let url = URL(string: try buildURL(address: address, apikey: apikey))
        let request:URLRequest = URLRequest(url: url!)
        
        // Make the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                // TODO: remove, for commandline
                CFRunLoopStop(runLoop)
                
                // Error occurred, abort
                return completion(nil, ParserError.requestFailed(
                    error?.localizedDescription ?? "Request failed."))
            }
            
            // TODO: remove, for commandline
            CFRunLoopStop(runLoop)
            
            do {
                // Try to parse the JSON
                let jsonData = try parseJSON(data: data!)
                return completion(Official.buildOfficials(data: jsonData), nil)
            } catch {
                // Error occurred while parsing JSON
                return completion(nil, error)
            }
        }.resume()
    }
    
    /// Builds the url to use to make the request.
    ///
    /// - Parameter address: the address to request for
    /// - Parameter apikey:  the apikey to use
    ///
    /// - Returns: the formated url
    ///
    /// - Throws: ParserError.invalidArgumentError if address cannot be
    ///           formatted for a URL query argument
    private static func buildURL(address:String,
                                 apikey:String) throws -> String {
        guard let formattedAddress = formatArg(arg: address) else {
            throw ParserError.invalidArgumentError(
                "Invalid argument \(address)")
        }
        
        return "\(OfficialScraper.url)?address=\(formattedAddress)&key=\(apikey)"
    }
    
    /// Formats the given argument to use as a query parameter in the request
    ///
    /// - Parameter arg: The argument to format
    ///
    /// - Returns: the formated argument
    private static func formatArg(arg:String) -> String? {
        return arg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    /// Parses the JSON string into a JSONData object.
    ///
    /// - Parameter data: the JSON data to parse
    ///
    /// - Returns: the JSONData object
    ///
    /// - Throws: ParserError.decodeError if failed to decode the JSON
    private static func parseJSON(data: Data) throws -> JSONData {
        do {
            return try JSONDecoder().decode(JSONData.self, from: data)
        } catch {
            throw ParserError.decodeError(error as! String)
        }
    }
}

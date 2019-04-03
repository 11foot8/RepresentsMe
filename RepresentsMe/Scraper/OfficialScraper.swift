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
    public static func getForAddress(
        address:Address,
        apikey:String,
        completion: @escaping ([Official]?, ParserError?) -> ()) {

        // Build the request
        var urlString:String? = nil
        do {
            urlString = try OfficialScraper.buildURL(
                address: address.description, apikey: apikey)
        } catch {
            // Failed to build the url, return an empty Array
            return completion([], nil)
        }

        let url = URL(string: urlString!)
        let request:URLRequest = URLRequest(url: url!)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                // Error occurred, abort
                return completion([], nil)
            }
            
            do {
                // Try to parse the JSON
                let jsonData = try parseJSON(data: data!)
                return completion(Official.buildOfficials(data: jsonData), nil)
            } catch {
                // Error occurred while parsing JSON, return an empty Array
                return completion([], nil)
            }
        }.resume()
    }
    
    /// Gets an official by their name and division ID
    ///
    /// - Parameter with:           the official's name
    /// - Parameter from:           the division ID
    /// - Parameter apikey:         the api key
    /// - Parameter completion:     the completion handler
    public static func getOfficial(
        with name:String,
        from divisionOCID:String,
        apikey:String,
        completion: @escaping (Official?, ParserError?) -> ()) {
        
        // Build the request
        var urlString:String? = nil
        do {
            urlString = try OfficialScraper.buildURL(
                division: divisionOCID, apikey: apikey)
        } catch {
            return completion(nil, nil)
        }
        let url = URL(string: urlString!)
        let request:URLRequest = URLRequest(url: url!)
        
        // Make the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                // Error occuroed, abort
                return completion(nil, nil)
            }
            
            do {
                // Try to parse the JSON
                let jsonData = try parseJSON(data: data!)
                let officials = Official.buildOfficials(data: jsonData)
                
                // Find the official with the given name
                for official in officials {
                    if official.name == name {
                        return completion(official, nil)
                    }
                }
                
                // Did not find the official
                return completion(nil, nil)
            } catch {
                // Error occurred while parsing JSON, return an empty Array
                return completion(nil, nil)
            }
        }.resume()
    }

    /// Builds the url to use to request officials by address.
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
    
    /// Builds hte url to use to request officials by division.
    ///
    /// - Parameter division:   the division to request for
    /// - Parameter apikey:     the apikey to use
    ///
    /// - Returns: the formatted url
    ///
    /// - Throws: ParserError.invalidArgumentError if division cannot be
    ///           formatted for a URL argument
    private static func buildURL(division:String,
                                 apikey:String) throws -> String {
        guard let formattedDivision = formatArg(arg: division) else {
            throw ParserError.invalidArgumentError(
                "Invalid argument \(division)")
        }
        
        return "\(OfficialScraper.url)/\(formattedDivision)?key=\(apikey)"
    }
    
    /// Formats the given argument to use as a query parameter in the request
    ///
    /// - Parameter arg: The argument to format
    ///
    /// - Returns: the formated argument
    private static func formatArg(arg:String) -> String? {
        return arg.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
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
            throw ParserError.decodeError(error.localizedDescription)
        }
    }
}

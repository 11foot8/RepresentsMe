//
//  Util.swift
//  
//
//  Created by Jacob Hausmann on 4/9/19.
//

import Foundation

class Util {
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    /// Reasons an address can be valid or invalid
    enum AddressError: Error {
        case incompleteStreetAddress
        case incompleteCity
        case incompleteState
        case incompleteZipcode
        case invalidStreetAddress
        case invalidCity
        case invalidState
        case invalidZipcode
        case invalidCountry
        case invalid

        var localizedDescription: String {
            switch self {
            default:
                return NSLocalizedString("AddressError", comment: "An unexpected error occured")
            }
        }
    }

    /// Checks that the address returns a full address when reverse geocoded
    /// and that city, state, and zipcode match
    static func isValidAddress(_ address:Address, completion: @escaping (AddressError?) -> ()) {
        // TODO: Check all fields are complete
        guard !address.streetAddress.isEmpty else {
            completion(.incompleteStreetAddress)
            return
        }

        guard !address.city.isEmpty else {
            completion(.incompleteCity)
            return
        }

        guard address.state.count == 2 else {
            completion(.invalidState)
            return
        }

        guard !address.zipcode.isEmpty else {
            completion(.incompleteZipcode)
            return
        }

        // TODO: Geocode address
        GeocoderWrapper.geocodeAddress(address, completionHandler: { (placemark) in

        })
        // TODO: reverse geocode result
        // TODO: Check result against original address
        return .invalid
    }
}

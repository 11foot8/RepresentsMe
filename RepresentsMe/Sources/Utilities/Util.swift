//
//  Util.swift
//  
//
//  Created by Jacob Hausmann on 4/9/19.
//

import Foundation
import UIKit

/// Key for accessing rememberMeEnabled from UserDefaults
let REMEMBER_ME_KEY = "rememberMeEnabled"
let BIOMETRIC_KEY = "biometricAuthenticationEnabled"

class Util {
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    /// Whether rememberMe is enabled or not
    static var rememberMeEnabled:Bool {
        get {
            let enabled = UserDefaults.standard.object(forKey: REMEMBER_ME_KEY) as? Bool
            return enabled ?? false
        }
        set(enabled) {
            UserDefaults.standard.set(enabled, forKey: REMEMBER_ME_KEY)
        }
    }

    static var biometricEnabled:Bool {
        get {
            let enabled = UserDefaults.standard.object(forKey: BIOMETRIC_KEY) as? Bool
            return enabled ?? false
        }
        set(enabled) {
            UserDefaults.standard.set(enabled, forKey: BIOMETRIC_KEY)
        }
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
        completion(.invalid)
    }
}

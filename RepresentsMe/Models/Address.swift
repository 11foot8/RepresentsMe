//
//  Address.swift
//  RepresentsMe
//
//  Created by Benny Singer on 3/6/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import MapKit

/// Class containing relevant information about an address.
class Address: Equatable, CustomStringConvertible {
    var streetAddress:String
    var city:String
    var state:String
    var zipcode:String

    var description:String {            // Returns textual representation of the
        return "\(streetAddress)\n" +   // official. Conforms class to
            "\(city), " +               // CustomStringConvertible protocol.
            "\(state) " +
        "\(zipcode)"                   
    }

    /// Creates an Address given a placemark.
    ///
    /// - Parameter placemark:      Placemark of address
    init(with placemark:CLPlacemark) {
        let streetNumber = placemark.subThoroughfare != nil ? "\(placemark.subThoroughfare!) " : ""
        let street = placemark.thoroughfare != nil ? "\(placemark.thoroughfare!)" : ""
        self.streetAddress = "\(streetNumber)\(street)"

        self.city = placemark.locality ?? ""
        self.state = placemark.administrativeArea ?? ""
        self.zipcode = placemark.postalCode ?? ""
    }

    /// Creates an Address given a dictionary.
    ///
    /// - Parameter dictionary:      Dictionary mapping String descriptors to String addresses
    init(with dictionary:[String:String]) {
        self.streetAddress = dictionary["line1"] ?? ""
        self.city = dictionary["city"] ?? ""
        self.state = dictionary["state"] ?? ""
        self.zipcode = dictionary["zip"] ?? ""
    }

    /// Creates an Address given the values for each field.
    ///
    /// - Parameter streetAddress:  The number and street of the address
    /// - Parameter city:           The city of the address
    /// - Parameter state:          The state of the address
    /// - Parameter zipcode:        The zipcode of the address
    init(streetAddress:String, city:String, state:String, zipcode:String) {
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.zipcode = zipcode
    }

    /// Returns a String representation of the first line of the address.
    func addressLine1() -> String {
        return streetAddress
    }

    /// Returns a String representation of the second line of the address.
    func addressLine2() -> String {
        return "\(city), \(state) \(zipcode)"
    }

    /// Returns a String representation of the city and state of the address.
    func addressCityState() -> String {
        return "\(city), \(state)"
    }

    /// Returns a String representation of the full multi-line address
    func fullMultilineAddress() -> String {
        return "\(addressLine1())\n\(addressLine2())"
    }

    static func == (lhs: Address, rhs: Address) -> Bool {
        return (
            lhs.streetAddress == rhs.streetAddress &&
            lhs.city == rhs.city &&
            lhs.state == rhs.state &&
            lhs.zipcode == rhs.zipcode
        )
    }
}

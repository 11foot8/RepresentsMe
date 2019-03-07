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
    var streetNumber:String
    var streetName:String
    var city:String
    var state:String
    var zipcode:String

    var description:String {            // Returns textual representation of the
        return "\(streetNumber) " +      // official. Conforms class to
            "\(streetName)\n" +         // CustomStringConvertible protocol.
            "\(city), " +
            "\(state) " +
        "\(zipcode)"                   
    }

    /// Creates an Address given a placemark.
    ///
    /// - Parameter placemark:      Placemark of address
    init(with placemark:CLPlacemark) {
        self.streetNumber = placemark.subThoroughfare ?? ""
        self.streetName = placemark.thoroughfare ?? ""
        self.city = placemark.locality ?? ""
        self.state = placemark.administrativeArea ?? ""
        self.zipcode = placemark.postalCode ?? ""
    }

    /// Creates an Address given the values for each field.
    ///
    /// - Parameter streetNumber:   The street number of the address
    /// - Parameter streetName:     The street name of the address
    /// - Parameter city:           The city of the address
    /// - Parameter state:          The state of the address
    /// - Parameter zipcode:        The zipcode of the address
    init(streetNumber:String, streetName:String, city:String, state:String,
         zipcode:String) {
        self.streetNumber = streetNumber
        self.streetName = streetName
        self.city = city
        self.state = state
        self.zipcode = zipcode
    }

    static func == (lhs: Address, rhs: Address) -> Bool {
        return (
            lhs.streetNumber == rhs.streetNumber &&
            lhs.streetName == rhs.streetName &&
            lhs.city == rhs.city &&
            lhs.state == rhs.state &&
            lhs.zipcode == rhs.zipcode
        )
    }

    func streetRepr() -> String {
        return "\(streetNumber) \(streetName)"
    }
}

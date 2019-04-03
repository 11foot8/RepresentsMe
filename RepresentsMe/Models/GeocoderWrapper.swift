//
//  GeocoderWrapper.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 4/2/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation
import MapKit

class GeocoderWrapper {
    let geocoder = CLGeocoder()
    var workItem:DispatchWorkItem? = nil
    public func geocodeAddressString(_ address:String, completionHandler:@escaping (CLPlacemark) -> Void) {
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks:[CLPlacemark]?, error:Error?) -> Void in
            if let _ = error {
                // TODO: Show alert informing user
                return
            }
            guard let placemark = placemarks?.first else {
                // TODO: show alert informing user search failed
                return
            }
            if self.workItem != nil {
                self.workItem?.cancel()
            }
            self.workItem = DispatchWorkItem{ completionHandler(placemark) }
            DispatchQueue.main.async(execute: self.workItem!)
            })
    }

    public func reverseGeocodeCoordinates(_ coords:CLLocationCoordinate2D, completionHandler:@escaping (Address) -> Void) {

        let location = CLLocation(latitude: coords.latitude, longitude: coords.longitude)

        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks:[CLPlacemark]?, error:Error?) in
            // If an error occured, alert user and return immediately
            if let _ = error {
                // TODO: Show alert informing the user
                return
            }

            // placemark is a list of results, if no results returned, alert user and return immediately
            guard let placemark = placemarks?.first else {
                // TODO: Show alert informing the user
                return
            }

            // Get address from the placemark
            let address = Address(with: placemark)

            if self.workItem != nil {
                self.workItem?.cancel()
            }

            self.workItem = DispatchWorkItem{ completionHandler(address)}
            DispatchQueue.main.async(execute: self.workItem!)
            })

    }
}

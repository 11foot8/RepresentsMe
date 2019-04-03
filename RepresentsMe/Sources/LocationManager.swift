//
//  LocationManager.swift
//  RepresentsMe
//
//  Created by Benny Singer on 4/3/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()

    private var locationManager: CLLocationManager

    public var userLocation: CLLocation? {
        return locationManager.location
    }

    private override init() {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    /// Check that location services are enabled, if so set up services,
    /// if not alert user that location services are not enabled.
    func checkLocationServices() -> Bool {
        // Check if Location Services are enabled globally
        if CLLocationManager.locationServicesEnabled() {
            return checkLocationAuthorization()
        } else {
            // TODO: show alert for letting user know they have to turn this on
        }

        return false
    }

    /// Check what location authorization the application has, and alert user if
    /// they need to take action to enable location authorization.
    private func checkLocationAuthorization() -> Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            return true
        case .denied:
            // TODO: show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            // TODO: show an alert letting them know whats up
            break
        }
        return false
    }

    private func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
        }
    }
}

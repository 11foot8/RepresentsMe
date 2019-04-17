//
//  LocationManager.swift
//  RepresentsMe
//
//  Created by Benny Singer on 4/3/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import UIKit
import MapKit

protocol LocationAuthorizationListener {
    func didChangeLocationAuthorization()
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    // MARK: - Static Properties
    static let shared = LocationManager()

    private static var locationAuthorizationListeners:[LocationAuthorizationListener] = []

    // MARK: - Properties
    private var locationManager: CLLocationManager

    public var userLocation: CLLocation? {
        return locationManager.location
    }

    public var userCoordinate: CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }

    // MARK: - Lifecycle
    private override init() {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Methods

    /// Adds a listener for changes in location authorization
    ///
    /// - Parameter listener:   the LocationAuthorizationListener to add
    static func addLocationAuthorizationListener(_ listener:LocationAuthorizationListener) {
        locationAuthorizationListeners.append(listener)
    }

    /// Removes a listener for changes in location authorization
    ///
    /// - Parameter listener:   the LocationAuthorizationListener to remove
    static func removeLocationAuthorizationListener(_ listener: LocationAuthorizationListener) {
        if let index = find(listener: listener, in: locationAuthorizationListeners) {
            locationAuthorizationListeners.remove(at: index)
        }
    }

    /// Finds the given listener in the given Array of listeners
    ///
    /// - Parameter listener:   the listener to search for
    /// - Parameter in:         the Array to search
    ///
    /// - Returns: the index if found or nil if not found
    private static func find(listener:LocationAuthorizationListener,
                             in listeners:[LocationAuthorizationListener]) -> Int? {
        return listeners.firstIndex {(appStateListener) in
            if let listener1 = listener as? UIViewController,
                let listener2 = appStateListener as? UIViewController {
                return listener1 === listener2
            }

            // should never occur
            return false
        }
    }

    /// Returns whether location services are available to this app
    func locationServicesEnabledAndAuthorized() -> Bool {
        // Check if Location Services are enabled globally
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse, .authorizedAlways:
                return true
            default:
                return false
            }
        }
        return false
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

    // MARK: - CLLocationManagerDelegate
    private func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        for listener in LocationManager.locationAuthorizationListeners {
            listener.didChangeLocationAuthorization()
        }
        if (status == .authorizedAlways || status == .authorizedWhenInUse) {
            locationManager.startUpdatingLocation()
        }
    }
}

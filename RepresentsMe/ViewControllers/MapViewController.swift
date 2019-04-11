//
//  MapViewController.swift
//  RepresentsMe
//
//  Created by Jacob Hausmann on 2/22/19.
//  Copyright © 2019 11foot8. All rights reserved.

import UIKit
import MapKit
import Foundation

let SANDBOX_OFFICIALS_SEGUE_IDENTIFIER = "sandboxOfficials"

/// The protocol to implement to receive a location when the user selects a
/// location on the map.
protocol LocationSelectionDelegate {
    func didSelectLocation(location: CLLocationCoordinate2D, address: Address)
}

/// The view controller that displays a map for the user to interact with.
/// The map allows the user to drop pins, go to their current location, and go
/// to their home location. Depending on the mode, the map can send the
/// location to show Officials for the selected Address or to select the
/// location as the location for an Event.
class MapViewController: UIViewController,
                         MKMapViewDelegate,
                         UISearchBarDelegate,
                         LocationInfoDelegate,
                         CustomSearchBarDelegate,
                         MapActionButtonsDelegate {

    /// The modes avaliable for the map view controller
    enum ReachType {
        case map        // The sandbox mode
        case event      // The mode for selecting a location for an Event
    }

    // MARK: - Properties
    
    // Make regions 10km across
    let regionInMeters:CLLocationDistance = 10000
    // Only request new geocodes when the pin has moved at least 50m
    let minimumDistanceForNewGeocode:CLLocationDistance = 50
    // Only request new geocode once per second
    let minimumTimeForNewGecode:TimeInterval = 1
    
    var previousLocation:CLLocation?
    var previousGeocodeTime:Date?
    var address:Address?
    var annotation:MKAnnotation?
    var reachType:ReachType = .map
    var delegate: LocationSelectionDelegate?
    var workItem:DispatchWorkItem?

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var customSearchBar: CustomSearchBar!
    @IBOutlet weak var locationInfoView: LocationInfo!
    @IBOutlet weak var mapActionButtons: MapActionButtons!

    // MARK: - Lifecycle
    
    /// Sets up the map view and delegates
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the map view
        self.setupMapView()
        
        // Setup delegates
        locationInfoView.delegate = self
        customSearchBar.delegate = self
        mapActionButtons.delegate = self
    }
    
    /// Hide the navigation bar when the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    /// Show the navigation bar when the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        delegate = nil
        reachType = .map
    }

    // MARK: - Actions
    
    /// Geocode the address given when search started and drop an pin on the
    /// location if one is found.k
    ///
    /// - Parameter query:  the entered address
    func onSearchQuery(query: String) {
        GeocoderWrapper.geocodeAddressString(query) {(placemark) in
            let coords = placemark.location!.coordinate
            self.dropPin(coords: coords,
                         title: "Searched Address",
                         replaceSearchedValue: false)
            self.centerView(on: coords, animated: false)
        }
    }

    /// Clear any pins when the search bar is cleared
    func onSearchClear() {
        clearPin()
    }

    /// Drops a pin on the selected location when a user long presses the map
    @objc func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let touchMapCoordinate = mapView.convert(touchPoint,
                                                     toCoordinateFrom: mapView)

            dropPin(coords: touchMapCoordinate,
                    title: "Dropped pin",
                    replaceSearchedValue: true)
        }
    }

    // MARK: - MapActionButtonsDelegate
    
    /// Centers the map on the user's current location
    func onLocateTouchUp() {
        if let coordinate = LocationManager.shared.userCoordinate {
            centerView(on: coordinate,animated: true)
            dropPin(coords: coordinate,
                    title: "Current Location",
                    replaceSearchedValue: true)
        }
    }

    /// Move view to user's saved address and drop a pin
    func onHomeTouchUp() {
        UsersDatabase.getCurrentUserAddress {(address, error) in
            if let _ = error {
                // TODO: Handle error
            } else {
                if let addressStr = address?.description {
                    GeocoderWrapper.geocodeAddressString(
                        addressStr) {(placemark) in
                            
                        let coords = placemark.location!.coordinate
                        self.dropPin(coords: coords,
                                     title: "Home",
                                     replaceSearchedValue: true)
                        self.centerView(on: coords, animated: true)
                    }
                } else {
                    // TODO: Handle nil address error
                }
            }
        }
    }

    // MARK: - Methods
    
    /// Clears the set pin
    func clearPin() {
        if let annotation = self.annotation {
            mapView.removeAnnotation(annotation)
        }
        locationInfoView.isHidden = true
    }

    /// Drops a pin at the given coordinates
    ///
    /// - Parameter coords:                 the coordinates to drop the pin at
    /// - Parameter title:                  the title for the pin
    /// - Parameter replaceSearchedValue:   whether or not to replace the
    ///                                     search bar text
    func dropPin(coords:CLLocationCoordinate2D,
                 title:String,
                 replaceSearchedValue:Bool) {
        // Replace the search bar text
        if replaceSearchedValue {
            customSearchBar.setQuery(title)
        }
        
        // Remove an existing pins
        self.clearPin()

        // Drop the new pin
        self.annotation = DroppedPin(title: title,
                                     locationName: "",
                                     discipline: "",
                                     coordinate: coords)
        mapView.addAnnotation(annotation!)
        
        // Update the location info view
        locationInfoView.isHidden = false
        locationInfoView.updateWithCoordinates(coords: coords, title: title)
    }

    // MARK: - Location Utilities
    
    /// Center mapView on user location with default zoom level,
    /// animate transition.
    func centerViewOnUserLocation() {
        if let coordinate = LocationManager.shared.userCoordinate {
            centerView(on: coordinate, animated: true)
        }
    }

    /// Center mapView on given locaiton.
    ///
    /// - Parameter on:         Location on which to center mapView
    /// - Parameter animated:   Whether or not to animate the transition
    func centerView(on location:CLLocationCoordinate2D, animated:Bool) {
        let region = MKCoordinateRegion(center: location,
                                        latitudinalMeters: regionInMeters,
                                        longitudinalMeters: regionInMeters)
        // Set zoom level
        mapView.setRegion(region, animated: animated)
        
        // Correct center
        mapView.setCenter(location, animated: animated)
    }

    /// Returns the current center location of mapView
    ///
    /// - Parameter for:    the map view to get the center of
    ///
    /// - Returns: Current center location of mapView
    func getCenterLocation(for mapView:MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    /// Convert MKCoordinateRegion to CLCircularRegion.
    ///
    /// - Parameter mk:     the MKCoordinateRegion to convert
    ///
    /// - Returns: the converted CLCircularRegion
    func convertRegion(mk:MKCoordinateRegion) -> CLCircularRegion {
        // MKCoordinateRegion is a center and span
        // Span is 2 values, latitudeDelta and longitudeDelta
        // To convert to CLCircularRegion, a center and radius is needed

        let center = mk.center                      // Center of region
        let span = mk.span                          // Span of region

        // Northwest corner of region
        let nw = CLLocation(latitude:  center.latitude  + span.latitudeDelta  / 2,
                            longitude: center.longitude - span.longitudeDelta / 2)
        // Southeast corner of region
        let se = CLLocation(latitude:  center.latitude  - span.latitudeDelta  / 2,
                            longitude: center.longitude + span.longitudeDelta / 2)

        let radius = nw.distance(from: se) / 2      // Radius of region
        let region = CLCircularRegion(center: center,
                                      radius: radius,
                                      identifier: "region")
        
        // CLCircularRegion analog to MKCoordinateRegion
        return region
    }

    // MARK: - Keyboard
    
    /// Hide keyboard when tapping out of SearchBar
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: - LocationInfoDelegate
    
    /// Handles when the go button is pressed.
    /// If in the sandbox mode, show the Officials for the given Address.
    /// If selecting a location for an Event, send the Address back to the
    /// delegate.
    ///
    /// - Parameter address:    the selected Address
    func goButtonPressed(address: Address) {
        switch reachType {
        case .map:
            // Selected a location for the sandbox view, show the Officials for
            // that location
            AppState.sandboxAddress = address
            
            // TODO: Check address validity - incl. addresses outside of US
            performSegue(withIdentifier: SANDBOX_OFFICIALS_SEGUE_IDENTIFIER,
                         sender: self)
            break
        case .event:
            // Selected a location for the Event, send location to the delegate
            // and dismiss
            delegate?.didSelectLocation(location: self.annotation!.coordinate,
                                        address: address)
            navigationController?.popViewController(animated: true)
        }
    }

    /// Prepare to segue to the Officials table view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SANDBOX_OFFICIALS_SEGUE_IDENTIFIER {
            let destination = segue.destination as! HomeViewController
            destination.reachType = .map
        }
    }
    
    /// Sets up the map view
    private func setupMapView() {
        // Default location to the center of the map
        previousLocation = getCenterLocation(for: mapView)
        previousGeocodeTime = Date()
        
        // Center the map on the user if they allowed location services
        if LocationManager.shared.checkLocationServices() {
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
        }
        
        // Setup long press gesture recognizer to drop pins
        let longPressRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(MapViewController.handleLongPress))
        mapView.addGestureRecognizer(longPressRecognizer)
        
        // Clear any previous pins
        clearPin()
    }
}

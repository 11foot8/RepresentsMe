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

enum MapViewControllerReachType {
    case map
    case event
}

protocol LocationSelectionDelegate {
    func didSelectLocation(location: CLLocationCoordinate2D, address: Address)
}

class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, LocationInfoDelegate, CustomSearchBarDelegate,
MapActionButtonsDelegate {
    // MARK: - Properties
    let regionInMeters:CLLocationDistance = 10000            // Regions will be 10 km across

    var previousLocation:CLLocation?                         // Save previous location to limit
                                                             // geocode frequency
    var previousGeocodeTime:Date?

    let minimumDistanceForNewGeocode:CLLocationDistance = 50 // Only request new geocodes when
                                                             // pin is moved 50+ meters
    let minimumTimeForNewGecode:TimeInterval = 1             // Only request new geocode once per second

    var address:Address?

    var annotation:MKAnnotation?

    var reachType: MapViewControllerReachType = .map

    var delegate: LocationSelectionDelegate?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        previousLocation = getCenterLocation(for: mapView)
        previousGeocodeTime = Date()

        if LocationManager.shared.checkLocationServices() {
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
        }

        // Set up Location Info View
        locationInfoView.delegate = self

        // Set up search bar
        customSearchBar.delegate = self

        mapActionButtons.delegate = self

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.handleLongPress))
        mapView.addGestureRecognizer(longPressRecognizer)

        clearPin()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        delegate = nil
        reachType = .map
    }

    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var customSearchBar: CustomSearchBar!
    @IBOutlet weak var locationInfoView: LocationInfo!
    @IBOutlet weak var mapActionButtons: MapActionButtons!

    // MARK: - Actions
    func onSearchQuery(query: String) {
        let address:String = query
        GeocoderWrapper.geocodeAddressString(address, completionHandler: self.geocodeSearchedAddressCompletionHandler)
    }

    func onSearchClear() {
        clearPin()
    }

    func geocodeSearchedAddressCompletionHandler(placemark:CLPlacemark) {
        let coords = placemark.location!.coordinate
        dropPin(coords: coords, title: "Searched Address", replaceSearchedValue: false)
        self.centerView(on: coords, animated: false)
    }

    func geocodeHomeAddressCompletionHandler(placemark:CLPlacemark) {
        let coords = placemark.location!.coordinate
        dropPin(coords: coords, title: "Home", replaceSearchedValue: true)
        self.centerView(on: coords, animated: true)
    }

    @objc func handleLongPress(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .began { return }

        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        dropPin(coords: touchMapCoordinate, title: "Dropped pin", replaceSearchedValue: true)
    }

    // MARK: - MapActionButtonsDelegate
    func onLocateTouchUp() {
        if let coordinate = LocationManager.shared.userCoordinate {
            centerView(on: coordinate,animated: true)
            dropPin(coords: coordinate, title: "Current Location", replaceSearchedValue: true)
        }
    }

    /// Move view to user's saved address and drop a pin
    func onHomeTouchUp() {
        let address = userAddr.description
        GeocoderWrapper.geocodeAddressString(address, completionHandler: self.geocodeHomeAddressCompletionHandler)
    }

    // MARK: - Methods
    func clearPin() {
        if self.annotation != nil {
            mapView.removeAnnotation(self.annotation!)
        }
        locationInfoView.isHidden = true
    }

    func dropPin(coords:CLLocationCoordinate2D, title:String, replaceSearchedValue:Bool) {
        if replaceSearchedValue {
            customSearchBar.setQuery(title)
        }
        locationInfoView.isHidden = false
        if (self.annotation != nil) {
            mapView.removeAnnotation(self.annotation!)
            self.annotation = nil
        }
        self.annotation = DroppedPin(title: title, locationName: "", discipline: "", coordinate: coords)
        mapView.addAnnotation(annotation!)
        locationInfoView.isHidden = false
        locationInfoView.updateWithCoordinates(coords: coords, title: title)
    }

    // MARK: - Location Utilities
    /// Center mapView on user location with default zoom level, animate transition.
    func centerViewOnUserLocation() {
        if let coordinate = LocationManager.shared.userCoordinate {
            centerView(on: coordinate, animated: true)
        }
    }

    /// Center mapView on given locaiton.
    /// - Parameter location: Location on which to center mapView
    /// - Parameter animated: Whether or not to animate the transition
    func centerView(on location:CLLocationCoordinate2D, animated:Bool) {
        let region = MKCoordinateRegion.init(center:location,
                                             latitudinalMeters: regionInMeters,
                                             longitudinalMeters: regionInMeters)
        // Set zoom level
        mapView.setRegion(region, animated: animated)
        // Correct center
        mapView.setCenter(location, animated: animated)
    }

    /// Returns the current center location of mapView
    /// - Returns: Current center location of mapView
    func getCenterLocation(for mapView:MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    /// Convert MKCoordinateRegion to CLCircularRegion.
    func convertRegion(mk:MKCoordinateRegion) -> (CLCircularRegion) {
        // MKCoordinateRegion is a center and span
        //  Span is 2 values, latitudeDelta and longitudeDelta
        //  To convert to CLCircularRegion, a center and radius is needed

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
        // Hide keyboard when tapping out of SearchBar
        self.view.endEditing(true)
    }

    // MARK: - LocationInfoDelegate
    func goButtonPressed(address: Address) {
        switch reachType {
        case .map:
            self.address = address
            // TODO: Check address validity - incl. addresses outside of US
            performSegue(withIdentifier: SANDBOX_OFFICIALS_SEGUE_IDENTIFIER, sender: self)
            break
        case.event:
            delegate?.didSelectLocation(location: self.annotation!.coordinate, address: address)
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SANDBOX_OFFICIALS_SEGUE_IDENTIFIER {
            let destination = segue.destination as! HomeViewController
            destination.addr = self.address!
            destination.reachType = .map
        }
    }
}
